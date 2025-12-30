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
    public function run(): void
    {
        try {
            $this->command->info('Starting Owner Analytics Seeder...');

            // Ensure Role exists
            if (!Role::where('name', 'owner')->exists()) {
                Role::create(['name' => 'owner', 'guard_name' => 'sanctum']);
            }

            // 1. Subscription Plan
            $plan = SubscriptionPlan::firstOrCreate(
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

            // 2. MRR (5 Active Owners)
            $this->command->info('Seeding MRR Data (5 Users)...');
            User::factory()->count(5)->create()->each(function ($user) use ($plan) {
                $user->assignRole('owner');

                OwnerSubscription::create([
                    'id' => Str::uuid(),
                    'user_id' => $user->id,
                    'plan_id' => $plan->id,
                    'status' => 'active',
                    'billing_cycle' => 'monthly',
                    'starts_at' => now()->subDays(rand(1, 20)),
                    'expires_at' => now()->addDays(20),
                    'gross_amount' => 120000,
                    'payment_type' => 'credit_card'
                ]);
            });

            // 3. Churn (1 Expired Owner)
            $this->command->info('Seeding Churn Data (1 Expired User)...');
            $churnUser = User::factory()->create([
                'name' => 'Churn Candidate',
                'email' => 'churn_final_' . Str::random(5) . '@test.com'
            ]);
            $churnUser->assignRole('owner');

            OwnerSubscription::create([
                'id' => Str::uuid(),
                'user_id' => $churnUser->id,
                'plan_id' => $plan->id,
                'status' => 'expired',
                'billing_cycle' => 'monthly',
                'starts_at' => now()->subDays(40),
                'expires_at' => now()->subDays(5),
                'gross_amount' => 120000,
                'payment_type' => 'credit_card'
            ]);

            // 4. Upsell (1 High Volume Owner, No Active Sub)
            $this->command->info('Seeding Upsell Data...');

            $upsellUser = User::factory()->create([
                'name' => 'Upsell Target',
                'email' => 'upsell_final_' . Str::random(5) . '@test.com'
            ]);
            $upsellUser->assignRole('owner');

            // Workshop
            $workshop = Workshop::create([
                'id' => Str::uuid(),
                'user_uuid' => $upsellUser->id,
                'code' => 'WS-UP-' . Str::random(5),
                'name' => 'Upsell Workshop',
                'status' => 'active',
                'is_active' => true,
                'opening_time' => '08:00',
                'closing_time' => '17:00',
                'operational_days' => 'Mon-Fri'
            ]);

            // Mechanic (Required for Service)
            $mechUser = User::factory()->create(['name' => 'Mechanic One']);
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

            for ($i = 0; $i < 15; $i++) {
                $service = Service::create([
                    'id' => Str::uuid(),
                    'workshop_uuid' => $workshop->id,
                    'customer_uuid' => $customer->id,
                    'vehicle_uuid' => $vehicle->id,
                    'mechanic_uuid' => $mechanic->id,
                    'status' => 'completed',
                    'created_at' => now()->subDays(rand(1, 25)),
                    'code' => 'WO-' . Str::random(5),
                    'name' => 'Service ' . $i,
                    'category_service' => 'ringan',
                    'odometer' => 1000 + ($i * 100)
                ]);

                // Create Invoice (Required by Transaction?)
                // Assuming Invoice Model exists and factory
                // Or just create manually
                $invoice = \App\Models\Invoice::create([
                    'id' => Str::uuid(),
                    'code' => 'INV-' . Str::random(5),
                    'workshop_uuid' => $workshop->id,
                    'customer_uuid' => $customer->id,
                    'vehicle_uuid' => $vehicle->id,
                    'service_uuid' => $service->id,
                    'user_uuid' => $upsellUser->id, // Admin/Cashier
                    'date' => now(),
                    'due_date' => now()->addDays(1),
                    'total_amount' => 150000,
                    'status' => 'paid',
                    'payment_method' => 'cash'
                ]);

                // Transaction
                Transaction::create([
                    'id' => Str::uuid(),
                    'service_uuid' => $service->id,
                    'workshop_uuid' => $workshop->id,
                    'customer_uuid' => $customer->id,
                    'invoice_uuid' => $invoice->id,
                    'status' => 'success',
                    'amount' => 150000,
                    'payment_method' => 'cash',
                    'created_at' => $service->created_at
                ]);
            }

            $this->command->info('✅ Owner Analytics Data Seeded Successfully!');

        } catch (\Exception $e) {
            file_put_contents('seeder_error.txt', $e->getMessage());
            $this->command->error("SEEDER ERROR logged to seeder_error.txt");
        }
    }
}
