<?php

namespace Database\Seeders;

use App\Models\Service;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\Workshop;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Faker\Factory as Faker;

class AnalyticsDummySeeder extends Seeder
{
    public function run()
    {
        $faker = Faker::create('id_ID');

        // Target Users
        $workshopUser = User::where('name', 'Lina Marlina')->first();
        if (!$workshopUser) {
            $this->command->error("User Lina Marlina not found!");
            return;
        }

        // Fetch Workshop: Explicitly use ID link confirmed by debug script
        $workshop = Workshop::where('user_uuid', $workshopUser->id)->first();

        if (!$workshop) {
            $this->command->error("Workshop not found for user: " . $workshopUser->id);
            // Fallback: Check if user has workshop_uuid directly set
            $workshopUuid = $workshopUser->workshop_uuid;
            if (!$workshopUuid) {
                return;
            }
        } else {
            $workshopUuid = $workshop->id;
        }

        // Use Spatie method safely (User::role throws if role missing)
        $customerId = null;
        try {
            // Try standard Eloquent way first to avoid Spatie exception
            $customerId = User::whereHas('roles', function ($q) {
                $q->where('name', 'customer');
            })->value('id');
        } catch (\Exception $e) {
            // Ignore
        }

        // Final fallback: just get random user that is not the owner
        if (!$customerId) {
            $customerId = User::where('id', '!=', $workshopUser->id)->value('id');
        }

        // If still no customer (only 1 user in DB?), create one
        if (!$customerId) {
            $this->command->info("Creating dummy customer...");
            $dummyCustomer = User::factory()->create([
                'name' => 'Dummy Customer',
                'email' => 'dummy' . rand(100, 999) . '@example.com',
                'password' => bcrypt('password'),
            ]);
            try {
                $dummyCustomer->assignRole('customer');
            } catch (\Exception $e) {
            }
            $customerId = $dummyCustomer->id;
        }

        if (!$customerId) {
            // Last resort: use the owner itself
            $this->command->warn("Using Owner as Customer (fallback)");
            $customerId = $workshopUser->id;
        }

        $vehicle = Vehicle::first();
        if (!$vehicle) {
            // Create dummy vehicle
            $vehicle = Vehicle::create([
                'id' => $faker->uuid,
                'customer_uuid' => $customerId,
                'workshop_uuid' => $workshopUuid,
                'brand' => 'Toyota',
                'model' => 'Avanza',
                'year' => '2020',
                'plate_number' => 'B ' . rand(1000, 9999) . ' XYZ',
                'color' => 'Black',
                'transmission' => 'Automatic',
            ]);
        }


        if (!$customerId || !$vehicle) {
            $this->command->error("Need at least 1 customer and 1 vehicle.");
            return;
        }

        $this->command->info("Injecting analytics data for Workshop: $workshopUuid");

        // Generate data for past 12 months
        $startDate = Carbon::now()->subMonths(12)->startOfMonth();
        $endDate = Carbon::now()->endOfMonth();

        $servicesToInsert = [];
        $transactionsToInsert = [];

        // Distribute 100 transactions randomly
        for ($i = 0; $i < 100; $i++) {
            $randomDate = Carbon::createFromTimestamp(rand($startDate->timestamp, $endDate->timestamp));

            // Random Amount: 100k - 2000k
            $amount = rand(100, 2000) * 1000;

            // Service
            $serviceId = $faker->uuid;
            $servicesToInsert[] = [
                'id' => $serviceId,
                'code' => 'SRV-' . strtoupper($faker->bothify('??####')),
                'customer_uuid' => $customerId,
                'vehicle_uuid' => $vehicle->id,
                'workshop_uuid' => $workshopUuid,
                'category_service' => $faker->randomElement(['ringan', 'sedang', 'berat', 'maintenance']), // Correct ENUM values
                'name' => 'Service Regular',
                'description' => 'Dummy service for analytics',
                'reason' => 'lainnya', // Correct ENUM value (was 'Maintenance')
                'status' => 'completed',
                'acceptance_status' => 'accepted',
                'type' => 'walk-in',
                'scheduled_date' => $randomDate->toDateString(),
                'estimated_time' => $randomDate->clone()->addHours(2)->toDateString(), // Correct: DATE column
                'created_at' => $randomDate,
                'updated_at' => $randomDate,
                'technician_name' => 'Tech ' . $faker->firstName, // Add technician_name
            ];

            // Transaction
            $transactionsToInsert[] = [
                'id' => $faker->uuid,
                'service_uuid' => $serviceId,
                'workshop_uuid' => $workshopUuid,
                'amount' => rand(150000, 500000),
                'status' => 'success',
                'payment_method' => $faker->randomElement(['cash', 'transfer', 'qris']),
                'created_at' => $randomDate,
                'updated_at' => $randomDate,
            ];
        }

        try {
            Service::insert($servicesToInsert);
            $this->command->info("Services inserted successfully.");

            Transaction::insert($transactionsToInsert);
            $this->command->info("Transactions inserted successfully.");
        } catch (\Exception $e) {
            $this->command->error("Insert Failed: " . $e->getMessage());
        }
    }
}
