<div class="space-y-8" x-data="{ 
    loaded: false, 
    showArchiveModal: false,
    showUpsellModal: false,
    selectedUpsell: null
}" x-init="setTimeout(() => { loaded = true; setTimeout(() => initCharts(), 1000); }, 500)">

    {{-- Header & Controls --}}
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
            <h1 class="text-2xl font-bold text-gray-900">Executive Decision Intelligence</h1>
            <p class="text-sm text-gray-500">Pemantauan kinerja bisnis real-time berbasis prinsip EIS.</p>
        </div>

        <div class="flex flex-wrap items-center gap-3">
            {{-- Export Button --}}
            <button wire:click="exportData"
                class="inline-flex items-center gap-2 px-4 py-2 bg-red-600 hover:bg-red-700 text-white text-sm font-medium rounded-lg transition-colors shadow-sm">
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" />
                </svg>
                Ekspor Data
            </button>

            {{-- Filter Button --}}
            <div class="relative" x-data="{ open: @entangle('showFilter') }">
                <button @click="open = !open"
                    class="inline-flex items-center gap-2 px-4 py-2 bg-white border border-gray-200 hover:bg-gray-50 text-gray-700 text-sm font-medium rounded-lg transition-colors shadow-sm">
                    <svg class="w-4 h-4 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
                    </svg>
                    Filter & Arsip
                </button>

                {{-- Filter Dropdown --}}
                <div x-show="open" @click.away="open = false"
                    class="absolute right-0 mt-2 w-72 bg-white rounded-xl shadow-xl border border-gray-100 p-4 z-50 origin-top-right"
                    style="display: none;">

                    <div class="mb-4 pb-4 border-b border-gray-100">
                        <h3 class="font-bold text-gray-900 mb-3 text-xs uppercase tracking-wider">Laporan Tahunan (EIS)
                        </h3>
                        <div>
                            <select wire:model.live="selectedYear"
                                class="w-full text-sm border-gray-300 rounded-lg focus:ring-indigo-500 focus:border-indigo-500">
                                @foreach(range(date('Y'), date('Y') - 4) as $y)
                                    <option value="{{ $y }}">{{ $y }}</option>
                                @endforeach
                            </select>
                            <p class="text-[10px] text-gray-500 mt-1">Mengubah grafik CLV, Market Gap, dan Top
                                Workshops.</p>
                        </div>
                    </div>

                    <div class="mb-4 pb-4 border-b border-gray-100">
                        <h3 class="font-bold text-gray-900 mb-3 text-xs uppercase tracking-wider">Periode Scorecard
                            (Bulanan)</h3>
                        <div>
                            <select wire:model.live="selectedMonth"
                                class="w-full text-sm border-gray-300 rounded-lg focus:ring-indigo-500 focus:border-indigo-500">
                                @foreach(range(1, 12) as $m)
                                    <option value="{{ $m }}">{{ DateTime::createFromFormat('!m', $m)->format('F') }}
                                    </option>
                                @endforeach
                            </select>
                            <p class="text-[10px] text-gray-500 mt-1">Mengubah kartu KPI pendapatan bulanan.</p>
                        </div>
                    </div>

                    <div class="space-y-2">
                        <button wire:click="applyFilter"
                            class="w-full py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium rounded-lg transition-colors">
                            Tutup
                        </button>

                        {{-- Archive Button with Custom Modal Trigger --}}
                        <button @click="showArchiveModal = true; open = false"
                            class="w-full py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 text-sm font-medium rounded-lg transition-colors flex items-center justify-center gap-2">
                            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4" />
                            </svg>
                            Arsipkan Data Tahun Ini
                        </button>
                    </div>
                </div>
            </div>

            {{-- Refresh Button --}}
            <button wire:click="refresh"
                class="inline-flex items-center gap-2 px-4 py-2 bg-white border border-gray-200 hover:bg-gray-50 text-gray-700 text-sm font-medium rounded-lg transition-colors shadow-sm group">
                <svg class="w-4 h-4 text-gray-500 group-hover:rotate-180 transition-transform duration-500" fill="none"
                    viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
                Refresh
            </button>
        </div>
    </div>

    {{-- Loading Skeleton --}}
    <div wire:loading class="w-full">
        <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 animate-pulse">
            <div class="h-40 bg-gray-200 rounded-2xl"></div>
            <div class="h-40 bg-gray-200 rounded-2xl"></div>
            <div class="h-40 bg-gray-200 rounded-2xl"></div>
        </div>
    </div>

    {{-- 1. KPI Scorecard (Dashboard Style) --}}
    <div wire:loading.remove class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3" x-show="loaded"
        x-transition:enter="transition ease-out duration-500" x-transition:enter-start="opacity-0 transform scale-95"
        x-transition:enter-end="opacity-100 transform scale-100">

        @foreach($scorecard as $index => $card)
            @php
                switch ($card['id']) {
                    case 'revenue':
                        $color = 'emerald';
                        $icon = 'banknotes';
                        break;
                    case 'mrr':
                        $color = 'blue';
                        $icon = 'arrow-path';
                        break;
                    case 'subscriptions':
                        $color = 'cyan';
                        $icon = 'ticket';
                        break;
                    case 'users':
                        $color = 'violet';
                        $icon = 'users';
                        break;
                    case 'csat':
                        $color = 'amber';
                        $icon = 'star';
                        break;
                    case 'nps':
                        $color = 'rose';
                        $icon = 'megaphone';
                        break;
                    default:
                        $color = 'gray';
                        $icon = 'chart-bar';
                        break;
                }
                $bgClass = "bg-{$color}-50";
                $textClass = "text-{$color}-600";
                $isRightEdge = ($index + 1) % 3 === 0;
                $tooltipClass = $isRightEdge ? 'right-0 origin-top-right' : 'left-0 origin-top-left';
                $arrowClass = $isRightEdge ? 'right-2' : 'left-2';
            @endphp

            <div
                class="relative rounded-2xl bg-white p-6 shadow-sm border border-gray-100 transition-all duration-300 hover:-translate-y-1 hover:shadow-lg hover:z-20 group">
                <div class="absolute inset-0 overflow-hidden rounded-2xl pointer-events-none">
                    <div
                        class="absolute -right-6 -top-6 h-24 w-24 rounded-full {{ $bgClass }} opacity-50 transition-transform group-hover:scale-110">
                    </div>
                </div>

                <div class="relative z-10 flex justify-between items-start">
                    <div class="flex-1">
                        <div class="flex items-start gap-2">
                            <span class="text-sm font-medium text-gray-500">{{ $card['name'] }}</span>
                            <div class="relative group/info cursor-help inline-block mt-0.5">
                                <svg class="w-4 h-4 text-gray-300 hover:text-gray-500 transition-colors" fill="none"
                                    viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <div
                                    class="absolute z-50 invisible w-64 p-3 mt-2 text-xs font-normal text-white bg-gray-900 rounded-lg opacity-0 {{ $tooltipClass }} group-hover/info:visible group-hover/info:opacity-100 transition-all duration-200 shadow-xl">
                                    {{ $card['description'] }}
                                    <div class="absolute -top-1 {{ $arrowClass }} w-2 h-2 bg-gray-900 rotate-45"></div>
                                </div>
                            </div>
                        </div>

                        <div class="mt-2 flex flex-wrap items-baseline gap-2">
                            <span class="text-2xl font-bold text-gray-900 leading-tight">
                                {{ $card['unit'] === 'IDR' ? 'Rp' . number_format($card['value'], 0, ',', '.') : ($card['unit'] === '%' ? number_format($card['value'], 1) . '%' : number_format($card['value'])) }}
                            </span>
                            @if($card['status'] === 'blue')
                                <span
                                    class="text-xs font-medium text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full flex items-center gap-1">
                                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd"
                                            d="M12 7a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0V8.414l-4.293 4.293a1 1 0 01-1.414 0L8 10.414l-4.293 4.293a1 1 0 01-1.414-1.414l5-5a1 1 0 011.414 0L11 10.586 14.586 7H12z"
                                            clip-rule="evenodd" />
                                    </svg> Strong
                                </span>
                            @elseif($card['status'] === 'green')
                                <span
                                    class="text-xs font-medium text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full flex items-center gap-1">
                                    <svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                                    </svg> On Track
                                </span>
                            @else
                                <span
                                    class="text-xs font-medium text-rose-600 bg-rose-50 px-2 py-0.5 rounded-full flex items-center gap-1">
                                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd"
                                            d="M10 18a8 8 0 100-16 8 8 0 000 16zm-1-4a1 1 0 112 0v-4a1 1 0 11-2 0v4zm1-9a1 1 0 100 2 1 1 0 000-2z"
                                            clip-rule="evenodd" />
                                    </svg> Review
                                </span>
                            @endif
                        </div>
                        <div class="mt-1 text-xs text-gray-400">Target: {{ number_format($card['target']) }}</div>
                    </div>

                    <div class="p-3 rounded-xl {{ $bgClass }} {{ $textClass }} shrink-0 ml-4">
                        @if($icon === 'banknotes')
                            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        @elseif($icon === 'arrow-path')
                            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                            </svg>
                        @elseif($icon === 'users')
                            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                            </svg>
                        @elseif($icon === 'ticket')
                            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M16.5 6v.75m0 3v.75m0 3v.75m0 3V18m-9-5.25h5.25M7.5 15h3M3.375 5.25c-.621 0-1.125.504-1.125 1.125v9.632a2.25 2.25 0 01-.894 1.785 2.25 2.25 0 001.077 4.083h19.134a2.25 2.25 0 001.077-4.083 2.25 2.25 0 01-.894-1.785V6.375c0-.621-.504-1.125-1.125-1.125H3.375z" />
                            </svg>
                        @elseif($icon === 'star')
                            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z" />
                            </svg>
                        @elseif($icon === 'megaphone')
                            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M10.34 15.84c-.688-.06-1.386-.09-2.09-.09H7.5a4.5 4.5 0 110-9h.75c.704 0 1.402-.03 2.09-.09m0 9.18c.253.962.584 1.892.985 2.783.247.55.06 1.21-.463 1.511l-.657.38c-.551.318-1.26.117-1.527-.461a20.845 20.845 0 01-1.44-4.282m3.102.069a18.03 18.03 0 01-.59-4.59c0-1.586.205-3.124.59-4.59m0 9.18a23.848 23.848 0 018.835 2.535M10.34 6.66a23.847 23.847 0 008.835-2.535m0 0A23.74 23.74 0 0018.795 3m.38 1.125a23.91 23.91 0 011.014 5.395m-1.014 8.855c-.118.38-.245.754-.38 1.125m.38-1.125a23.91 23.91 0 001.014-5.395m0-3.467a23.849 23.849 0 010 3.467m0-3.467a23.849 23.849 0 000 3.467" />
                            </svg>
                        @else
                            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z" />
                            </svg>
                        @endif
                    </div>
                </div>

                {{-- Sparkline Chart --}}
                <div class="mt-4 h-24 w-[calc(100%+3rem)] -ml-6 -mb-6 relative z-10 overflow-hidden rounded-b-2xl">
                    <canvas id="sparkline-{{ $loop->index }}"
                        data-chart="{{ json_encode($card['chart_data'] ?? [0, 0, 0]) }}" data-color="{{ $color }}">
                    </canvas>
                </div>
            </div>
        @endforeach
    </div>

    {{-- 2. Geospatial Market Gap & CLV --}}
    <div wire:loading.remove class="flex flex-row gap-4" x-show="loaded"
        x-transition:enter="transition ease-out duration-700 delay-100"
        x-transition:enter-start="opacity-0 translate-y-4" x-transition:enter-end="opacity-100 translate-y-0">

        {{-- Matrix Chart (2/3 width on desktop) --}}
        <div class="w-2/3 space-y-8">
            {{-- CLV Chart --}}
            <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                <div class="flex justify-between items-start mb-6">
                    <div>
                        <div class="flex items-center gap-2">
                            <h3 class="text-lg font-bold text-gray-900">Matriks Nilai Pelanggan (CLV)</h3>
                            <div class="relative group/info cursor-help inline-block">
                                <svg class="w-4 h-4 text-gray-300 hover:text-gray-500 transition-colors" fill="none"
                                    viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <div
                                    class="absolute z-50 invisible w-64 p-3 mt-2 text-xs leading-relaxed text-white bg-gray-900 rounded-lg opacity-0 -right-1/2 group-hover/info:visible group-hover/info:opacity-100 transition-all duration-200 shadow-xl">
                                    Identifikasi segmen pelanggan berdasarkan Frekuensi Pembelian (Sumbu X) dan Total
                                    Nilai Uang (Sumbu Y).
                                </div>
                            </div>
                        </div>
                        <p class="text-sm text-gray-500 mt-1">Segmentasi berdasarkan Frekuensi vs Nominal Transaksi</p>
                    </div>
                </div>
                <div class="h-80 w-full relative">
                    <canvas id="clvBubbleChart"
                        data-chart-json="{{ json_encode($clvAnalysis['scatter'] ?? []) }}"></canvas>
                </div>
            </div>

            {{-- Market Gap Analysis --}}
            <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <div class="flex items-center gap-2">
                            <h3 class="text-lg font-bold text-gray-900">Geospatial Market Gap</h3>
                            <span
                                class="bg-indigo-100 text-indigo-700 text-[10px] px-2 py-0.5 rounded-full font-bold">Interactive
                                Map</span>
                        </div>
                        <p class="text-sm text-gray-500 mt-1">Peta Peluang Ekspansi (Demand vs Supply)</p>
                    </div>
                </div>

                <div id="marketMap" data-chart-json="{{ json_encode($cityStats) }}"
                    class="w-full h-80 rounded-xl border border-gray-200 bg-gray-50 relative z-0"></div>

                <div class="mt-4 grid grid-cols-2 gap-2 max-h-40 overflow-y-auto custom-scrollbar">
                    @forelse(array_slice($marketGap, 0, 5) as $city)
                        <div
                            class="flex justify-between items-center text-xs p-2 bg-gray-50 rounded border border-gray-100">
                            <span class="font-bold text-gray-700">{{ $city['city'] }}</span>
                            <span class="text-indigo-600 font-bold">{{ number_format($city['gap_score'], 0) }}% Gap</span>
                        </div>
                    @empty
                        <div class="col-span-2 text-center text-xs text-gray-400">Data belum tersedia</div>
                    @endforelse
                </div>
            </div>
        </div>

        {{-- Insight Panel (1/3 width on desktop) --}}
        <div class="flex flex-col gap-6 w-1/3">
            <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                <h3 class="text-lg font-bold text-gray-900 mb-6">Quick Insights</h3>
                <div class="space-y-6">
                    <div class="relative pl-4 border-l-4 border-indigo-500">
                        <div class="text-xs font-semibold text-indigo-500 uppercase tracking-wide">High Value Customers
                        </div>
                        <div class="text-3xl font-bold text-gray-900 mt-1">
                            {{ $clvAnalysis['summary']['high_value_count'] ?? 0 }}</div>
                    </div>
                    <div class="relative pl-4 border-l-4 border-emerald-500">
                        <div class="text-xs font-semibold text-emerald-500 uppercase tracking-wide">Rata-rata LTV</div>
                        <div class="text-3xl font-bold text-gray-900 mt-1">Rp
                            {{ number_format($clvAnalysis['summary']['avg_ltv'] ?? 0, 0, ',', '.') }}</div>
                    </div>
                </div>
            </div>

            <div
                class="bg-gradient-to-br from-indigo-600 to-purple-700 rounded-2xl shadow-lg p-6 text-white relative overflow-hidden">
                <div class="relative z-10">
                    <h4 class="font-bold text-lg mb-2">Rekomendasi AI</h4>
                    <p class="text-indigo-100 text-sm leading-relaxed">
                        Fokus retensi pada {{ $clvAnalysis['summary']['high_value_count'] ?? 0 }} pelanggan bernilai
                        tinggi.
                        Pertimbangkan program loyalitas eksklusif.
                    </p>
                </div>
                <div class="absolute -bottom-8 -right-8 w-32 h-32 bg-white opacity-10 rounded-full blur-2xl"></div>
            </div>
        </div>
    </div>

    {{-- 3. Operational Deep Dive --}}
    <div wire:loading.remove
        class="mt-8 bg-white rounded-2xl shadow-sm border border-gray-100 p-8 relative overflow-hidden">
        <div class="absolute top-0 right-0 w-64 h-64 bg-indigo-50 rounded-bl-full opacity-50 pointer-events-none"></div>

        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 relative z-10">
            <div class="flex items-center gap-3">
                <div class="p-2 bg-blue-50 rounded-lg text-blue-600">
                    <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                    </svg>
                </div>
                <div>
                    <h2 class="text-xl font-bold text-gray-900">Drill-down: Kinerja Mitra Bengkel</h2>
                    <p class="text-sm text-gray-500">Analisis performa Top 10 Mitra. Klik bar grafik untuk melihat
                        detail mendalam.</p>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 relative z-10">
            <div class="lg:col-span-2">
                <div class="w-full relative" style="height: 320px; min-height: 320px;">
                    <canvas id="topWorkshopsChart" data-chart-json="{{ json_encode($topWorkshops) }}"></canvas>
                </div>
            </div>
            <div class="space-y-6">
                <div class="bg-gray-50 rounded-xl p-5 border border-gray-100">
                    <h4 class="font-bold text-gray-900 text-sm mb-3">Highlight Performa</h4>
                    @if(count($topWorkshops) > 0)
                        <div class="flex items-center gap-4 mb-4">
                            <div class="w-12 h-12 rounded-full bg-yellow-100 flex items-center justify-center text-2xl">🏆
                            </div>
                            <div>
                                <div class="text-xs text-gray-500 uppercase tracking-widest">Top Performer</div>
                                <div class="font-bold text-gray-900">{{ $topWorkshops[0]['name'] }}</div>
                                <div class="text-xs text-indigo-600 font-semibold">Rp
                                    {{ number_format($topWorkshops[0]['revenue'], 0, ',', '.') }}</div>
                            </div>
                        </div>
                    @endif
                    <p class="text-xs text-gray-500 leading-relaxed">
                        <span class="font-bold text-indigo-600">Klik salah satu bar</span> untuk membuka modal detail.
                    </p>
                </div>
            </div>
        </div>
    </div>

    {{-- Detail Modal (Workshop) --}}
    <div x-data="{ show: @entangle('showWorkshopModal') }" x-show="show" x-cloak
        class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div x-show="show" class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
                @click="$wire.closeWorkshopModal(); setTimeout(() => { if(window.marketMapInstance) window.marketMapInstance.invalidateSize(); }, 100)"></div>
            <span class="hidden sm:inline-block sm:align-middle sm:h-screen">&#8203;</span>
            <div x-show="show"
                class="inline-block align-bottom bg-white rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-6xl sm:w-full">
                @if(!empty($workshopDetail))
                    <div class="bg-indigo-600 px-4 py-4 sm:px-6">
                        <div class="flex items-center justify-between">
                            <h3 class="text-lg leading-6 font-medium text-white">Workshop Deep Dive:
                                {{ $workshopDetail['name'] }}</h3>
                            <button type="button" class="text-indigo-200 hover:text-white"
                                wire:click="closeWorkshopModal"
                                @click="setTimeout(() => { if(window.marketMapInstance) window.marketMapInstance.invalidateSize(); }, 100)">X</button>
                        </div>
                        <p class="mt-1 text-sm text-indigo-200">Owner: {{ $workshopDetail['owner_name'] }} |
                            {{ $workshopDetail['address'] }}</p>
                    </div>
                    <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                        <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                            <div class="space-y-4">
                                <div class="bg-gray-50 p-4 rounded-xl border border-gray-100">
                                    <div class="text-xs text-gray-500 uppercase tracking-wide">Total Revenue</div>
                                    <div class="text-2xl font-bold text-gray-900 mt-1">Rp
                                        {{ number_format($workshopDetail['total_revenue'], 0, ',', '.') }}</div>
                                </div>
                                <div class="bg-gray-50 p-4 rounded-xl border border-gray-100">
                                    <div class="text-xs text-gray-500 uppercase tracking-wide">Avg Rating</div>
                                    <div class="flex items-center gap-1 mt-1">
                                        <span
                                            class="text-2xl font-bold text-gray-900">{{ $workshopDetail['rating'] }}</span>
                                    </div>
                                </div>
                                <div class="bg-gray-50 p-4 rounded-xl border border-gray-100">
                                    <div class="text-xs text-gray-500 uppercase tracking-wide">Total Transaksi</div>
                                    <div class="text-2xl font-bold text-gray-900 mt-1">{{ number_format($workshopDetail['total_trx'] ?? 0) }}</div>
                                </div>
                            </div>
                            <div class="md:col-span-2">
                                <h4 class="font-bold text-gray-900 text-sm mb-3">Tren Pendapatan (6 Bulan Terakhir)</h4>
                                <div class="h-48 w-full">
                                    <canvas id="workshopDetailChart"
                                        data-labels="{{ json_encode(array_keys($workshopDetail['revenue_trend'] ?? [])) }}"
                                        data-values="{{ json_encode(array_values($workshopDetail['revenue_trend'] ?? [])) }}">
                                    </canvas>
                                </div>
                            </div>
                            
                            {{-- Column 4: Popular Services --}}
                            <div>
                                <h4 class="font-bold text-gray-900 text-sm mb-3">Service Paling Laris</h4>
                                <div class="space-y-2 max-h-64 overflow-y-auto">
                                    @forelse($workshopDetail['top_services'] ?? [] as $service)
                                        <div class="bg-gradient-to-r from-indigo-50 to-purple-50 p-3 rounded-lg border border-indigo-100">
                                            <div class="flex items-start justify-between gap-2">
                                                <div class="flex-1 min-w-0">
                                                    <div class="text-sm font-semibold text-gray-900 leading-tight truncate" title="{{ $service['name'] }}">
                                                        {{ $service['name'] }}
                                                    </div>
                                                    <div class="text-xs text-gray-500 mt-1">{{ $service['count'] }} transaksi</div>
                                                </div>
                                                <div class="flex items-center justify-center h-7 w-7 rounded-full bg-indigo-600 text-white text-xs font-bold flex-shrink-0">
                                                    {{ $loop->iteration }}
                                                </div>
                                            </div>
                                        </div>
                                    @empty
                                        <div class="text-center py-8 text-gray-400 text-sm">
                                            <svg class="w-12 h-12 mx-auto mb-2 text-gray-300" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                            </svg>
                                            Belum ada data service
                                        </div>
                                    @endforelse
                                </div>
                            </div>
                        </div>
                    </div>
                @else
                    <div class="p-10 text-center">Memuat data...</div>
                @endif
            </div>
        </div>
    </div>

    {{-- Premium Archive Modal --}}
    <div x-show="showArchiveModal" x-cloak class="relative z-[60]" aria-labelledby="modal-title" role="dialog"
        aria-modal="true">
        <div x-show="showArchiveModal" x-transition:enter="ease-out duration-300" x-transition:enter-start="opacity-0"
            x-transition:enter-end="opacity-100" x-transition:leave="ease-in duration-200"
            x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0"
            class="fixed inset-0 bg-gray-500 bg-opacity-75 backdrop-blur-sm transition-opacity"></div>

        <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
            <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
                <div x-show="showArchiveModal" x-transition:enter="ease-out duration-300"
                    x-transition:enter-start="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                    x-transition:enter-end="opacity-100 translate-y-0 sm:scale-100"
                    x-transition:leave="ease-in duration-200"
                    x-transition:leave-start="opacity-100 translate-y-0 sm:scale-100"
                    x-transition:leave-end="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                    @click.away="showArchiveModal = false"
                    class="relative transform overflow-hidden rounded-2xl bg-white text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-lg">
                    <div class="bg-white px-4 pb-4 pt-5 sm:p-6 sm:pb-4">
                        <div class="sm:flex sm:items-start">
                            <div
                                class="mx-auto flex h-16 w-16 flex-shrink-0 items-center justify-center rounded-full bg-red-100 sm:mx-0 sm:h-12 sm:w-12">
                                <svg class="h-8 w-8 text-red-600 sm:h-6 sm:w-6" fill="none" viewBox="0 0 24 24"
                                    stroke-width="1.5" stroke="currentColor" aria-hidden="true">
                                    <path stroke-linecap="round" stroke-linejoin="round"
                                        d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
                                </svg>
                            </div>
                            <div class="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left">
                                <h3 class="text-xl font-bold leading-6 text-gray-900" id="modal-title">Konfirmasi
                                    Pengarsipan</h3>
                                <div class="mt-2">
                                    <p class="text-sm text-gray-500">
                                        Anda akan mengarsipkan data analitik untuk tahun
                                        <strong>{{ date('Y') }}</strong>.
                                        Tindakan ini akan membuat snapshot permanen untuk referensi histori. Data saat
                                        ini tidak akan dihapus, namun snapshot akan ditimpa jika sudah ada.
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="bg-gray-50 px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6">
                        <button type="button" wire:click="generateSnapshot" @click="showArchiveModal = false"
                            class="inline-flex w-full justify-center rounded-xl bg-red-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500 sm:ml-3 sm:w-auto transition-colors">
                            Ya, Arsipkan Data
                        </button>
                        <button type="button" @click="showArchiveModal = false"
                            class="mt-3 inline-flex w-full justify-center rounded-xl bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto transition-colors">
                            Batal
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- Premium Upsell Modal --}}
    <div x-show="showUpsellModal" x-cloak class="relative z-[60]" aria-labelledby="modal-title" role="dialog"
        aria-modal="true">
        <div x-show="showUpsellModal" x-transition:enter="ease-out duration-300" x-transition:enter-start="opacity-0"
            x-transition:enter-end="opacity-100" x-transition:leave="ease-in duration-200"
            x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0"
            class="fixed inset-0 bg-gray-500 bg-opacity-75 backdrop-blur-sm transition-opacity"></div>

        <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
            <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
                <div x-show="showUpsellModal" x-transition:enter="ease-out duration-300"
                    x-transition:enter-start="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                    x-transition:enter-end="opacity-100 translate-y-0 sm:scale-100"
                    x-transition:leave="ease-in duration-200"
                    x-transition:leave-start="opacity-100 translate-y-0 sm:scale-100"
                    x-transition:leave-end="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                    @click.away="showUpsellModal = false"
                    class="relative transform overflow-hidden rounded-2xl bg-white text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-lg">
                    <div class="bg-gradient-to-r from-emerald-500 to-teal-600 px-4 py-6 sm:px-6">
                        <div class="flex items-center gap-3 text-white">
                            <div class="rounded-full bg-white/20 p-2">
                                <svg class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7" />
                                </svg>
                            </div>
                            <div>
                                <h3 class="text-xl font-bold leading-6">Kirim Penawaran Spesial</h3>
                                <p class="text-emerald-100 text-xs mt-1">Maksimalkan potensi pendapatan dari mitra ini.
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="px-4 py-6 sm:px-6 space-y-4">
                        <div class="bg-gray-50 rounded-lg p-3 border border-gray-100">
                            <div class="text-xs text-gray-500 uppercase font-bold">Mitra Penerima</div>
                            <div class="font-bold text-gray-900" x-text="selectedUpsell?.workshop"></div>
                            <div class="text-sm text-gray-600" x-text="selectedUpsell?.owner"></div>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Pilih Jenis Promo</label>
                            <select
                                class="w-full rounded-lg border-gray-300 focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm shadow-sm">
                                <option>Diskon Langganan 20% (Recommended)</option>
                                <option>Akses Fitur Premium 7 Hari</option>
                                <option>Undangan Webinar Bisnis Eksklusif</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Pesan Personal
                                (Opsional)</label>
                            <textarea rows="3"
                                class="w-full rounded-lg border-gray-300 focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm shadow-sm"
                                placeholder="Tambahkan catatan khusus..."></textarea>
                        </div>
                    </div>
                    <div class="bg-gray-50 px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6">
                        <button type="button"
                            @click="$wire.sendUpsellOffer(selectedUpsell.workshop_id); showUpsellModal = false"
                            class="inline-flex w-full justify-center rounded-xl bg-emerald-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-emerald-500 sm:ml-3 sm:w-auto transition-colors">
                            Kirim Penawaran
                        </button>
                        <button type="button" @click="showUpsellModal = false"
                            class="mt-3 inline-flex w-full justify-center rounded-xl bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto transition-colors">
                            Batal
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- 3. Business Outlook section - Update Tawarkan Button to trigger modal --}}
    <div wire:loading.remove class="mt-8 bg-white rounded-2xl shadow-sm border border-gray-100 p-8" x-show="loaded">
        <div class="flex items-center gap-3 mb-8">
            <div class="p-2 bg-indigo-50 rounded-lg text-indigo-600">
                <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
            </div>
            <div>
                <h2 class="text-xl font-bold text-gray-900">Platform Business Outlook (SaaS)</h2>
                <p class="text-sm text-gray-500">Prediksi kesehatan bisnis BBI Hub & Peluang Pertumbuhan</p>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div class="p-6 bg-gray-50 rounded-xl border border-gray-100">
                <h3 class="font-bold text-gray-900 mb-1">Prediksi Pendapatan (MRR)</h3>
                <div class="flex items-baseline gap-2 mb-4">
                    <span class="text-3xl font-bold text-gray-900">Rp
                        {{ number_format($platformOutlook['mrr_forecast']['prediction'], 0, ',', '.') }}</span>
                </div>
                <div class="h-32">
                    <canvas id="mrrForecastChart"
                        data-chart-json="{{ json_encode($platformOutlook['mrr_forecast']['history'] ?? []) }}"
                        data-prediction="{{ $platformOutlook['mrr_forecast']['prediction'] ?? 0 }}"></canvas>
                </div>
            </div>
            <div class="p-6 bg-rose-50 rounded-xl border border-rose-100">
                <h3 class="font-bold text-rose-900 mb-1">Resiko Churn</h3>
                <div class="space-y-3 max-h-48 overflow-y-auto pr-2 custom-scrollbar">
                    @forelse($platformOutlook['churn_candidates'] as $risk)
                        <div class="bg-white p-3 rounded-lg shadow-sm border border-rose-100">
                            <div class="flex justify-between items-start">
                                <div>
                                    <div class="font-bold text-gray-900 text-sm">{{ $risk['name'] }}</div>
                                    <div class="text-[10px] text-gray-500">{{ $risk['owner'] ?? 'N/A' }}</div>
                                </div>
                                <div class="text-right">
                                    <div class="text-xs font-bold text-rose-600">Drop {{ $risk['drop_rate'] }}</div>
                                </div>
                            </div>
                            <div class="mt-2 text-[10px] text-gray-500 bg-rose-50 px-2 py-1 rounded flex justify-between">
                                <span>Vol: <strong>{{ $risk['prev_vol'] ?? 0 }}</strong> <span
                                        class="text-gray-400">-></span>
                                    <strong>{{ $risk['current_vol'] ?? 0 }}</strong></span>
                            </div>
                        </div>
                    @empty
                        <div class="text-center py-4 text-rose-400 text-sm">Tidak ada resiko.</div>
                    @endforelse
                </div>
            </div>
            <div class="p-6 bg-emerald-50 rounded-xl border border-emerald-100">
                <h3 class="font-bold text-emerald-900 mb-1">Peluang Upsell</h3>
                <div class="space-y-3 max-h-48 overflow-y-auto pr-2 custom-scrollbar">
                    @forelse($platformOutlook['upsell_candidates'] as $lead)
                        <div class="bg-white p-3 rounded-lg shadow-sm border border-emerald-100">
                            <div class="flex justify-between items-start">
                                <div>
                                    <div class="font-bold text-gray-900 text-sm">{{ $lead['workshop'] }}</div>
                                    <div class="text-[10px] text-gray-500">{{ $lead['owner'] ?? 'N/A' }}</div>
                                </div>
                                <div class="text-right">
                                    {{-- TRIGGER MODAL HERE --}}
                                    <button @click="selectedUpsell = {{ json_encode($lead) }}; showUpsellModal = true"
                                        class="text-[10px] bg-emerald-600 text-white px-2 py-0.5 rounded shadow hover:bg-emerald-700 transition-colors">Tawarkan</button>
                                </div>
                            </div>
                            <div class="mt-2 text-[10px] text-gray-500 flex items-center gap-1">
                                <svg class="w-3 h-3 text-emerald-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                                </svg>
                                <span>High Volume: <strong>{{ $lead['volume'] }}</strong> trx/bulan</span>
                            </div>
                        </div>
                    @empty
                        <div class="text-center py-4 text-emerald-500 text-sm">Belum ada peluang.</div>
                    @endforelse
                </div>
            </div>
        </div>
    </div>
