<?php

namespace App\Livewire\Admin;

use Livewire\Component;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Title;
use App\Services\EisService;

#[Title('Analitik Bisnis')]
#[Layout('layouts.app')]
class ExecutiveDashboard extends Component
{
    public array $scorecard = [];
    public array $clvAnalysis = [];
    public array $marketGap = [];
    public array $customerSegmentation = [];
    public array $platformOutlook = [];
    public array $topWorkshops = [];
    public array $cityStats = [];

    // Drill Down State
    public bool $showWorkshopModal = false;
    public array $workshopDetail = [];
    public string $selectedWorkshopId = '';

    // Filter State
    public int $selectedMonth;
    public int $selectedYear;
    public bool $showFilter = false;

    public function mount(EisService $eisService, \App\Services\PlatformIntelligenceService $platformService)
    {
        $this->selectedMonth = now()->month;
        $this->selectedYear = now()->year;

        $this->loadData($eisService, $platformService);
    }

    public function loadData(EisService $eisService, \App\Services\PlatformIntelligenceService $platformService)
    {
        $this->loadMonthlyData($eisService);
        $this->loadYearlyData($eisService, $platformService);
    }

    public function loadMonthlyData(EisService $eisService)
    {
        $this->scorecard = $eisService->getKpiScorecard($this->selectedMonth, $this->selectedYear);
    }

    public function loadYearlyData(EisService $eisService, \App\Services\PlatformIntelligenceService $platformService)
    {
        // YEARLY DATA (CLV, Map, Top Workshops)
        $this->clvAnalysis = $eisService->getClvAnalysis($this->selectedYear);
        $this->marketGap = $eisService->getMarketGapAnalysis($this->selectedYear);
        $this->topWorkshops = $eisService->getTopWorkshops(10, $this->selectedYear);
        $this->cityStats = $eisService->getCityMarketStats($this->selectedYear);

        // CUSTOMER SEGMENTATION - Keep global for now
        $this->customerSegmentation = $eisService->getCustomerSegmentation();

        // Platform Intelligence (SaaS)
        $this->platformOutlook = $this->getPlatformOutlookFromML();

        \Illuminate\Support\Facades\Log::info("ExecutiveDashboard loaded for Year {$this->selectedYear} forced log", [
            'clv_scatter_count' => count($this->clvAnalysis['scatter'] ?? []),
            'market_gap_count' => count($this->marketGap),
            'top_workshops_count' => count($this->topWorkshops),
        ]);
    }

    /**
     * Get Platform Outlook from ML Service
     */
    private function getPlatformOutlookFromML(): array
    {
        try {
            /** @var \Illuminate\Http\Client\Response $response */
            $response = \Illuminate\Support\Facades\Http::timeout(5)->get(
                env('ML_API_URL', 'http://localhost:5000') . '/predict/platform-outlook'
            );

            if ($response->successful()) {
                return $response->json();
            }
            return $this->getPlatformOutlookFallback();

        } catch (\Exception $e) {
            return $this->getPlatformOutlookFallback();
        }
    }

    private function getPlatformOutlookFallback(): array
    {
        try {
            $platformService = app(\App\Services\PlatformIntelligenceService::class);

            return [
                'churn_candidates' => $platformService->getChurnRiskCandidates(),
                'upsell_candidates' => $platformService->getUpsellCandidates(),
                'mrr_forecast' => $platformService->forecastMRR()
            ];
        } catch (\Exception $e) {
            return [
                'churn_candidates' => [],
                'upsell_candidates' => [],
                'mrr_forecast' => [
                    'prediction' => 0,
                    'growth_rate' => 0,
                    'history' => []
                ]
            ];
        }
    }

    public function refresh(EisService $eisService, \App\Services\PlatformIntelligenceService $platformService)
    {
        // Clear specific caches
        \Illuminate\Support\Facades\Cache::forget("eis_scorecard_{$this->selectedYear}_{$this->selectedMonth}");
        \Illuminate\Support\Facades\Cache::forget("eis_clv_{$this->selectedYear}");
        \Illuminate\Support\Facades\Cache::forget("eis_market_gap_v2_{$this->selectedYear}");
        \Illuminate\Support\Facades\Cache::forget("eis_top_workshops_{$this->selectedYear}");
        \Illuminate\Support\Facades\Cache::forget("eis_city_stats_map_{$this->selectedYear}");

        $this->loadData($eisService, $platformService);

        $this->dispatch('refresh-charts');
    }

    public function applyFilter(EisService $eisService, \App\Services\PlatformIntelligenceService $platformService)
    {
        $this->showFilter = false;
        $this->loadData($eisService, $platformService); // Load Everything
        $this->dispatch('refresh-charts');
    }

    // Livewire Hook: When Year Changes
    public function updatedSelectedYear(EisService $eisService, \App\Services\PlatformIntelligenceService $platformService)
    {
        // When Year changes, we reload everything (Monthly Scorecard depends on Year too, and Yearly charts)
        $this->loadData($eisService, $platformService);
        $this->dispatch('refresh-charts');
    }

    // Livewire Hook: When Month Changes
    public function updatedSelectedMonth(EisService $eisService)
    {
        // When Month changes, ONLY reload Monthly Data (Scorecard)
        $this->loadMonthlyData($eisService);
        // No need to refresh charts for Scorecard as they are rendered via Blade loop (except Sparklines?)
        // Sparklines in Scorecard MIGHT need refresh if they depend on Month? 
        // Current Scorecard sparkline is just "trend", usually based on year history ending in month.
        // Let's dispatch refresh anyway to be safe, or just partial?
        // Scorecard sparklines are canvas. They need re-init.
        $this->dispatch('refresh-charts');
    }

    public function generateSnapshot(EisService $eisService)
    {
        $eisService->createSnapshot($this->selectedYear);
        $this->dispatch('notify', type: 'success', message: "Data tahun {$this->selectedYear} berhasil diarsipkan.");
        // Reload to presumably fetch from snapshot
        $this->loadData($eisService, app(\App\Services\PlatformIntelligenceService::class));
        $this->dispatch('refresh-charts');
    }

    public function exportData()
    {
        return redirect()->route('admin.eis.print', [
            'month' => $this->selectedMonth,
            'year' => $this->selectedYear
        ]);
    }

    public function openWorkshopDetail(EisService $eisService, string $id)
    {
        $this->selectedWorkshopId = $id;
        $this->workshopDetail = $eisService->getWorkshopDetail($id);
        $this->showWorkshopModal = true;
        $this->dispatch('init-workshop-chart');
    }

    public function closeWorkshopModal()
    {
        $this->showWorkshopModal = false;
        $this->workshopDetail = [];
        $this->selectedWorkshopId = '';
    }

    public function sendUpsellOffer(string $workshopId)
    {
        $workshop = \App\Models\Workshop::find($workshopId);

        if ($workshop && $workshop->owner) {
            $workshop->owner->notify(new \App\Notifications\UpsellPremiumNotification());
            $this->dispatch('notify', type: 'success', message: "Penawaran Premium berhasil dikirim.");
        } else {
            $this->dispatch('notify', type: 'error', message: "Gagal mengirim penawaran.");
        }
    }

    public function render()
    {
        return view('livewire.admin.executive-dashboard');
    }
}
