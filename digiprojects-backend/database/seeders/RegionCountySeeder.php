<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class RegionCountySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $regions = [
            'Nairobi' => ['Nairobi City'],
            'Central' => ['Kiambu', 'Nyeri', 'Murang\'a', 'Kirinyaga', 'Nyandarua'],
            'Coast' => ['Mombasa', 'Kwale', 'Kilifi', 'Tana River', 'Lamu', 'Taita Taveta'],
            'Rift Valley' => ['Nakuru', 'Uasin Gishu', 'Kajiado', 'Narok', 'Kericho', 'Bomet', 'Nandi'],
            'Western' => ['Kakamega', 'Vihiga', 'Bungoma', 'Busia'],
            'Eastern' => ['Machakos', 'Makueni', 'Kitui', 'Embu', 'Meru', 'Isiolo', 'Marsabit'],
            'Nyanza' => ['Kisumu', 'Kisii', 'Homa Bay', 'Migori', 'Siaya', 'Nyamira'],
            'North Eastern' => ['Garissa', 'Wajir', 'Mandera'],
        ];

        foreach ($regions as $regionName => $counties) {
            $region = \App\Models\Region::create(['name' => $regionName]);
            
            foreach ($counties as $countyName) {
                \App\Models\County::create([
                    'name' => $countyName,
                    'region_id' => $region->id,
                    'is_active' => true
                ]);
            }
        }
    }
}
