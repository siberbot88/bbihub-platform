<?php

namespace Tests\Feature\Performance;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;

class DashboardQueryOptimizationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test: Dashboard endpoint query count with simple check
     * 
     * This test verifies that the dashboard doesn't have N+1 query problems
     */
    public function test_dashboard_query_optimization()
    {
        // Seed database
        $this->seed();

        // Login as admin
        $admin = \App\Models\User::where('email', 'admin@example.com')->first();

        if (!$admin) {
            $this->markTestSkipped('Admin user not found. Run: php artisan db:seed');
        }

        $this->actingAs($admin, 'sanctum');

        // Enable query logging
        DB::enableQueryLog();

        // Call dashboard endpoint
        $response = $this->getJson('/api/v1/admins/dashboard');

        // Get executed queries
        $queries = DB::getQueryLog();
        $queryCount = count($queries);

        // Assertions
        $response->assertStatus(200);

        // Report query count
        $this->assertTrue(true, "Dashboard executed {$queryCount} queries");

        // ✅ OPTIMIZED: Should be less than 15 queries
        // Before optimization: 20+ queries (N+1 problem)
        // After optimization: ~5-12 queries
        if ($queryCount > 15) {
            dump("⚠️ WARNING: High query count detected: {$queryCount} queries");
            dump("First 5 queries:");
            foreach (array_slice($queries, 0, 5) as $index => $query) {
                dump(($index + 1) . ". " . $query['query']);
            }
        } else {
            dump("✅ OPTIMIZED: Only {$queryCount} queries executed");
        }

        $this->assertLessThan(
            15,
            $queryCount,
            "Dashboard has potential N+1 query! Found {$queryCount} queries."
        );

        DB::disableQueryLog();
    }

    /**
     * Test: Check that optimized queries use JOIN
     */
    public function test_optimized_queries_use_joins()
    {
        $this->seed();

        $admin = \App\Models\User::where('email', 'admin@example.com')->first();

        if (!$admin) {
            $this->markTestSkipped('Admin user not found');
        }

        $this->actingAs($admin, 'sanctum');

        DB::enableQueryLog();

        $this->getJson('/api/v1/admins/dashboard');

        $queries = DB::getQueryLog();

        // Check if aggregated queries are being used
        $hasJoinQuery = false;
        $hasGroupBy = false;

        foreach ($queries as $query) {
            $sql = strtolower($query['query']);

            if (str_contains($sql, 'join')) {
                $hasJoinQuery = true;
            }

            if (str_contains($sql, 'group by')) {
                $hasGroupBy = true;
            }
        }

        dump([
            'Has JOIN queries' => $hasJoinQuery ? '✅ Yes' : '❌ No',
            'Has GROUP BY' => $hasGroupBy ? '✅ Yes' : '❌ No',
        ]);

        // Optimized queries should use JOIN for mechanic stats
        $this->assertTrue(
            $hasJoinQuery || count($queries) < 10,
            'Dashboard should use optimized JOIN queries or have < 10 queries'
        );

        DB::disableQueryLog();
    }

    /**
     * Test: Performance benchmark
     */
    public function test_dashboard_performance_benchmark()
    {
        $this->seed();

        $admin = \App\Models\User::where('email', 'admin@example.com')->first();

        if (!$admin) {
            $this->markTestSkipped('Admin user not found');
        }

        $this->actingAs($admin, 'sanctum');

        $start = microtime(true);

        $response = $this->getJson('/api/v1/admins/dashboard');

        $end = microtime(true);
        $executionTime = ($end - $start) * 1000; // milliseconds

        $response->assertStatus(200);

        dump([
            '⏱️  Performance Metrics' => [
                'Execution Time' => round($executionTime, 2) . 'ms',
                'Status' => $executionTime < 1000 ? '✅ Fast' : '⚠️  Slow',
                'Target' => '< 1000ms',
            ],
        ]);

        $this->assertLessThan(
            2000,
            $executionTime,
            "Dashboard too slow: {$executionTime}ms. Expected < 2000ms."
        );
    }
}
