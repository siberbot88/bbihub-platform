<?php
$u = \App\Models\User::where('email', 'fajar.bengkel88@gmail.com')->first();
if ($u && $u->workshops->isNotEmpty()) {
    echo "Workshop Status: " . $u->workshops->first()->status . "\n";
} else {
    echo "Workshop not found or User not found\n";
}
