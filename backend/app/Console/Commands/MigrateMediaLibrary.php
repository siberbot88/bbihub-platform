<?php

namespace App\Console\Commands;

use App\Models\Service;
use App\Models\User;
use App\Models\Workshop;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;
use Exception;

class MigrateMediaLibrary extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'media:migrate-legacy';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Migrate legacy string paths to Spatie Media Library';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Starting Media Migration...');

        $this->migrateUsers();
        $this->migrateWorkshops();
        $this->migrateServices();

        $this->info('All migrations completed!');
    }

    private function migrateUsers()
    {
        $this->info('Migrating Users...');
        $users = User::whereNotNull('photo')->get();
        $bar = $this->output->createProgressBar($users->count());

        foreach ($users as $user) {
            try {
                // Skip if already has media
                if ($user->getFirstMedia('profile_photo')) {
                    $bar->advance();
                    continue;
                }

                $path = $user->photo;

                // Skip external URLs (social login, placeholders)
                if (str_starts_with($path, 'http')) {
                    $bar->advance();
                    continue;
                }

                if (Storage::disk('public')->exists($path)) {
                    $fullPath = Storage::disk('public')->path($path);
                    $user->addMedia($fullPath)
                        ->preservingOriginal()
                        ->toMediaCollection('profile_photo');
                } else {
                    $this->warn("\nFile not found for User ID {$user->id}: {$path}");
                }
            } catch (Exception $e) {
                $this->error("\nError User ID {$user->id}: " . $e->getMessage());
            }
            $bar->advance();
        }
        $bar->finish();
        $this->newLine();
    }

    private function migrateWorkshops()
    {
        $this->info('Migrating Workshops...');
        $workshops = Workshop::whereNotNull('photo')->get();
        $bar = $this->output->createProgressBar($workshops->count());

        foreach ($workshops as $workshop) {
            try {
                if ($workshop->getFirstMedia('workshop_photo')) {
                    $bar->advance();
                    continue;
                }

                $path = $workshop->photo;

                if (str_starts_with($path, 'http')) {
                    $bar->advance();
                    continue;
                }

                if (Storage::disk('public')->exists($path)) {
                    $fullPath = Storage::disk('public')->path($path);
                    $workshop->addMedia($fullPath)
                        ->preservingOriginal()
                        ->toMediaCollection('workshop_photo');
                } else {
                    $this->warn("\nFile not found for Workshop ID {$workshop->id}: {$path}");
                }
            } catch (Exception $e) {
                $this->error("\nError Workshop ID {$workshop->id}: " . $e->getMessage());
            }
            $bar->advance();
        }
        $bar->finish();
        $this->newLine();
    }

    private function migrateServices()
    {
        $this->info('Migrating Services...');
        $services = Service::whereNotNull('image_path')->get();
        $bar = $this->output->createProgressBar($services->count());

        foreach ($services as $service) {
            try {
                if ($service->getFirstMedia('service_image')) {
                    $bar->advance();
                    continue;
                }

                $path = $service->image_path;

                if (str_starts_with($path, 'http')) {
                    $bar->advance();
                    continue;
                }

                if (Storage::disk('public')->exists($path)) {
                    $fullPath = Storage::disk('public')->path($path);
                    $service->addMedia($fullPath)
                        ->preservingOriginal()
                        ->toMediaCollection('service_image');
                } else {
                    $this->warn("\nFile not found for Service ID {$service->id}: {$path}");
                }
            } catch (Exception $e) {
                $this->error("\nError Service ID {$service->id}: " . $e->getMessage());
            }
            $bar->advance();
        }
        $bar->finish();
        $this->newLine();
    }
}
