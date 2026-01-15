<?php

namespace Database\Seeders;

use App\Models\County;
use App\Models\Region;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class InitialSetupSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create regions if they don't exist
        $coastRegion = Region::firstOrCreate(
            ['name' => 'Coast'],
            ['coordinator_id' => null]
        );

        $nyanzaRegion = Region::firstOrCreate(
            ['name' => 'Nyanza'],
            ['coordinator_id' => null]
        );

        // Create counties
        $mombasa = County::firstOrCreate(
            ['name' => 'Mombasa'],
            [
                'region_id' => $coastRegion->id,
                'is_active' => true,
            ]
        );

        $kwale = County::firstOrCreate(
            ['name' => 'Kwale'],
            [
                'region_id' => $coastRegion->id,
                'is_active' => true,
            ]
        );

        $siaya = County::firstOrCreate(
            ['name' => 'Siaya'],
            [
                'region_id' => $nyanzaRegion->id,
                'is_active' => true,
            ]
        );

        $kisumu = County::firstOrCreate(
            ['name' => 'Kisumu'],
            [
                'region_id' => $nyanzaRegion->id,
                'is_active' => true,
            ]
        );

        // Update existing officers with counties
        $officer1 = User::where('email', 'officer@mombasa.go.ke')->first();
        if ($officer1) {
            $officer1->update(['county_id' => $mombasa->id]);
        }

        $officer2 = User::where('email', 'officer@siaya.go.ke')->first();
        if ($officer2) {
            $officer2->update(['county_id' => $siaya->id]);
        }

        // Create additional officers
        User::firstOrCreate(
            ['email' => 'officer@kwale.go.ke'],
            [
                'name' => 'Kwale Officer',
                'password' => Hash::make('password'),
                'role' => 'COUNTY_OFFICER',
                'county_id' => $kwale->id,
            ]
        );

        User::firstOrCreate(
            ['email' => 'officer@kisumu.go.ke'],
            [
                'name' => 'Kisumu Officer',
                'password' => Hash::make('password'),
                'role' => 'COUNTY_OFFICER',
                'county_id' => $kisumu->id,
            ]
        );

        echo "✓ Initial setup completed: 4 counties created, 4 officers assigned\n";
    }
}
