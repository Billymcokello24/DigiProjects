<?php

namespace Database\Seeders;

use App\Models\Submission;
use App\Models\User;
use Illuminate\Database\Seeder;

class SubmissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $officer = User::where('email', 'officer@siaya.go.ke')->first();

        if ($officer) {
            $data = [
                ['project_type' => 'CCP', 'phase' => 'Phase 2', 'site' => 'Siaya CC', 'status' => 'UP', 'remarks' => 'Stable'],
                ['project_type' => 'CCP', 'phase' => 'Phase 2', 'site' => 'Treasury', 'status' => 'DOWN', 'remarks' => 'Faulty switch'],
                ['project_type' => 'CCP', 'phase' => 'Phase 2', 'site' => 'Police', 'status' => 'DOWN', 'remarks' => 'Blown out switch'],
                ['project_type' => 'NOFBI', 'phase' => 'NOFBI 2', 'site' => 'Siaya CC', 'status' => 'UP', 'remarks' => 'Stable'],
                ['project_type' => 'DSH', 'phase' => 'Ongoing', 'site' => 'Bondo Sub-county', 'status' => 'Ongoing', 'remarks' => 'Fiber stringing done'],
                ['project_type' => 'Public Wi-Fi', 'phase' => 'Phase 4', 'site' => 'Bondo Market', 'status' => 'UP', 'remarks' => 'Stable'],
            ];

            foreach ($data as $item) {
                $officer->submissions()->create($item);
            }
        }
    }
}
