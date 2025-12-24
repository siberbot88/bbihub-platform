<?php

namespace App\Livewire\Admin;

use Livewire\Component;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Title;
use App\Models\Workshop;
use App\Models\User;
use App\Models\Employment;
use App\Models\Feedback;
use App\Models\Transaction;
use App\Models\AuditLog;
use App\Models\Report;
use App\Models\OwnerSubscription;
use App\Models\MembershipTransaction;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

#[Title('Dashboard')]
#[Layout('layouts.app')]
class Dashboard extends Component
{
    public array $cards = [];
    public array $activityLogs = [];
    public array $serviceMonthly = [];
    public array $revenueByWorkshop = [];
    public array $appRevenue = [];
    public array $quickActions = [];

    public function mount(): void
    {
        $this->loadCards();
        $this->loadActivityLogs();
        $this->loadServiceChart();
        $this->loadRevenueChart();
        $this->loadAppRevenueTrend();
        $this->loadQuickActions();
    }

    private function loadCards(): void
    {
        // 1. Total Bengkel
        $totalWorkshops = Workshop::count();
        $activeWorkshops = Workshop::where('status', 'active')->count();

        // 2. Total User (Pelanggan)
        $totalUsers = User::doesntHave('roles')->count();

        // 3. Total Teknisi
        $totalMechanics = Employment::where('status', 'active')->count();

        // 4. Total Feedback (Today)
        $totalFeedback = Feedback::whereDate('created_at', Carbon::today())->count();
        $totalFeedbackAll = Feedback::count();

        $this->cards = [
            [
                'title' => 'Total Bengkel',
                'value' => $totalWorkshops,
                'desc' => "{$activeWorkshops} Bengkel Aktif",
                'icon' => 'bengkel',
                'delta' => '+0%',
                'chart' => $this->getSparklineDataOptimized(Workshop::class)
            ],
            [
                'title' => 'Total User',
                'value' => $totalUsers,
                'desc' => 'Pelanggan terdaftar',
                'icon' => 'pengguna',
                'delta' => '+0%',
                'chart' => $this->getSparklineDataOptimized(User::class)
            ],
            [
                'title' => 'Total Teknisi',
                'value' => $totalMechanics,
                'desc' => 'Mekanik terverifikasi',
                'icon' => 'tech',
                'delta' => '+0%',
                'chart' => [0, 0, 0, 0, 0, 0, 0]
            ],
            [
                'title' => 'Total Feedback',
                'value' => $totalFeedback > 0 ? $totalFeedback : $totalFeedbackAll,
                'desc' => $totalFeedback > 0 ? 'Feedback hari ini' : 'Total semua feedback',
                'icon' => 'feedback',
                'delta' => '+0%',
                'chart' => $this->getSparklineDataOptimized(Feedback::class)
            ],
        ];
    }

    private function loadActivityLogs(): void
    {
        // ✅ Already optimized with eager loading
        $logs = AuditLog::with('user')->latest()->take(5)->get();

        $this->activityLogs = $logs->map(function ($log) {
            return [
                'title' => $log->event . ' - ' . ($log->user->name ?? $log->user_email ?? 'System'),
                'time' => $log->created_at->diffForHumans(),
            ];
        })->toArray();

        if (empty($this->activityLogs)) {
            $this->activityLogs[] = ['title' => 'Belum ada aktivitas tercatat', 'time' => '-'];
        }
    }

