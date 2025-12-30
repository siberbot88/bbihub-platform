<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\CustomerMembership;
use App\Models\User;
use App\Models\Workshop;
use App\Models\Membership;
use App\Models\MembershipTransaction;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Schema;

class MlTestDataSeeder extends Seeder
{
    public function run(): void
    {
        // CLEAR DATA FIRST
        Schema::disableForeignKeyConstraints();
        MembershipTransaction::truncate();
        CustomerMembership::truncate();
        Membership::truncate();
        Schema::enableForeignKeyConstraints();

        $this->command->info('Cleaned old ML data. Generating MRR data only...');

        // 1. Generate Historical MRR Data (Last 12 Months)
        $this->command->info('Generating MRR History for ML Forecast...');

        $dummyOwner = User::firstOrCreate(
            ['email' => 'system@bbihub.com'],
            ['name' => 'System Admin', 'password' => bcrypt('password')]
        );

        $workshop = Workshop::firstOrCreate(
            ['name' => 'BBI Hub Official Store'],
            ['user_id' => $dummyOwner->id]
        );

        $membership = Membership::create([
            'id' => Str::uuid(),
            'workshop_id' => $workshop->id,
            'name' => 'Premium Plan Test',
            'price' => 500000,
            'duration_months' => 1,
            'discount_percentage' => 0,
            'points_multiplier' => 1.0,
            'is_active' => true,
            'benefits' => json_encode(['all_access' => true])
        ]);

        $customerUser = User::firstOrCreate(
            ['email' => 'dummy_member@test.com'],
            ['name' => 'Dummy Member', 'password' => bcrypt('password')]
        );

        $customer = Customer::firstOrCreate(
            ['user_id' => $customerUser->id],
            ['phone' => '081234567890', 'address' => 'Test Address']
        );

        // Generate increasing revenue trend
        for ($i = 12; $i >= 0; $i--) {
            $monthDate = now()->subMonths($i)->startOfMonth();
            $txCount = rand(5, 10) + (12 - $i);

            for ($j = 0; $j < $txCount; $j++) {

                $custMember = CustomerMembership::create([
                    'id' => Str::uuid(),
                    'customer_id' => $customer->id,
                    'membership_id' => $membership->id,
                    'workshop_id' => $workshop->id,
                    'started_at' => $monthDate,
                    'expires_at' => $monthDate->copy()->addMonth(),
                    'status' => 'active',
                    'auto_renew' => false,
                    'total_points' => 0
                ]);

                MembershipTransaction::create([
                    'id' => Str::uuid(),
                    'customer_membership_id' => $custMember->id,
                    'customer_id' => $customer->id,
                    'membership_id' => $membership->id,
                    'amount' => 500000,
                    'payment_method' => 'credit_card',
                    'payment_status' => 'completed',
                    'transaction_date' => $monthDate->copy()->addDays(rand(1, 28)),
                    'paid_at' => $monthDate->copy()->addDays(rand(1, 28)),
                    'payment_type' => 'credit_card',
                    'midtrans_order_id' => 'ORDER-' . Str::uuid()
                ]);
            }
        }

        $this->command->info('MRR Data Generated! (Skipped Churn/Upsell to avoid schema conflicts)');
    }
}
