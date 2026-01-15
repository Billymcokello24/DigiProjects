<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $mombasa = \App\Models\County::where('name', 'Mombasa')->first();
        $siaya = \App\Models\County::where('name', 'Siaya')->first();

        User::create([
            'name' => 'Mombasa Officer',
            'email' => 'officer@mombasa.go.ke',
            'password' => Hash::make('password'),
            'role' => 'COUNTY_OFFICER',
            'county_id' => $mombasa ? $mombasa->id : null,
        ]);

        User::create([
            'name' => 'Siaya Officer',
            'email' => 'officer@siaya.go.ke',
            'password' => Hash::make('password'),
            'role' => 'COUNTY_OFFICER',
            'county_id' => $siaya ? $siaya->id : null,
        ]);

        User::create([
            'name' => 'System Admin',
            'email' => 'admin@icta.go.ke',
            'password' => Hash::make('password'),
            'role' => 'ADMIN',
            'county_id' => null,
        ]);
    }
}
