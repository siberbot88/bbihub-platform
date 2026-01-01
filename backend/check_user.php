try {
// Pick a user who has a workshop
$w = \App\Models\Workshop::first();
if (!$w) { die("No workshops found."); }

$u = $w->owner;
if (!$u) { die("Workshop has no owner."); }

echo "User found: " . $u->name . "\n";

// Check property access
$direct = $u->workshop_uuid;
echo "Direct Access (\$u->workshop_uuid): " . var_export($direct, true) . "\n";

// Check attributes array
$attrs = $u->getAttributes();
echo "Exists in attributes? " . (array_key_exists('workshop_uuid', $attrs) ? 'YES' : 'NO') . "\n";

// Check relation
echo "Relation Access (\$u->workshop->id): " . ($u->workshop ? $u->workshop->id : 'NULL') . "\n";

} catch (\Exception $e) {
echo "Error: " . $e->getMessage();
}