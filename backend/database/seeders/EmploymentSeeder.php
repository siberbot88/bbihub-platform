<?php

namespace Database\Seeders;

use App\Models\Employment;
use App\Models\User;
use App\Models\Workshop;
use Database\Seeders\Helpers\IndonesianDataHelper;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class EmploymentSeeder extends Seeder
{
    /**
     * Create staff for each workshop:
     * - 1 admin per workshop
     * - 2 mechanics per workshop
     * Total: 500 admins + 1000 mechanics = 1500 staff users
     */
    public function run(): void
    {
        $workshops = Workshop::all();
        // IMPORTANT: Keep code sequential across ALL batches
        $employmentCode = 1; // Will increment: ST00001, ST00002, etc.
        $totalStaff = 0;

        $batchSize = 50;

        foreach ($workshops->chunk($batchSize) as $workshopChunk) {
            $usersToInsert = [];
            $employmentsToInsert = [];

            foreach ($workshopChunk as $workshop) {
                // 1. Create 1 Admin
                list($adminUser, $adminEmployment) = $this->createStaff(
                    $workshop,
                    'admin',
                    $employmentCode++, // Increment AFTER use
                    $totalStaff++
                );
                $usersToInsert[] = $adminUser;
                $employmentsToInsert[] = $adminEmployment;

                // 2. Create 2 Mechanics
                for ($m = 0; $m < 2; $m++) {
                    list($mechUser, $mechEmployment) = $this->createStaff(
                        $workshop,
                        'mechanic',
                        $employmentCode++, // Increment AFTER use
                        $totalStaff++
                    );
                    $usersToInsert[] = $mechUser;
                    $employmentsToInsert[] = $mechEmployment;
                }
            }

            // Batch insert
            DB::table('users')->insert($usersToInsert);
            DB::table('employments')->insert($employmentsToInsert);
        }

        $this->command->info("✓ Created {$totalStaff} staff members");
        $this->command->info("  → " . ($totalStaff / 3) . " admins");
        $this->command->info("  → " . ($totalStaff / 3 * 2) . " mechanics");
    }

    /**
     * Create staff user and employment record
     */
    private function createStaff(Workshop $workshop, string $role, int $code, int $index): array
    {
        $userId = Str::uuid()->toString();
        $name = IndonesianDataHelper::randomName();
        $username = $role . str_pad($index + 1, 4, '0', STR_PAD_LEFT);
        $email = $role . ($index + 1) . "@demo-bbihub.local";

        // User data
        $user = [
            'id' => $userId,
            'name' => $name,
            'username' => $username,
            'email' => $email,
            'email_verified_at' => now(),
            'password' => Hash::make('password123'), // Demo password
            'photo' => "https://ui-avatars.com/api/?name=" . urlencode($name) . "&background=random",
            'fcm_token' => null,
            'trial_ends_at' => null,
            'trial_used' => false,
            'must_change_password' => false,
            'created_at' => $workshop->created_at,
            'updated_at' => now(),
        ];

        // Employment data
        $employmentId = Str::uuid()->toString();
        $employmentCode = 'SE' . str_pad($code, 7, '0', STR_PAD_LEFT);

        if ($role === 'admin') {
            $specialist = null;
            $jobdesk = IndonesianDataHelper::adminJobdesks()[array_rand(IndonesianDataHelper::adminJobdesks())];
        } else {
            $specialist = IndonesianDataHelper::mechanicSpecialists()[array_rand(IndonesianDataHelper::mechanicSpecialists())];
            $jobdesk = 'Teknisi ' . $specialist;
        }

        $employment = [
            'id' => $employmentId,
            'user_uuid' => $userId,
            'workshop_uuid' => $workshop->id,
            'code' => $employmentCode,
            'specialist' => $specialist,
            'jobdesk' => $jobdesk,
            'status' => 'active',
            'created_at' => $workshop->created_at,
            'updated_at' => now(),
        ];

        return [$user, $employment];
    }
}
