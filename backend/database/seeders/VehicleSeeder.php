<?php

namespace Database\Seeders;

use App\Models\Customer;
use Database\Seeders\Helpers\IndonesianDataHelper;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class VehicleSeeder extends Seeder
{
    /**
     * Create vehicles for all customers
     * Each customer has 1-2 vehicles
     * Total: ~40,000 vehicles
     */
    public function run(): void
    {
        // $customers = Customer::all(); // Removed to save memory
        $vehicleCode = 1;
        $totalVehicles = 0;

        $batchSize = 10;

        // Use chunkById for better memory management with large datasets
        Customer::chunkById($batchSize, function ($customerChunk) use (&$totalVehicles, &$vehicleCode) {
            $vehiclesToInsert = [];

            foreach ($customerChunk as $customer) {
                $numVehicles = rand(1, 2); // 1-2 vehicles per customer

                for ($v = 0; $v < $numVehicles; $v++) {
                    // 70% motor, 30% mobil
                    $isMotor = rand(1, 100) <= 70;

                    if ($isMotor) {
                        $brands = IndonesianDataHelper::motorcycleBrands();
                        $brandName = array_rand($brands);
                        $models = $brands[$brandName];
                        $model = $models[array_rand($models)];
                        $category = 'Motor';
                        $type = 'Matic'; // or 'Manual', 'Sport', etc.
                    } else {
                        $brands = IndonesianDataHelper::carBrands();
                        $brandName = array_rand($brands);
                        $models = $brands[$brandName];
                        $model = $models[array_rand($models)];
                        $category = 'Mobil';
                        $type = ['MPV', 'SUV', 'Sedan', 'Hatchback'][rand(0, 3)];
                    }

                    $vehicleId = Str::uuid()->toString();
                    $code = 'VEH-' . str_pad($vehicleCode++, 6, '0', STR_PAD_LEFT);
                    $name = "{$brandName} {$model}";
                    $year = rand(2010, 2024);
                    $color = IndonesianDataHelper::vehicleColors()[array_rand(IndonesianDataHelper::vehicleColors())];

                    // Get plate code from customer's location (we'll use Jakarta as fallback)
                    $plateCode = 'B'; // Default to Jakarta plate
                    $plateNumber = IndonesianDataHelper::randomPlateNumber($plateCode);

                    // Odometer realistic based on year
                    $vehicleAge = 2025 - $year;
                    $odometerMin = $vehicleAge * 5000; // 5000 km/year minimum
                    $odometerMax = $vehicleAge * 25000; // 25000 km/year maximum
                    $odometer = rand($odometerMin, $odometerMax);

                    $vehiclesToInsert[] = [
                        'id' => $vehicleId,
                        'customer_uuid' => $customer->id,
                        'code' => $code,
                        'name' => $name,
                        'type' => $type,
                        'category' => $category,
                        'brand' => $brandName,
                        'model' => $model,
                        'year' => $year,
                        'color' => $color,
                        'plate_number' => $plateNumber,
                        'odometer' => $odometer,
                        'created_at' => $customer->created_at,
                        'updated_at' => now(),
                    ];

                    $totalVehicles++;
                }
            }

            // Batch insert
            if (!empty($vehiclesToInsert)) {
                DB::table('vehicles')->insert($vehiclesToInsert);
            }
        });

        $this->command->info("✓ Created {$totalVehicles} vehicles");
        $this->command->info("  → 70% motorcycles, 30% cars");
        $this->command->info("  → 1-2 vehicles per customer");
    }
}
