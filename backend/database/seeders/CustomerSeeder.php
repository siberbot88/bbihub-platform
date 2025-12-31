<?php

namespace Database\Seeders;

use App\Models\Workshop;
use Database\Seeders\Helpers\IndonesianDataHelper;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class CustomerSeeder extends Seeder
{
    private const CUSTOMERS_PER_WORKSHOP_MIN = 40;
    private const CUSTOMERS_PER_WORKSHOP_MAX = 80;

    /**
     * Create customers distributed across all workshops
     * Average 60 customers per workshop = ~30,000 total
     */
    public function run(): void
    {
        $workshops = Workshop::all();
        $customerCode = 1;
        $totalCustomers = 0;

        foreach ($workshops as $workshop) {
            $numCustomers = rand(self::CUSTOMERS_PER_WORKSHOP_MIN, self::CUSTOMERS_PER_WORKSHOP_MAX);
            $customersToInsert = [];

            for ($i = 0; $i < $numCustomers; $i++) {
                $customerId = Str::uuid()->toString();
                $customerName = IndonesianDataHelper::randomName();
                $code = 'CUST-' . str_pad($customerCode++, 6, '0', STR_PAD_LEFT);

                // Generate email (required field)
                $emailName = strtolower(str_replace(' ', '.', $customerName));
                $email = $emailName . rand(100, 999) . '@gmail.com';

                $customersToInsert[] = [
                    'id' => $customerId,
                    'code' => $code,
                    'name' => $customerName,
                    'phone' => IndonesianDataHelper::randomPhone(),
                    'address' => IndonesianDataHelper::generateCustomerAddress($workshop->city),
                    'email' => $email, // Required field
                    'created_at' => now()->subDays(rand(1, 365)),
                    'updated_at' => now(),
                ];

                $totalCustomers++;
            }

            // Batch insert per workshop
            DB::table('customers')->insert($customersToInsert);
        }

        $this->command->info("✓ Created {$totalCustomers} customers");
        $this->command->info("  → Distributed across 500 workshops");
        $this->command->info("  → Average " . round($totalCustomers / 500) . " customers per workshop");
    }
}
