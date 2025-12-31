<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class MassiveDataSeeder extends Seeder
{
    /**
     * Seed the application's database with massive realistic data.
     * 
     * This seeder creates 500 workshops with complete integrated data:
     * - 500 owners (1 per workshop)
     * - 500 admins (1 per workshop)
     * - 1000 mechanics (2 per workshop)
     * - ~30,000 customers
     * - ~40,000 vehicles
     * - ~15,000 services (with realistic status distribution)
     * - ~10,000 invoices (for completed services)
     * - ~10,000 transactions (matching invoices)
     */
    public function run(): void
    {
        $this->command->info('🚀 Starting BBIHUB Massive Data Seeding...');
        $this->command->warn('⚠️  This will take 3-7 minutes. Please wait...');
        $this->command->newLine();

        $startTime = microtime(true);

        // Disable foreign key checks for faster insertion
        Schema::disableForeignKeyConstraints();

        try {
            // Step 1: Subscription Plans (if not exists)
            $this->command->info('📋 Creating subscription plans...');
            $this->call(SubscriptionPlanSeeder::class);

            // Step 2: Owners & Workshops (500 workshops)
            $this->command->info('👤 Creating 500 workshops with owners...');
            $this->call(WorkshopWithOwnerSeeder::class);

            // Step 3: Employment (Staff: Admin & Mechanics)
            $this->command->info('👥 Creating staff (1500 admins + mechanics)...');
            $this->call(EmploymentSeeder::class);

            // Step 4: Customers & Vehicles
            $this->command->info('👨‍👩‍👧‍👦 Creating customers (~30,000)...');
            $this->call(CustomerSeeder::class);

            $this->command->info('🚗 Creating vehicles (~40,000)...');
            $this->call(VehicleSeeder::class);

            // Step 5: Services (with realistic distribution)
            $this->command->info('🔧 Creating services (~15,000)...');
            $this->call(ServiceSeeder::class);

            // Step 6: Invoices & Transactions (for completed services)
            $this->command->info('💰 Creating invoices & transactions (~10,000)...');
            $this->call(InvoiceTransactionSeeder::class);

            // Step 7: Feedback (for completed transactions)
            $this->command->info('⭐ Creating feedback (~6,000)...');
            $this->call(FeedbackSeeder::class);

            // Step 8: Role assignments (Spatie)
            $this->command->info('🔐 Assigning roles to users...');
            $this->call(RoleAssignmentSeeder::class);

        } finally {
            // Re-enable foreign key checks
            Schema::enableForeignKeyConstraints();
        }

        $endTime = microtime(true);
        $duration = round($endTime - $startTime, 2);
        $minutes = floor($duration / 60);
        $seconds = $duration - ($minutes * 60);

        $this->command->newLine();
        $this->command->info("✅ Seeding completed in {$minutes}m " . round($seconds) . "s");
        $this->command->newLine();

        // Show statistics
        $this->showStatistics();
    }

    /**
     * Display seeding statistics
     */
    private function showStatistics(): void
    {
        $this->command->info('📊 Database Statistics:');
        $this->command->table(
            ['Entity', 'Count'],
            [
                ['Workshops', DB::table('workshops')->count()],
                ['Users (All)', DB::table('users')->count()],
                ['Employments', DB::table('employments')->count()],
                ['Customers', DB::table('customers')->count()],
                ['Vehicles', DB::table('vehicles')->count()],
                ['Services', DB::table('services')->count()],
                ['Invoices', DB::table('invoices')->count()],
                ['Transactions', DB::table('transactions')->count()],
            ]
        );

        $this->command->newLine();
        $this->command->info('🎯 Service Status Distribution:');
        $serviceStats = DB::table('services')
            ->select('status', DB::raw('COUNT(*) as count'))
            ->groupBy('status')
            ->get();

        $statusTable = [];
        foreach ($serviceStats as $stat) {
            $statusTable[] = [$stat->status, $stat->count];
        }
        $this->command->table(['Status', 'Count'], $statusTable);

        $this->command->newLine();
        $this->command->info('✅ All data has been seeded successfully!');
        $this->command->info('💡 Tip: Check data relationships to ensure integration is correct.');
    }
}
