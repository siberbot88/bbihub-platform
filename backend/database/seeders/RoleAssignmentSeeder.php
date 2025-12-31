<?php

namespace Database\Seeders;

use App\Models\Employment;
use App\Models\User;
use App\Models\Workshop;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;

class RoleAssignmentSeeder extends Seeder
{
    /**
     * Assign Spatie roles to all users
     * - Owners → 'owner' role
     * - Admin staff → 'admin' role
     * - Mechanic staff → 'mechanic' role
     */
    public function run(): void
    {
        // Get roles (assuming they were created by base db:seed)
        $roleOwner = Role::where('name', 'owner')->where('guard_name', 'sanctum')->first();
        $roleAdmin = Role::where('name', 'admin')->where('guard_name', 'sanctum')->first();
        $roleMechanic = Role::where('name', 'mechanic')->where('guard_name', 'sanctum')->first();

        if (!$roleOwner || !$roleAdmin || !$roleMechanic) {
            $this->command->warn('Roles not found! Creating them...');
            $this->createRoles();

            $roleOwner = Role::where('name', 'owner')->where('guard_name', 'sanctum')->first();
            $roleAdmin = Role::where('name', 'admin')->where('guard_name', 'sanctum')->first();
            $roleMechanic = Role::where('name', 'mechanic')->where('guard_name', 'sanctum')->first();
        }

        $ownerCount = 0;
        $adminCount = 0;
        $mechanicCount = 0;

        // 1. ASSIGN OWNER ROLE
        // Users who have workshops are owners
        // 1. ASSIGN OWNER ROLE
        // Users who have workshops are owners
        $this->command->info('Assigning owner roles...');
        $owners = User::whereHas('workshops')->get();

        foreach ($owners as $owner) {
            if (!$owner->hasRole('owner')) {
                $owner->assignRole($roleOwner);
                $ownerCount++;
            }
        }

        // 2. ASSIGN ADMIN & MECHANIC ROLES
        // Based on employment jobdesk
        // 2. ASSIGN ADMIN & MECHANIC ROLES
        // Based on employment jobdesk
        $this->command->info('Assigning admin & mechanic roles...');
        $employments = Employment::with('user')->get();

        foreach ($employments as $employment) {
            if (!$employment->user) {
                continue;
            }

            $user = $employment->user;

            // Determine role based on jobdesk
            $jobdesk = strtolower($employment->jobdesk ?? '');

            if (
                str_contains($jobdesk, 'admin') ||
                str_contains($jobdesk, 'kasir') ||
                str_contains($jobdesk, 'customer service') ||
                str_contains($jobdesk, 'supervisor') ||
                str_contains($jobdesk, 'koordinator')
            ) {
                // Admin role
                if (!$user->hasRole('admin')) {
                    $user->assignRole($roleAdmin);
                    $adminCount++;
                }
            } else {
                // Mechanic role (default for technicians)
                if (!$user->hasRole('mechanic')) {
                    $user->assignRole($roleMechanic);
                    $mechanicCount++;
                }
            }
        }

        $this->command->newLine();
        $this->command->info("✓ Assigned {$ownerCount} owner roles");
        $this->command->info("✓ Assigned {$adminCount} admin roles");
        $this->command->info("✓ Assigned {$mechanicCount} mechanic roles");
    }

    /**
     * Create roles if they don't exist
     */
    private function createRoles(): void
    {
        $roles = ['owner', 'admin', 'mechanic'];

        foreach ($roles as $roleName) {
            Role::firstOrCreate(
                ['name' => $roleName, 'guard_name' => 'sanctum']
            );
        }

        $this->command->info('✓ Created missing roles');
    }
}
