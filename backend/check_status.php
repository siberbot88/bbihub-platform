<?php
$u = \App\Models\User::where('email', 'fajar.bengkel88@gmail.com')->first();
if ($u) {
    dump($u->workshops->toArray());
} else {
    echo "User not found\n";
}
