<?php

namespace Database\Seeders;

use App\Models\SubscriptionPlan;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class SubscriptionPlanSeeder extends Seeder
{
    /**
     * Seed subscription plans (only if they don't exist)
     */
    public function run(): void
    {
        $plans = [
            [
                'id' => Str::uuid(),
                'code' => 'starter',
                'name' => 'Starter Plan',
                'description' => 'Free plan dengan fitur dasar untuk UMKM bengkel',
                'price_monthly' => 0,
                'price_yearly' => 0,
                'features' => json_encode([
                    'Max 2 Staff',
                    'Basic Analytics',
                    'Invoice Management',
                    'Customer Database',
                ]),
                'is_active' => true,
                'is_recommended' => false,
            ],
            [
                'id' => Str::uuid(),
                'code' => 'bbi_hub_plus',
                'name' => 'BBI Hub Plus',
                'description' => 'Paket premium dengan semua fitur lengkap untuk bengkel profesional',
                'price_monthly' => 120000,
                'price_yearly' => 1440000,
                'features' => json_encode([
                    'Unlimited Staff',
                    'Advanced Analytics & Reports',
                    'Invoice Management',
                    'Customer Database',
                    'Membership Management',
                    'Voucher & Promo',
                    'Multi-branch Support',
                    'Priority Support',
                ]),
                'is_active' => true,
                'is_recommended' => true,
            ],
        ];

        foreach ($plans as $plan) {
            SubscriptionPlan::updateOrCreate(
                ['code' => $plan['code']],
                $plan
            );
        }
    }
}
