<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use App\Models\OwnerSubscription;

echo "=== Activating Premium for All Owners ===\n\n";

// Get all users and filter owners through relationship
$users = User::with('workshopOwnership')->get();
$owners = $users->filter(function ($user) {
    return $user->workshopOwnership()->exists();
});

if ($owners->isEmpty()) {
    echo "No owners found.\n";
    die();
}

foreach ($owners as $owner) {
    echo "Owner: {$owner->name} ({$owner->email})\n";

    $subscription = OwnerSubscription::where('owner_uuid', $owner->id)
        ->where('status', 'active')
        ->where('end_date', '>', now())
        ->first();

    if ($subscription) {
        echo "✅ Already PREMIUM - Expires: {$subscription->end_date}\n";
    } else {
        echo "❌ NOT PREMIUM - Activating...\n";

        OwnerSubscription::updateOrCreate(
            ['owner_uuid' => $owner->id],
            [
                'package' => 'yearly',
                'start_date' => now(),
                'end_date' => now()->addYear(),
                'status' => 'active',
                'payment_method' => 'manual',
                'amount' => 0,
            ]
        );

        echo "   ✅ Premium activated until " . now()->addYear()->format('Y-m-d') . "\n";
    }

    echo "\n";
}

echo "=== Done! ===\n";
echo "Please LOGOUT and LOGIN again in mobile app.\n";
