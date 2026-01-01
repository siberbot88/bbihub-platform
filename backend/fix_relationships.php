<?php

use App\Models\User;
use App\Models\Workshop;

echo "--- FIX START ---\n";

$user = User::where('name', 'Lina Marlina')->first();
if (!$user) {
    echo "User Lina Marlina NOT FOUND.\n";
    exit;
}
echo "User: " . $user->name . " | ID: " . $user->id . "\n";

// Find ANY workshop
$workshop = Workshop::first();
if (!$workshop) {
    echo "NO WORKSHOPS in database. Please seed workshops first.\n";
    exit;
}
echo "Target Workshop: " . $workshop->name . " | ID: " . $workshop->id . "\n";

// Update Workshop Ownership
$workshop->user_uuid = $user->id;
$workshop->save();
echo "Updated Workshop owner to Lina Marlina.\n";

// Update User's Workshop Reference
$user->workshop_uuid = $workshop->id;
$user->save();
echo "Updated User workshop_uuid reference.\n";

echo "--- FIX END ---\n";
