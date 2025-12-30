<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Customer;
use App\Models\Vehicle;
use App\Models\Service;
use App\Models\Transaction;
use App\Models\Workshop;
use Carbon\Carbon;

class ClvTestDataSeeder extends Seeder
{
    /**
     * Seed varied transaction data for CLV scatter chart visualization
     */
    public function run(): void
    {
        $this->command->info('Creating CLV Test Data...');

        $workshops = Workshop::limit(5)->get();
        if ($workshops->isEmpty()) {
            $this->command->error('No workshops found. Run PerformanceTestSeeder first.');
            return;
        }

        // Define customer segments with different transaction patterns
        $segments = [
            // Champions: High frequency (10-15 trx), High value (500k-1M per trx)
            'champions' => ['count' => 3, 'freq' => [10, 15], 'amount' => [500000, 1000000]],

            // Loyal: Medium-High frequency (7-10 trx), Medium value (200k-500k)
            'loyal' => ['count' => 4, 'freq' => [7, 10], 'amount' => [200000, 500000]],

            // Potential: Low-Medium frequency (3-5 trx), High value (400k-800k)
            'potential' => ['count' => 4, 'freq' => [3, 5], 'amount' => [400000, 800000]],

            // New: Very low frequency (1-2 trx), Medium value (150k-400k)
            'new' => ['count' => 5, 'freq' => [1, 2], 'amount' => [150000, 400000]],

            // Low Value: Medium frequency (5-8 trx), Low value (50k-150k)
            'low_value' => ['count' => 4, 'freq' => [5, 8], 'amount' => [50000, 150000]],

            // At Risk: Low frequency (2-4 trx), Medium value (200k-400k)
            'at_risk' => ['count' => 3, 'freq' => [2, 4], 'amount' => [200000, 400000]],
        ];

        foreach ($segments as $segmentName => $config) {
            for ($i = 0; $i < $config['count']; $i++) {
                $customer = Customer::factory()->create();
                $vehicle = Vehicle::factory()->create(['customer_uuid' => $customer->id]);

                $numTransactions = rand($config['freq'][0], $config['freq'][1]);
                $workshop = $workshops->random();

                for ($t = 0; $t < $numTransactions; $t++) {
                    // Create service first
                    $service = Service::factory()->create([
                        'workshop_uuid' => $workshop->id,
                        'customer_uuid' => $customer->id,
                        'vehicle_uuid' => $vehicle->id,
                        'status' => 'completed',
                        'reason' => null, // Allow null for completed services
                        'created_at' => Carbon::now()->subDays(rand(1, 180)),
                    ]);

                    // Create successful transaction
                    Transaction::factory()->create([
                        'service_uuid' => $service->id,
                        'customer_uuid' => $customer->id,
                        'workshop_uuid' => $workshop->id,
                        'amount' => rand($config['amount'][0], $config['amount'][1]),
                        'status' => 'success',
                        'created_at' => $service->created_at,
                    ]);
                }

                $this->command->info("Created {$segmentName} customer: {$customer->name} ({$numTransactions} transactions)");
            }
        }

        $this->command->info('CLV Test Data Seeding Completed.');
    }
}
