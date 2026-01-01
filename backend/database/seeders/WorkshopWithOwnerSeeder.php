<?php

namespace Database\Seeders;

use App\Models\OwnerSubscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use App\Models\Workshop;
use Database\Seeders\Helpers\IndonesianDataHelper;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class WorkshopWithOwnerSeeder extends Seeder
{
    private const NUM_WORKSHOPS = 500;
    private const NUM_PAID = 200; // 40% paid subscription
    private const NUM_FREE = 300; // 60% free tier

    /**
     * Create 500 workshops with their owners and subscriptions
     * Data is fully integrated: Owner → Subscription → Workshop
     */
    public function run(): void
    {
        // Get subscription plans
        $planStarter = SubscriptionPlan::where('code', 'starter')->first();
        $planPro = SubscriptionPlan::where('code', 'bbi_hub_plus')->first();

        if (!$planStarter || !$planPro) {
            $this->command->error('Subscription plans not found! Run SubscriptionPlanSeeder first.');
            return;
        }

        $cities = IndonesianDataHelper::cities();
        $workshopCreated = 0;

        // We'll use DB transactions in batches for performance
        $batchSize = 50;
        $batches = ceil(self::NUM_WORKSHOPS / $batchSize);

        for ($batch = 0; $batch < $batches; $batch++) {
            $usersToInsert = [];
            $workshopsToInsert = [];
            $subscriptionsToInsert = [];

            $startIdx = $batch * $batchSize;
            $endIdx = min(($batch + 1) * $batchSize, self::NUM_WORKSHOPS);

            for ($i = $startIdx; $i < $endIdx; $i++) {
                $city = $cities[$i % count($cities)];
                $isPaid = $i < self::NUM_PAID;

                // 1. Create Owner User
                $ownerId = Str::uuid()->toString();
                $ownerName = IndonesianDataHelper::randomName();
                $username = "owner" . str_pad($i + 1, 4, '0', STR_PAD_LEFT);
                $email = "owner" . ($i + 1) . "@demo-bbihub.local";

                $usersToInsert[] = [
                    'id' => $ownerId,
                    'name' => $ownerName,
                    'username' => $username,
                    'email' => $email,
                    'email_verified_at' => now(),
                    'password' => Hash::make('password123'), // Demo password
                    'photo' => "https://ui-avatars.com/api/?name=" . urlencode($ownerName) . "&background=random",
                    'fcm_token' => null,
                    'trial_ends_at' => null,
                    'trial_used' => false,
                    'must_change_password' => false,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];

                // 2. Create Subscription
                $subscriptionId = Str::uuid()->toString();
                // Bias towards recent dates for demo data (20% in last 30 days)
                $daysAgo = rand(1, 100) <= 20 ? rand(0, 30) : rand(31, 365);
                $startsAt = now()->subDays($daysAgo);

                if ($isPaid) {
                    // Paid subscription
                    $expiresAt = $startsAt->copy()->addYear();
                    $subscriptionsToInsert[] = [
                        'id' => $subscriptionId,
                        'user_id' => $ownerId,
                        'plan_id' => $planPro->id,
                        'status' => 'active',
                        'billing_cycle' => 'yearly',
                        'starts_at' => $startsAt,
                        'expires_at' => $expiresAt,
                        'transaction_id' => 'TRX-' . strtoupper(Str::random(10)),
                        'order_id' => 'ORD-' . ($i + 1),
                        'payment_type' => ['qris', 'bank_transfer', 'credit_card'][rand(0, 2)],
                        'gross_amount' => 2990000,
                        'snap_token' => null,
                        'pdf_url' => null,
                        'created_at' => $startsAt,
                        'updated_at' => now(),
                    ];
                } else {
                    // Free subscription
                    $subscriptionsToInsert[] = [
                        'id' => $subscriptionId,
                        'user_id' => $ownerId,
                        'plan_id' => $planStarter->id,
                        'status' => 'active',
                        'billing_cycle' => 'monthly',
                        'starts_at' => $startsAt,
                        'expires_at' => null, // Free never expires
                        'transaction_id' => null,
                        'order_id' => null,
                        'payment_type' => null,
                        'gross_amount' => 0,
                        'snap_token' => null,
                        'pdf_url' => null,
                        'created_at' => $startsAt,
                        'updated_at' => now(),
                    ];
                }

                // 3. Create Workshop
                $workshopId = Str::uuid()->toString();
                $workshopType = IndonesianDataHelper::workshopTypes()[array_rand(IndonesianDataHelper::workshopTypes())];
                $workshopSuffix = IndonesianDataHelper::workshopSuffixes()[array_rand(IndonesianDataHelper::workshopSuffixes())];
                $workshopName = "{$workshopType} {$workshopSuffix} {$city['city']}";
                $workshopCode = 'BKL-' . str_pad($i + 1, 8, '0', STR_PAD_LEFT);

                $workshopsToInsert[] = [
                    'id' => $workshopId,
                    'user_uuid' => $ownerId,
                    'code' => $workshopCode,
                    'name' => $workshopName,
                    'description' => "Bengkel terpercaya di {$city['city']} dengan pelayanan profesional dan teknisi berpengalaman",
                    'address' => IndonesianDataHelper::generateWorkshopAddress($city['city']),
                    'phone' => IndonesianDataHelper::randomPhone(),
                    'email' => "workshop" . ($i + 1) . "@demo-bbihub.local",
                    'photo' => 'https://placehold.co/600x400/D72B1C/FFFFFF?text=' . urlencode(substr($workshopName, 0, 20)),
                    'city' => $city['city'],
                    'province' => $city['province'],
                    'country' => 'Indonesia',
                    'postal_code' => $city['postal'],
                    'latitude' => $city['lat'] + (rand(-100, 100) / 1000),
                    'longitude' => $city['lon'] + (rand(-100, 100) / 1000),
                    'maps_url' => "https://maps.google.com/?q={$city['lat']},{$city['lon']}",
                    'opening_time' => '08:00:00',
                    'closing_time' => ['17:00:00', '18:00:00', '19:00:00'][rand(0, 2)],
                    'operational_days' => ['Senin-Sabtu', 'Senin-Jumat', 'Senin-Minggu'][rand(0, 2)],
                    'is_active' => true,
                    'status' => 'active',
                    'created_at' => $startsAt,
                    'updated_at' => now(),
                ];

                $workshopCreated++;
            }

            // Batch insert untuk performance
            DB::table('users')->insert($usersToInsert);
            DB::table('owner_subscriptions')->insert($subscriptionsToInsert);
            DB::table('workshops')->insert($workshopsToInsert);
        }

        $this->command->info("✓ Created {$workshopCreated} workshops");
        $this->command->info("  → " . self::NUM_PAID . " with paid subscription (BBI Hub Plus)");
        $this->command->info("  → " . self::NUM_FREE . " with free plan (Starter)");
    }
}
