<?php

namespace App\Livewire\Admin;

use Livewire\Component;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Title;
use App\Services\EisService;

#[Title('Executive EIS')]
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
        $this->scorecard = $eisService->getKpiScorecard($this->selectedMonth, $this->selectedYear);
        // These metrics are currently global snapshots, but cached
        $this->clvAnalysis = $eisService->getClvAnalysis();
        $this->marketGap = $eisService->getMarketGapAnalysis();
        $this->customerSegmentation = $eisService->getCustomerSegmentation();

        // Platform Intelligence (SaaS)
        // Platform Business Outlook - Call ML API
        $this->platformOutlook = $this->getPlatformOutlookFromML();

        $this->topWorkshops = $eisService->getTopWorkshops();
        $this->cityStats = $eisService->getCityMarketStats();

        // Set filters
        $this->selectedYear = now()->year;
        $this->selectedMonth = now()->month;
    }

    /**
     * Get Platform Outlook from ML Service
     * Falls back to basic calculation if ML service unavailable
     */
    private function getPlatformOutlookFromML(): array
    {
        try {
            /** @var \Illuminate\Http\Client\Response $response */
            $response = \Illuminate\Support\Facades\Http::timeout(5)->get(
                env('ML_API_URL', 'http://localhost:5000') . '/predict/platform-outlook'
            );

            if ($response->successful()) {
                \Illuminate\Support\Facades\Log::info('ML API call successful');
                return $response->json();
            }

            // Fallback if API call failed
            \Illuminate\Support\Facades\Log::warning('ML API failed, using fallback');
            return $this->getPlatformOutlookFallback();

        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('ML API Error: ' . $e->getMessage());
            return $this->getPlatformOutlookFallback();
        }
    }

    /**
     * Fallback Platform Outlook (basic calculation)
     */
    private function getPlatformOutlookFallback(): array
    {
        try {
            // Use Laravel service container to get PlatformIntelligenceService
            $platformService = app(\App\Services\PlatformIntelligenceService::class);

            return [
                'churn_candidates' => $platformService->getChurnRiskCandidates(),
                'upsell_candidates' => $platformService->getUpsellCandidates(),
                'mrr_forecast' => $platformService->forecastMRR()
            ];
        } catch (\Exception $e) {
            // Return empty structure if fallback also fails
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
        \Illuminate\Support\Facades\Cache::forget("eis_clv");
        \Illuminate\Support\Facades\Cache::forget("eis_market_gap");
        \Illuminate\Support\Facades\Cache::forget("eis_segmentation");
        \Illuminate\Support\Facades\Cache::forget("eis_top_workshops");

        $this->loadData($eisService, $platformService);

        $this->dispatch('refresh-charts'); // Signal JS to re-render charts
    }

    public function applyFilter(EisService $eisService, \App\Services\PlatformIntelligenceService $platformService)
    {
        $this->showFilter = false;
        $this->loadData($eisService, $platformService);
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

        // Dispatch event safely for chart initialization in modal
        $this->dispatch('init-workshop-chart');
    }

    public function closeWorkshopModal()
    {
        $this->showWorkshopModal = false;
        $this->workshopDetail = [];
        $this->selectedWorkshopId = '';
    }

    public function render()
    {
        return view('livewire.admin.executive-dashboard');
    }
}