</div>

@push('scripts')
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
        integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener('livewire:navigated', () => {
            console.log('[EIS] Livewire navigated event');
            initCharts();
        });
        document.addEventListener('DOMContentLoaded', () => {
            console.log('[EIS] DOMContentLoaded event');
            initCharts();
        });
        window.addEventListener('refresh-charts', () => {
            console.log('[EIS] refresh-charts event');
            initCharts();
        });

        function initCharts() {
            console.log('[EIS] initCharts() starting...');
            // Increased timeout to ensure Livewire data is fully loaded
            setTimeout(() => {
                console.log('[EIS] Initializing all charts now');
                initTopWorkshopsChart();
                initClvChartSafe();
                initSparklinesSafe();
                initMrrForecastChartSafe();
                initMap();
                console.log('[EIS] All charts initialized');
            }, 250); // Increased from 100ms to 250ms
        }

        window.addEventListener('init-workshop-chart', event => {
            setTimeout(() => initWorkshopDetailChart(), 300);
        });

        function initTopWorkshopsChart() {
            console.log('[EIS] initTopWorkshopsChart() called');
            const ctx = document.getElementById('topWorkshopsChart');
            if (!ctx) {
                console.warn('[EIS] Top Workshops chart canvas not found');
                return;
            }
            
            // Properly check if destroy exists before calling it
            if (window.topWorkshopsChart && typeof window.topWorkshopsChart.destroy === 'function') {
                console.log('[EIS] Destroying existing Top Workshops chart');
                window.topWorkshopsChart.destroy();
            }

            try {
                const rawData = JSON.parse(ctx.dataset.chartJson || '[]');
                console.log('[EIS] Top Workshops data:', 'Count:', rawData.length);
                
                const labels = rawData.map(d => d.name);
                const data = rawData.map(d => d.revenue);
                const ids = rawData.map(d => d.id);

                window.topWorkshopsChart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Revenue',
                            data: data,
                            backgroundColor: 'rgba(79, 70, 229, 0.8)',
                            borderRadius: 6
                        }]
                    },
                    options: {
                        indexAxis: 'y',
                        responsive: true,
                        maintainAspectRatio: false,
                        onClick: (e, activeEls) => {
                            if (activeEls.length === 0) return;
                            const index = activeEls[0].index;
                            @this.openWorkshopDetail(ids[index]);
                        }
                    }
                });
                console.log('[EIS] Top Workshops chart initialized successfully');
            } catch (error) {
                console.error('[EIS] Error initializing Top Workshops chart:', error);
            }
        }

        function initClvChartSafe() {
            console.log('[EIS] initClvChartSafe() called');
            const ctx = document.getElementById('clvBubbleChart');
            if (!ctx) {
                console.warn('[EIS] CLV Chart canvas not found');
                return;
            }

            if (window.clvChart) {
                console.log('[EIS] Destroying existing CLV chart');
                window.clvChart.destroy();
            }

            const rawData = JSON.parse(ctx.dataset.chartJson || '[]');
            console.log('[EIS] CLV Chart data:', rawData, 'Count:', rawData.length);

            if (rawData.length === 0) {
                console.warn('[EIS] CLV Chart: No data available');
                // Show empty state by creating chart with placeholder
                window.clvChart = new Chart(ctx, {
                    type: 'bubble',
                    data: {
                        datasets: [{
                            label: 'Pelanggan',
                            data: [],
                            backgroundColor: 'rgba(99, 102, 241, 0.6)',
                            borderColor: 'rgba(99, 102, 241, 1)'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: { enabled: false }
                        }
                    }
                });
                return;
            }

            try {
                window.clvChart = new Chart(ctx, {
                    type: 'bubble',
                    data: {
                        datasets: [{
                            label: 'Pelanggan',
                            data: rawData,
                            backgroundColor: 'rgba(99, 102, 241, 0.6)',
                            borderColor: 'rgba(99, 102, 241, 1)'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            x: {
                                title: { display: true, text: 'Frekuensi Transaksi' }
                            },
                            y: {
                                title: { display: true, text: 'Total Nilai (Rp)' }
                            }
                        }
                    }
                });
                console.log('[EIS] CLV Chart initialized successfully');
            } catch (error) {
                console.error('[EIS] Error initializing CLV chart:', error);
            }
        }

        function initMrrForecastChartSafe() {
            const ctx = document.getElementById('mrrForecastChart');
            if (!ctx) return;
            if (window.mrrChart) window.mrrChart.destroy();

            const rawData = JSON.parse(ctx.dataset.chartJson || '[]');
            const prediction = parseFloat(ctx.dataset.prediction || 0);

            const labels = rawData.map(d => d.label);
            const values = rawData.map(d => d.y);

            // Add prediction
            labels.push('Next Month');
            const historicalData = [...values, null];

            // Fix: Create array of nulls for previous months, leaving only the last history point and the new prediction point
            // This ensures the line connects from the last actual point to the prediction
            const predictedData = Array(Math.max(0, values.length - 1)).fill(null);
            if (values.length > 0) {
                predictedData.push(values[values.length - 1]);
            }
            predictedData.push(prediction);

            window.mrrChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        { label: 'History', data: historicalData, borderColor: '#4f46e5', tension: 0.3 },
                        { label: 'Forecast', data: predictedData, borderColor: '#9333ea', borderDash: [5, 5], tension: 0.3 }
                    ]
                },
                options: { responsive: true, maintainAspectRatio: false }
            });
        }

        function initSparklinesSafe() {
            console.log('[EIS] initSparklinesSafe() called');
            if (window.sparklineInstances) window.sparklineInstances.forEach(c => c.destroy());
            window.sparklineInstances = [];
            
            document.querySelectorAll('canvas[id^="sparkline-"]').forEach(canvas => {
                const data = JSON.parse(canvas.dataset.chart || '[]');
                const color = canvas.dataset.color || 'gray';
                const colors = { 
                    'emerald': '#10b981', 
                    'blue': '#3b82f6', 
                    'rose': '#f43f5e', 
                    'cyan': '#06b6d4',
                    'violet': '#8b5cf6',
                    'amber': '#f59e0b'
                };

                const lineColor = colors[color] || '#6b7280';

                const chart = new Chart(canvas, {
                    type: 'line',
                    data: {
                        labels: data.map((_, i) => i),
                        datasets: [{
                            data: data,
                            borderColor: lineColor,
                            backgroundColor: lineColor + '20', // Semi-transparent fill
                            pointRadius: 0,
                            borderWidth: 2,
                            fill: true,  // Enable area fill
                            tension: 0.4 // Smooth curves
                        }]
                    },
                    options: { 
                        responsive: true, 
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false }, // Remove 'undefined'
                            tooltip: { enabled: false }
                        },
                        scales: { 
                            x: { display: false }, 
                            y: { display: false } 
                        }
                    }
                });
                window.sparklineInstances.push(chart);
            });
            console.log('[EIS] Sparklines initialized:', window.sparklineInstances.length);
        }

        function initMap() {
            console.log('[EIS] initMap() called');
            const mapContainer = document.getElementById('marketMap');
            if (!mapContainer) {
                console.warn('[EIS] Map container not found');
                return;
            }
            
            if (window.marketMapInstance) {
                console.log('[EIS] Removing existing map instance');
                window.marketMapInstance.remove();
            }

            try {
                const map = L.map('marketMap').setView([-2.5489, 118.0149], 4);
                window.marketMapInstance = map;
                L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
                    attribution: '© OpenStreetMap contributors © CARTO'
                }).addTo(map);

                const cityStats = JSON.parse(mapContainer.dataset.chartJson || '[]');
                console.log('[EIS] Map data:', cityStats, 'Count:', cityStats.length);
                
                const cityCoords = {
                    'Surabaya': [-7.2575, 112.7521], 
                    'Jakarta': [-6.2088, 106.8456], 
                    'Bandung': [-6.9175, 107.6191],
                    'Medan': [3.5952, 98.6722], 
                    'Semarang': [-6.9667, 110.4167], 
                    'Makassar': [-5.1477, 119.4328],
                    'Denpasar': [-8.6705, 115.2126], 
                    'Yogyakarta': [-7.7956, 110.3695], 
                    'Malang': [-7.9666, 112.6326],
                    'Palembang': [-2.9760, 104.7754],
                    'Balikpapan': [-1.2379, 116.8529],
                    'Banjarmasin': [-3.3194, 114.5908],
                    'Pekanbaru': [0.5071, 101.4478],
                    'Manado': [1.4748, 124.8421]
                };

                let markersAdded = 0;
                cityStats.forEach((stat, index) => {
                    if (cityCoords[stat.city]) {
                        const demand = stat.demand || 0;
                        const supply = stat.supply || 0;
                        const radius = index < 5 ? 40000 : 15000;
                        const color = index < 5 ? '#ef4444' : '#94a3b8';
                        
                        L.circle(cityCoords[stat.city], {
                            color: color,
                            fillColor: color,
                            fillOpacity: 0.5,
                            radius: radius
                        })
                        .addTo(map)
                        .bindTooltip(`
                            <strong>${stat.city}</strong><br>
                            Demand: ${demand} requests<br>
                            Supply: ${supply} workshops
                        `, { permanent: false, direction: 'top' });
                        
                        markersAdded++;
                    } else {
                        console.warn(`[EIS] No coordinates found for city: ${stat.city}`);
                    }
                });
                
                console.log(`[EIS] Map initialized successfully. Added ${markersAdded} markers`);
                
                // Invalidate size to ensure proper rendering
                setTimeout(() => map.invalidateSize(), 100);
                
            } catch (error) {
                console.error('[EIS] Error initializing map:', error);
            }
        }

        function initWorkshopDetailChart() {
            const ctx = document.getElementById('workshopDetailChart');
            if (!ctx) return;
            if (window.detailChart) window.detailChart.destroy();

            const labels = JSON.parse(ctx.dataset.labels || '[]');
            const values = JSON.parse(ctx.dataset.values || '[]');
            window.detailChart = new Chart(ctx, {
                type: 'line',
                data: { labels: labels, datasets: [{ label: 'Revenue', data: values, borderColor: '#4f46e5' }] }
            });
        }
    </script>
@endpush