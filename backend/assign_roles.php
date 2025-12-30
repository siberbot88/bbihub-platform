<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "Assigning roles to users without roles...\n";

$users = App\Models\User::all();
$assigned = 0;
$skipped = 0;

foreach ($users as $user) {
    // Skip if already has role
    if ($user->roles()->count() > 0) {
        $skipped++;
        continue;
    }

    // Determine role based on relationships
    $role = null;

    // Check if they own a workshop
    if ($user->workshops()->exists()) {
        $role = 'owner';
    }
    // Check if they are employed (mechanic)
    elseif ($user->employment()->exists()) {
        $role = 'mechanic';
    }
    // Check username patterns
    elseif (str_contains($user->username, 'owner') || str_contains($user->email, 'owner')) {
        $role = 'owner';
    } elseif (str_contains($user->username, 'mechanic') || str_contains($user->email, 'mechanic')) {
        $role = 'mechanic';
    } elseif (str_contains($user->username, 'admin') || str_contains($user->email, 'admin')) {
        $role = 'admin';
    }
    // Default to customer if no other indicators
    else {
        $role = 'customer';
    }

    try {
        $user->assignRole($role);
        $assigned++;

        if ($assigned % 50 == 0) {
            echo "Assigned {$assigned} roles...\n";
        }
    } catch (\Throwable $e) {
        echo "Failed to assign role '{$role}' to {$user->email}: {$e->getMessage()}\n";
    }
}

echo "\n✅ Total: {$users->count()} users\n";
echo "✅ Assigned: {$assigned} roles\n";
echo "✅ Skipped (already has role): {$skipped}\n";
