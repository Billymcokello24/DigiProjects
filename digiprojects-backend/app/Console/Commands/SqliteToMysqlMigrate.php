<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Config;

class SqliteToMysqlMigrate extends Command
{
    /**
     * The name and signature of the console command.
     *
     * --tables=comma,separated list to limit tables
     * --force to overwrite existing data in mysql
     * --sqlite-path to provide an explicit path to the sqlite DB file
     */
    protected $signature = 'db:sqlite-to-mysql {--tables=} {--force} {--sqlite-path=}';

    /**
     * The console command description.
     */
    protected $description = 'Copy data from the sqlite connection to the mysql connection (chunked)';

    public function handle(): int
    {
        $this->info('Starting sqlite -> mysql migration');

        $allowed = [
            'users',
            'regions',
            'counties',
            'projects',
            'phases',
            'submissions',
            'password_reset_tokens',
            'sessions',
            'personal_access_tokens',
            'migrations',
        ];

        $opt = $this->option('tables');
        $tables = $opt ? array_map('trim', explode(',', $opt)) : $allowed;

        // Validate tables
        foreach ($tables as $t) {
            if (!in_array($t, $allowed)) {
                $this->error("Table not whitelisted: $t");
                return 1;
            }
        }

        // If user provided a sqlite path, override the sqlite connection database config
        $sqlitePath = $this->option('sqlite-path');
        if ($sqlitePath) {
            $this->info("Overriding sqlite database path: $sqlitePath");
            Config::set('database.connections.sqlite.database', $sqlitePath);
        }

        // Test connections
        try {
            DB::connection('sqlite')->getPdo();
            DB::connection('mysql')->getPdo();
        } catch (\Exception $e) {
            $this->error('Failed to connect to one of the databases: ' . $e->getMessage());
            return 1;
        }

        // Disable foreign key checks on mysql target
        $this->info('Disabling foreign key checks on mysql target');
        DB::connection('mysql')->statement('SET FOREIGN_KEY_CHECKS=0;');

        foreach ($tables as $table) {
            $this->line("\nProcessing table: $table");

            // Ensure source table exists
            $sourceHas = Schema::connection('sqlite')->hasTable($table);
            if (!$sourceHas) {
                $this->warn("Source sqlite table not found: $table — skipping");
                continue;
            }

            // Ensure target table exists
            $targetHas = Schema::connection('mysql')->hasTable($table);
            if (!$targetHas) {
                $this->warn("Target mysql table not found: $table — skipping");
                continue;
            }

            $targetCount = DB::connection('mysql')->table($table)->count();
            if ($targetCount > 0 && !$this->option('force')) {
                $this->warn("Target table $table already has $targetCount rows. Use --force to overwrite/skippable behavior. Skipping.");
                continue;
            }

            if ($this->option('force')) {
                DB::connection('mysql')->table($table)->truncate();
                $this->info("Truncated target table $table");
            }

            $bar = null;
            $total = DB::connection('sqlite')->table($table)->count();
            if ($total > 0) {
                $bar = $this->output->createProgressBar($total);
                $bar->start();
            }

            // chunked copy
            DB::connection('sqlite')->table($table)->orderByRaw('1')->chunk(500, function ($rows) use ($table, $bar) {
                $insert = [];
                foreach ($rows as $r) {
                    $row = (array) $r;
                    // remove attributes that don't exist in target? assume schemas match
                    $insert[] = $row;
                }
                if (!empty($insert)) {
                    // insert preserving ids (works if schema allows explicit ids)
                    DB::connection('mysql')->table($table)->insert($insert);
                    if ($bar) $bar->advance(count($insert));
                }
            });

            if ($bar) {
                $bar->finish();
                $this->info('');
            }

            $this->info("Finished copying table: $table");
        }

        // Re-enable FK checks
        DB::connection('mysql')->statement('SET FOREIGN_KEY_CHECKS=1;');

        $this->info('\nMigration complete.');
        return 0;
    }
}
