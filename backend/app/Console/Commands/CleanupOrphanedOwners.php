<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Models\Workshop;
use Illuminate\Support\Facades\DB;

class CleanupOrphanedOwners extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'cleanup:orphaned-owners {--force : Force deletion without confirmation}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Delete users with role "owner" who do not have any workshops';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('🔍 Scanning for orphaned owners...');

        // Get all user IDs with role 'owner'
        $ownerUserIds = DB::table('model_has_roles')
            ->join('roles', 'roles.id', '=', 'model_has_roles.role_id')
            ->where('roles.name', 'owner')
            ->pluck('model_has_roles.model_id');

        // Get user IDs who actually own workshops
        $workshopOwnerIds = Workshop::distinct('user_uuid')->pluck('user_uuid');

        // Find orphaned owners (have owner role but no workshop)
        $orphanedOwnerIds = $ownerUserIds->diff($workshopOwnerIds);

        if ($orphanedOwnerIds->isEmpty()) {
            $this->info('✅ No orphaned owners found. All owners have workshops!');
            return 0;
        }

        $orphanedOwners = User::whereIn('id', $orphanedOwnerIds)->get();

        $this->warn("⚠️  Found {$orphanedOwners->count()} orphaned owners:");
        $this->table(
            ['ID', 'Name', 'Email', 'Created At'],
            $orphanedOwners->map(fn($user) => [
                substr($user->id, 0, 13) . '...',
                $user->name,
                $user->email,
                $user->created_at->format('Y-m-d H:i')
            ])
        );

        // Confirm deletion unless --force flag is used
        if (!$this->option('force')) {
            if (!$this->confirm('Do you want to DELETE these users permanently?')) {
                $this->info('❌ Deletion cancelled.');
                return 0;
            }
        }

        // Delete orphaned owners
        $deleted = User::whereIn('id', $orphanedOwnerIds)->delete();

        $this->info("✅ Successfully deleted {$deleted} orphaned owner(s)!");
        $this->info("📊 Summary:");
        $this->line("   - Total owners with role: {$ownerUserIds->count()}");
        $this->line("   - Owners with workshops: {$workshopOwnerIds->count()}");
        $this->line("   - Orphaned owners deleted: {$deleted}");
        $this->line("   - Remaining owners: " . ($ownerUserIds->count() - $deleted));

        return 0;
    }
}
