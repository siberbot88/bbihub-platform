<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use App\Models\User;
use App\Models\SubscriptionPlan;
use App\Models\OwnerSubscription;
use App\Models\Workshop;
use App\Models\Customer;
use App\Models\Vehicle;
use App\Models\Service;
use App\Models\Transaction;
use App\Models\Employment;
use Spatie\Permission\Models\Role;

class OwnerAnalyticsSeeder extends Seeder
{
    private $plan;

    public function run(): void
    {
        try {
            $this->command->info('Starting Owner Analytics Seeder...');

            $this->ensureRoleExists();
            $this->seedSubscriptionPlan();
            $this->seedMrrData(); // Section 2
            $this->seedChurnData(); // Section 3
            $this->seedUpsellData(); // Section 4

            $this->command->info('✅ Owner Analytics Data Seeded Successfully!');

        } catch (\Exception $e) {
            file_put_contents('seeder_error.txt', $e->getMessage());
            $this->command->error("SEEDER ERROR logged to seeder_error.txt");
        }
    }

    private function ensureRoleExists()
    {
        if (!Role::where('name', 'owner')->exists()) {
            Role::create(['name' => 'owner', 'guard_name' => 'sanctum']);
        }
    }

    private function seedSubscriptionPlan()
    {
        $this->plan = SubscriptionPlan::firstOrCreate(
            ['code' => 'bbi_hub_plus'],
            [
                'id' => Str::uuid(),
                'name' => 'BBI HUB Plus',
                'description' => 'ML Analytics Plan',
                'price_monthly' => 120000,
                'price_yearly' => 1440000,
                'features' => json_encode(['analytics' => true]),
                'is_active' => true,
                'is_recommended' => true
            ]
        );
    }

    private function seedMrrData()
    {
        $this->command->info('Seeding MRR Data (12 Months History)...');

        foreach (range(1, 12) as $month) {
            $userCount = rand(0, 1);
            if ($month == 6 || $month == 12)
                $userCount = 2;

            if ($userCount > 0) {
                User::factory()->count($userCount)->state(function (array $attributes) {
                    return [
                        'email' => 'owner_mrr_' . Str::random(8) . '_' . uniqid() . '@generated.com',
                        'username' => 'owner_' . Str::random(8),
                    ];
                })->create()->each(function ($user) use ($month) {
                    $user->assignRole('owner');
                    $this->createSubscriptionForUser($user, $month);
                });
            }
        }
    }

    private function createSubscriptionForUser($user, $month)
    {
        $year = 2025;
        $startDate = \Carbon\Carbon::create($year, $month, rand(1, 28), 10, 0, 0);
        $amount = 120000;

        OwnerSubscription::create([
            'id' => Str::uuid(),
            'user_id' => $user->id,
            'plan_id' => $this->plan->id,
            'status' => 'active',
            'billing_cycle' => 'monthly',
            'starts_at' => $startDate,
            'expires_at' => $startDate->copy()->addMonth(),
            'gross_amount' => $amount,
            'payment_type' => 'credit_card'
        ]);
    }

    private function seedChurnData()
    {
        $this->command->info('Seeding Churn Data (1 Expired User)...');
        $churnUser = User::factory()->create([
            'name' => 'Churn Candidate',
            'email' => 'churn_final_' . Str::random(5) . '@test.com'
        ]);
        $churnUser->assignRole('owner');

        OwnerSubscription::create([
            'id' => Str::uuid(),
            'user_id' => $churnUser->id,
            'plan_id' => $this->plan->id,
            'status' => 'expired',
            'billing_cycle' => 'monthly',
            'starts_at' => now()->subDays(40),
            'expires_at' => now()->subDays(5),
            'gross_amount' => 120000,
            'payment_type' => 'credit_card'
        ]);
    }

    private function seedUpsellData()
    {
        $this->command->info('Seeding Upsell Data...');

        $upsellUser = User::factory()->create([
            'name' => 'Upsell Target',
            'email' => 'upsell_final_' . Str::random(5) . '@test.com'
        ]);
        $upsellUser->assignRole('owner');

        // Workshop
        $workshop = Workshop::factory()->create([
            'user_uuid' => $upsellUser->id,
            'code' => 'WS-UP-' . Str::random(5),
            'name' => 'Upsell Workshop',
            'description' => 'A workshop with high transaction volume but no subscription.',
            'status' => 'active',
            'is_active' => true,
        ]);

        // Mechanic
        $mechUser = User::factory()->state(function (array $attributes) {
            return [
                'email' => 'mechanic_' . Str::random(8) . '@generated.com',
            ];
        })->create(['name' => 'Mechanic One']);

        $mechanic = Employment::create([
            'id' => Str::uuid(),
            'workshop_uuid' => $workshop->id,
            'user_uuid' => $mechUser->id,
            'code' => 'MECH-' . Str::random(3),
            'specialist' => 'General',
            'status' => 'active'
        ]);

        // Customer & Vehicle
        $customer = Customer::factory()->create();
        $vehicle = Vehicle::factory()->create(['customer_uuid' => $customer->id]);

        $this->generateTransactionsForUpsell($workshop, $customer, $vehicle, $mechanic, $upsellUser);
    }

    private function generateTransactionsForUpsell($workshop, $customer, $vehicle, $mechanic, $upsellUser)
    {
        for ($i = 0; $i < 15; $i++) {
            // Ensure some services are for TODAY (to test Dashboard "Hari Ini")
            if ($i < 5) {
                $createdAt = now();
                $scheduledDate = now();
                $status = 'completed';
                if ($i == 0)
                    $status = 'pending';
                if ($i == 1)
                    $status = 'in progress';
            } else {
                $createdAt = now()->subDays(rand(1, 25));
                $scheduledDate = $createdAt;
                $status = 'completed';
            }

            $service = Service::factory()->create([
                'workshop_uuid' => $workshop->id,
                'customer_uuid' => $customer->id,
                'vehicle_uuid' => $vehicle->id,
                'mechanic_uuid' => $mechanic->id,
                'status' => $status,
                'acceptance_status' => 'accepted',
                'created_at' => $createdAt,
                'scheduled_date' => $scheduledDate,
                'completed_at' => ($status === 'completed' || $status === 'lunas') ? $createdAt->copy()->addHours(2) : null,
                'code' => 'WO-' . Str::random(5),
                'name' => 'Service ' . $i,
                'reason' => 'lainnya',
                'reason_description' => 'Routine Checkup',
                'feedback_mechanic' => 'Good',
                'category_service' => 'ringan',
            ]);

            // Create transaction first (since invoice references it)
            $transaction = Transaction::factory()->create([
                'service_uuid' => $service->id,
                'workshop_uuid' => $workshop->id,
                'customer_uuid' => $customer->id,
                'status' => 'success',
                'amount' => 150000,
                'payment_method' => 'cash',
                'created_at' => $createdAt
            ]);

            // Invoice references transaction
            $invoice = \App\Models\Invoice::factory()->create([
                'transaction_uuid' => $transaction->id,
                'code' => 'INV-' . Str::random(5),
                'amount' => 150000,
                'due_date' => $createdAt->copy()->addDays(1),
                'paid_at' => $createdAt->copy()->addHours(3),
            ]);
        }
    }
}
