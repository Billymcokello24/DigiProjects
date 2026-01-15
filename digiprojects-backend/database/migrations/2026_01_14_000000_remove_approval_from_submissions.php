<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('submissions', function (Blueprint $table) {
            // Drop approval-related columns if they exist
            if (Schema::hasColumn('submissions', 'approval_status')) {
                $table->dropColumn('approval_status');
            }
            if (Schema::hasColumn('submissions', 'admin_feedback')) {
                $table->dropColumn('admin_feedback');
            }
            if (Schema::hasColumn('submissions', 'reviewed_by')) {
                $table->dropColumn('reviewed_by');
            }
            if (Schema::hasColumn('submissions', 'reviewed_at')) {
                $table->dropColumn('reviewed_at');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('submissions', function (Blueprint $table) {
            $table->string('approval_status')->default('pending')->after('remarks');
            $table->text('admin_feedback')->nullable()->after('approval_status');
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->onDelete('set null')->after('admin_feedback');
            $table->timestamp('reviewed_at')->nullable()->after('reviewed_by');
        });
    }
};
