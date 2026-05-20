<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MigrateSqliteToMysql extends Command
{
    protected $signature = 'migrate:sqlite-to-mysql {--tables=*}';
    protected $description = 'Copy data from the sqlite connection to the mysql connection for listed tables (or all)';

    public function handle()
    {
        $tables = $this->option('tables');
        $allTables = [
            'users', 'counties', 'regions', 'projects', 'phases', 'submissions', 'migrations', 'personal_access_tokens'
        ];

        if (empty($tables)) {
            $tables = $allTables;
        }

        foreach ($tables as $table) {
            $this->info("Migrating table: $table");
            try {
                $rows = DB::connection('sqlite')->table($table)->get();
            } catch (\Exception $e) {
                $this->error("Failed reading table $table from sqlite: " . $e->getMessage());
                continue;
            }

            DB::connection('mysql')->transaction(function () use ($table, $rows) {
                // Truncate target table to avoid duplicates
                DB::connection('mysql')->table($table)->truncate();

                foreach ($rows as $row) {
                    $data = (array) $row;
                    // Remove sqlite-specific rowid if present
                    if (array_key_exists('rowid', $data)) unset($data['rowid']);
                    // Convert DateTime objects to strings
                    array_walk($data, function (&$v) {
                        if ($v instanceof \DateTime) $v = $v->format('Y-m-d H:i:s');
                    });

                    // Insert - if the table has an auto-increment primary key, ensure provided ID is inserted
                    DB::connection('mysql')->table($table)->insert($data);
                }
            });

            $this->info("Finished migrating $table (" . count($rows) . " rows)");
        }

        $this->info('Migration completed.');
        return 0;
    }
}