    private function loadServiceChart(): void
    {
        // ✅ OPTIMIZED: Single aggregated query instead of 6 queries
        $startDate = Carbon::now()->subMonths(5)->startOfMonth();
        $endDate = Carbon::now()->endOfMonth();

        $results = Transaction::selectRaw("
                DATE_FORMAT(created_at, '%Y-%m') as month,
                COUNT(*) as count
            ")
            ->whereBetween('created_at', [$startDate, $endDate])
            ->groupBy('month')
            ->orderBy('month')
            ->get()
            ->keyBy('month');

        $data = [];
        $labels = [];

        for ($i = 5; $i >= 0; $i--) {
            $date = Carbon::now()->subMonths($i);
            $monthKey = $date->format('Y-m');

            $data[] = $results->get($monthKey)->count ?? 0;
            $labels[] = $date->format('M');
        }

        $this->serviceMonthly = [
            'labels' => $labels,
            'data' => $data,
        ];
    }

    private function loadAppRevenueTrend(): void
    {
        // ✅ OPTIMIZED: Single query for subscriptions, single query for memberships
        // Instead of 12 queries (6 + 6), we do 2 queries total

        $startDate = Carbon::now()->subMonths(5)->startOfMonth();
        $endDate = Carbon::now()->endOfMonth();

        // Get subscription revenue aggregated by month
        $subscriptionResults = OwnerSubscription::selectRaw("
                DATE_FORMAT(created_at, '%Y-%m') as month,
                SUM(gross_amount) as revenue
            ")
            ->whereBetween('created_at', [$startDate, $endDate])
            ->groupBy('month')
            ->get()
            ->keyBy('month');

        // Get membership revenue aggregated by month
        $membershipResults = MembershipTransaction::selectRaw("
                DATE_FORMAT(created_at, '%Y-%m') as month,
                SUM(amount) as revenue
            ")
            ->whereBetween('created_at', [$startDate, $endDate])
            ->where('payment_status', 'completed')
            ->groupBy('month')
            ->get()
            ->keyBy('month');

        $labels = [];
        $totalRevenue = [];
        $subscriptionRevenue = [];
        $membershipRevenue = [];

        for ($i = 5; $i >= 0; $i--) {
            $date = Carbon::now()->subMonths($i);
            $monthKey = $date->format('Y-m');

            $subs = $subscriptionResults->get($monthKey)->revenue ?? 0;
            $mems = $membershipResults->get($monthKey)->revenue ?? 0;

            $labels[] = $date->format('M Y');
            $subscriptionRevenue[] = $subs;
            $membershipRevenue[] = $mems;
            $totalRevenue[] = $subs + $mems;
        }

        $this->appRevenue = [
            'labels' => $labels,
            'total' => $totalRevenue,
            'breakdown' => [
                'subscriptions' => $subscriptionRevenue,
                'memberships' => $membershipRevenue
            ],
            'sources_pie' => [
                'labels' => ['Komisi Service', 'Langganan Bengkel', 'Membership'],
                'data' => [
                    0, // Commission (Not implemented yet)
                    array_sum($subscriptionRevenue),
                    array_sum($membershipRevenue)
                ]
            ]
        ];
    }

    private function loadRevenueChart(): void
    {
        // ✅ Already optimized with GROUP BY
        $topWorkshops = Transaction::select('workshop_uuid', DB::raw('sum(amount) as revenue'))
            ->groupBy('workshop_uuid')
            ->orderByDesc('revenue')
            ->take(5)
            ->with('workshop:id,name')
            ->get();

        $labels = [];
        $data = [];

        foreach ($topWorkshops as $item) {
            $name = $item->workshop->name ?? 'Unknown';
            $labels[] = Str::limit($name, 15);
            $data[] = $item->revenue;
        }

        if (empty($data)) {
            $labels = ['Belum ada data'];
            $data = [0];
        }

        $this->revenueByWorkshop = [
            'labels' => $labels,
            'data' => $data
        ];
    }

    private function loadQuickActions(): void
    {
        // ✅ Already optimized (simple counts)
        $this->quickActions = [
            'pending_workshops' => Workshop::where('status', 'pending')->count(),
            'pending_reports' => Report::where('status', 'pending')->count(),
            'suspended_workshops' => Workshop::where('status', 'suspended')->count(),
        ];
    }

    private function getSparklineDataOptimized($modelClass): array
    {
        // ✅ OPTIMIZED: Single aggregated query instead of 7 queries
        $startDate = Carbon::now()->subDays(6)->startOfDay();
        $endDate = Carbon::now()->endOfDay();

        $results = $modelClass::selectRaw("
                DATE(created_at) as date,
                COUNT(*) as count
            ")
            ->whereBetween('created_at', [$startDate, $endDate])
            ->groupBy('date')
            ->get()
            ->keyBy('date');

        $data = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i)->format('Y-m-d');
            $data[] = $results->get($date)->count ?? 0;
        }

        return $data;
    }

    public function render()
    {
        return view('livewire.admin.dashboard');
    }
}
