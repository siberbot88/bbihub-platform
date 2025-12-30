<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Workshop;
use App\Models\WorkshopDocument;

class PerformanceTestSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info('Starting Basic Workshop Seeding...');

        // List of 15 Realistic Workshop Names
        $realNames = [
            'Bengkel Maju Jaya Motor',
            'Prima Auto Service',
            'Cahaya Abadi Mobil',
            'Mitra Teknik Utama',
            'Garage 88 Performance',
            'Dunia Ban & Service',
            'Sinar Harapan Motor',
            'Klinik Mobil Sehat',
            'Berkah Jaya Abadi',
            'Solusi Mesin Diesel',
            'Transmisi Pak Budi',
            'Auto Kilat Service',
            'Bintang Motor Sport',
            'Mekanik Handal Express',
            'Semesta Otomotif'
        ];

        // Cities distribution for Map Testing
        $cities = [
            0 => 'Surabaya',
            1 => 'Surabaya',
            2 => 'Surabaya',
            3 => 'Surabaya',
            4 => 'Surabaya',
            5 => 'Jakarta',
            6 => 'Jakarta',
            7 => 'Jakarta',
            8 => 'Bandung',
            9 => 'Bandung',
            10 => 'Medan',
            11 => 'Semarang',
            12 => 'Makassar',
            13 => 'Denpasar',
            14 => 'Yogyakarta'
        ];

        foreach ($realNames as $index => $workshopName) {
            $slug = \Illuminate\Support\Str::slug($workshopName);
            $ownerEmail = "owner.{$slug}@demobbihub.com";

            // A. Owner
            $owner = User::where('email', $ownerEmail)->first();
            if (!$owner) {
                // Buat user baru tanpa role column (sesuai request database user)
                $owner = User::factory()->create([
                    'name' => 'Owner ' . $workshopName,
                    'username' => 'owner.' . $slug,
                    'email' => $ownerEmail,
                    'password' => bcrypt('password'),
                ]);

                // Assign Role via Spatie
                try {
                    $owner->assignRole('owner');
                } catch (\Throwable $e) {
                }
            }

            // B. Workshop
            $city = $cities[$index] ?? 'Surabaya';
            $workshop = Workshop::where('name', $workshopName)->first();

            if (!$workshop) {
                $workshop = Workshop::factory()->create([
                    'user_uuid' => $owner->id,
                    'name' => $workshopName,
                    'city' => $city,
                    'province' => 'Jawa Timur', // Simplified
                    'status' => 'active',
                    // Optional: coordinates could be seeded here if database has lat/long columns
                ]);

                // C. Document
                WorkshopDocument::factory()->create([
                    'workshop_uuid' => $workshop->id
                ]);
            } else {
                // Update city if it exists but is different (fix existing bad data)
                if ($workshop->city !== $city) {
                    $workshop->update(['city' => $city]);
                }
            }

            $this->command->info("Seeded: {$workshop->name} in {$workshop->city}");
        }

        $this->command->info('Seeding Completed: 15 Workshops Created.');
    }
}
