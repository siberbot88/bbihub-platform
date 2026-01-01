<?php

use App\Models\User;
use App\Models\Workshop;
use App\Models\Service;
use App\Models\Vehicle;
use Carbon\Carbon;
use Faker\Factory as Faker;

echo "--- INSERT DEBUG START ---\n";

$faker = Faker::create('id_ID');
$user = User::where('name', 'Lina Marlina')->first();
$workshop = Workshop::where('user_uuid', $user->id)->first();
$vehicle = Vehicle::first();

if (!$workshop || !$vehicle) {
    echo "Prerequisites missing (Workshop/Vehicle).\n";
    exit;
}

$serviceId = $faker->uuid;
$serviceData = [
    'id' => $serviceId,
    'code' => 'TEST-' . rand(100, 999),
    'customer_uuid' => $user->id, // Use valid ID
    'vehicle_uuid' => $vehicle->id,
    'workshop_uuid' => $workshop->id,
    'category_service' => 'maintenance',
    'name' => 'Service Regular',
    'description' => 'Dummy service',
    'reason' => 'Maintenance',
    'status' => 'completed',
    'acceptance_status' => 'accepted',
    'type' => 'walk-in',
    'scheduled_date' => Carbon::now()->toDateString(),
    'estimated_time' => Carbon::now()->addHours(2)->toDateString(),
    'created_at' => Carbon::now(),
    'updated_at' => Carbon::now(),
    'technician_name' => 'Tech Debug',
];

echo "Attempting insert...\n";

try {
    Service::insert([$serviceData]);
    echo "Insert SUCCESS!\n";
} catch (\Exception $e) {
    echo "Insert FAILED: " . $e->getMessage() . "\n";
}

echo "--- INSERT DEBUG END ---\n";
