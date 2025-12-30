<div class="space-y-8" x-data="{ loaded: false }"
    x-init="setTimeout(() => { loaded = true; setTimeout(() => initCharts(), 1000); }, 500)">
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
                    Filter
                </button>

                {{-- Filter Dropdown --}}
                <div x-show="open" @click.away="open = false"
                    class="absolute right-0 mt-2 w-72 bg-white rounded-xl shadow-xl border border-gray-100 p-4 z-50 origin-top-right"
                    style="display: none;">
                    <h3 class="font-bold text-gray-900 mb-3">Pilih Periode</h3>
                    <div class="space-y-3">
                        <div>
                            <label class="block text-xs font-medium text-gray-500 mb-1">Bulan</label>
                            <select wire:model="selectedMonth"
                                class="w-full text-sm border-gray-300 rounded-lg focus:ring-indigo-500 focus:border-indigo-500">
                                @foreach(range(1, 12) as $m)
                                    <option value="{{ $m }}">{{ DateTime::createFromFormat('!m', $m)->format('F') }}
                                    </option>
                                @endforeach
                            </select>
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-gray-500 mb-1">Tahun</label>
                            <select wire:model="selectedYear"
                                class="w-full text-sm border-gray-300 rounded-lg focus:ring-indigo-500 focus:border-indigo-500">
                                @foreach(range(date('Y'), date('Y') - 2) as $y)
                                    <option value="{{ $y }}">{{ $y }}</option>
                                @endforeach
                            </select>
                        </div>
                        <button wire:click="applyFilter"
                            class="w-full py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium rounded-lg transition-colors">
                            Terapkan Filter
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
    {{-- Grid change: lg:grid-cols-3 to make cards wider as requested --}}
    <div wire:loading.remove class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3" x-show="loaded"
        x-transition:enter="transition ease-out duration-500" x-transition:enter-start="opacity-0 transform scale-95"
        x-transition:enter-end="opacity-100 transform scale-100">

        @foreach($scorecard as $index => $card)
            @php
                // Design Config based on ID
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

                // Tailwind classes map
                $bgClass = "bg-{$color}-50";
                $textClass = "text-{$color}-600";

                // Tooltip Positioning Logic (3-column grid)
                // If it's the 3rd item in a row (index 2, 5, 8...), align to right.
                // Or if it's the last item in a row on smaller screens.
                // We mainly care about lg breakpoint where grid is 3 cols.
                $isRightEdge = ($index + 1) % 3 === 0;
                $tooltipClass = $isRightEdge ? 'right-0 origin-top-right' : 'left-0 origin-top-left';
                $arrowClass = $isRightEdge ? 'right-2' : 'left-2';
            @endphp

            {{--
            FIX: Removed 'overflow-hidden' from here so Tooltip can pop out.
            Added group class for hover effects.
            Added hover:z-20 for Stacking Context fix.
            --}}
            <div
                class="relative rounded-2xl bg-white p-6 shadow-sm border border-gray-100 transition-all duration-300 hover:-translate-y-1 hover:shadow-lg hover:z-20 group">

                {{--
                FIX: Inner layer for Background Decoration.
                This has overflow-hidden to clip the circle, but is absolute/behind content.
                --}}
                <div class="absolute inset-0 overflow-hidden rounded-2xl pointer-events-none">
                    <div
                        class="absolute -right-6 -top-6 h-24 w-24 rounded-full {{ $bgClass }} opacity-50 transition-transform group-hover:scale-110">
                    </div>
                </div>

                <div class="relative z-10 flex justify-between items-start">
                    <div class="flex-1"> {{-- Added flex-1 to push icon to right --}}
                        <div class="flex items-start gap-2"> {{-- Changed items-center to items-start --}}
                            <span class="text-sm font-medium text-gray-500">{{ $card['name'] }}</span> {{-- Removed
                            line-clamp-1 --}}

                            {{-- Info Tooltip --}}
                            <div class="relative group/info cursor-help inline-block mt-0.5"> {{-- Added mt-0.5 for optical
                                alignment --}}
                                <svg class="w-4 h-4 text-gray-300 hover:text-gray-500 transition-colors" fill="none"
                                    viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                {{-- Tooltip Box: z-50 to float above everything --}}
                                <div
                                    class="absolute z-50 invisible w-64 p-3 mt-2 text-xs font-normal text-white bg-gray-900 rounded-lg opacity-0 {{ $tooltipClass }} group-hover/info:visible group-hover/info:opacity-100 transition-all duration-200 shadow-xl">
                                    {{ $card['description'] }}
                                    {{-- Arrow --}}
                                    <div class="absolute -top-1 {{ $arrowClass }} w-2 h-2 bg-gray-900 rotate-45"></div>
                                </div>
                            </div>
                        </div>

                        <div class="mt-2 flex flex-wrap items-baseline gap-2">
                            <span class="text-2xl font-bold text-gray-900 leading-tight">
                                {{ $card['unit'] === 'IDR' ? 'Rp' . number_format($card['value'], 0, ',', '.') : ($card['unit'] === '%' ? number_format($card['value'], 1) . '%' : number_format($card['value'])) }}
                            </span>

                            {{-- Status Pill --}}
                            @if($card['status'] === 'blue')
                                <span
                                    class="text-xs font-medium text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full flex items-center gap-1">
                                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd"
                                            d="M12 7a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0V8.414l-4.293 4.293a1 1 0 01-1.414 0L8 10.414l-4.293 4.293a1 1 0 01-1.414-1.414l5-5a1 1 0 011.414 0L11 10.586 14.586 7H12z"
                                            clip-rule="evenodd" />
                                    </svg>
                                    Strong
                                </span>
                            @elseif($card['status'] === 'green')
                                <span
                                    class="text-xs font-medium text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full flex items-center gap-1">
                                    <svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                                    </svg>
                                    On Track
                                </span>
                            @else
                                <span
                                    class="text-xs font-medium text-rose-600 bg-rose-50 px-2 py-0.5 rounded-full flex items-center gap-1">
                                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd"
                                            d="M10 18a8 8 0 100-16 8 8 0 000 16zm-1-4a1 1 0 112 0v-4a1 1 0 11-2 0v4zm1-9a1 1 0 100 2 1 1 0 000-2z"
                                            clip-rule="evenodd" />
                                    </svg>
                                    Review
                                </span>
                            @endif
                        </div>
                        <div class="mt-1 text-xs text-gray-400">Target: {{ number_format($card['target']) }}</div>
                    </div>

                    {{-- Icon Container --}}
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
                        @elseif($icon === 'credit-card')
                            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
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

                {{-- Sparkline Chart (Edge-to-Edge) --}}
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
                            {{-- Info Tooltip --}}
                            <div class="relative group/info cursor-help inline-block">
                                <svg class="w-4 h-4 text-gray-300 hover:text-gray-500 transition-colors" fill="none"
                                    viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <div
                                    class="absolute z-50 invisible w-64 p-3 mt-2 text-xs leading-relaxed text-white bg-gray-900 rounded-lg opacity-0 -right-1/2 group-hover/info:visible group-hover/info:opacity-100 transition-all duration-200 shadow-xl">
                                    Identifikasi segmen pelanggan berdasarkan Frekuensi Pembelian (Sumbu X) dan Total
                                    Nilai Uang (Sumbu Y). Pelanggan di kanan atas adalah 'Champions'.
                                </div>
                            </div>
                        </div>
                        <p class="text-sm text-gray-500 mt-1">Segmentasi berdasarkan Frekuensi vs Nominal Transaksi</p>
                    </div>
                </div>
                <div class="h-80 w-full relative">
                    <canvas id="clvBubbleChart"></canvas>
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

                {{-- Map Container --}}
                <div id="marketMap" class="w-full h-80 rounded-xl border border-gray-200 bg-gray-50 relative z-0"></div>

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

        </div> {{-- End CLV/Map Column (w-2/3) --}}

        {{-- Insight Panel (1/3 width on desktop) --}}
        <div class="flex flex-col gap-6 w-1/3">
            <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                <h3 class="text-lg font-bold text-gray-900 mb-6">Quick Insights</h3>

                <div class="space-y-6">
                    <div class="relative pl-4 border-l-4 border-indigo-500">
                        <div class="text-xs font-semibold text-indigo-500 uppercase tracking-wide">High Value Customers
                        </div>
                        <div class="text-3xl font-bold text-gray-900 mt-1">
                            {{ $clvAnalysis['summary']['high_value_count'] }}
                        </div>
                        <div class="text-sm text-gray-500 mt-1">Pelanggan dengan LTV > Rp 10 Juta</div>
                    </div>

                    <div class="relative pl-4 border-l-4 border-emerald-500">
                        <div class="text-xs font-semibold text-emerald-500 uppercase tracking-wide">Rata-rata LTV</div>
                        <div class="text-3xl font-bold text-gray-900 mt-1">Rp
                            {{ number_format($clvAnalysis['summary']['avg_ltv'], 0, ',', '.') }}
                        </div>
                        <div class="text-sm text-gray-500 mt-1">Pendapatan per pelanggan berbayar</div>
                    </div>
                </div>
            </div>

            <div
                class="bg-gradient-to-br from-indigo-600 to-purple-700 rounded-2xl shadow-lg p-6 text-white relative overflow-hidden">
                <div class="relative z-10">
                    <h4 class="font-bold text-lg mb-2">Rekomendasi AI</h4>
                    <p class="text-indigo-100 text-sm leading-relaxed">
                        Fokus retensi pada {{ $clvAnalysis['summary']['high_value_count'] }} pelanggan bernilai tinggi.
                        Pertimbangkan program loyalitas eksklusif untuk meningkatkan frekuensi transaksi mereka.
                    </p>
                </div>
                <div class="absolute -bottom-8 -right-8 w-32 h-32 bg-white opacity-10 rounded-full blur-2xl"></div>
            </div>
        </div>

    </div> {{-- End flex-row container (CLV/Map + Quick Insights) --}}

    {{-- 3. Operational Deep Dive (Drill-Down Capable) --}}
    <div wire:loading.remove
        class="mt-8 bg-white rounded-2xl shadow-sm border border-gray-100 p-8 relative overflow-hidden">

        {{-- Decorative Background --}}
        <div class="absolute top-0 right-0 w-64 h-64 bg-indigo-50 rounded-bl-full opacity-50 pointer-events-none">
        </div>

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
            {{-- Chart Section --}}
            <div class="lg:col-span-2">
                <div class="w-full relative" style="height: 320px; min-height: 320px;">
                    <canvas id="topWorkshopsChart"></canvas>
                </div>

            </div>

            {{-- Summary / Legend --}}
            <div class="space-y-6">
                <div class="bg-gray-50 rounded-xl p-5 border border-gray-100">
                    <h4 class="font-bold text-gray-900 text-sm mb-3">Highlight Performa</h4>
                    @if(count($topWorkshops) > 0)
                        <div class="flex items-center gap-4 mb-4">
                            <div class="w-12 h-12 rounded-full bg-yellow-100 flex items-center justify-center text-2xl">
                                🏆
                            </div>
                            <div>
                                <div class="text-xs text-gray-500 uppercase tracking-widest">Top Performer</div>
                                <div class="font-bold text-gray-900">{{ $topWorkshops[0]['name'] }}</div>
                                <div class="text-xs text-indigo-600 font-semibold">Rp
                                    {{ number_format($topWorkshops[0]['revenue'], 0, ',', '.') }}
                                </div>
                            </div>
                        </div>
                    @endif
                    <p class="text-xs text-gray-500 leading-relaxed">
                        Grafik disamping interaktif.
                        <span class="font-bold text-indigo-600">Klik salah satu bar</span> untuk membuka modal
                        detail
                        yang berisi tren pendapatan 6 bulan terakhir, layanan terlaris, dan rating kepuasan
                        pelanggan
                        spesifik untuk bengkel tersebut.
                    </p>
                </div>
            </div>
        </div>
    </div>

    {{-- Detail Modal --}}
    <div x-data="{ show: @entangle('showWorkshopModal') }" x-show="show" x-cloak
        class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">

        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            {{-- Backdrop --}}
            <div x-show="show" x-transition:enter="ease-out duration-300" x-transition:enter-start="opacity-0"
                x-transition:enter-end="opacity-100" x-transition:leave="ease-in duration-200"
                x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0"
                class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="$wire.closeWorkshopModal()"
                aria-hidden="true"></div>

            <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

            {{-- Modal Panel --}}
            <div x-show="show" x-transition:enter="ease-out duration-300"
                x-transition:enter-start="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                x-transition:enter-end="opacity-100 translate-y-0 sm:scale-100"
                x-transition:leave="ease-in duration-200"
                x-transition:leave-start="opacity-100 translate-y-0 sm:scale-100"
                x-transition:leave-end="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                class="inline-block align-bottom bg-white rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full">

                @if(!empty($workshopDetail))
                    <div class="bg-indigo-600 px-4 py-4 sm:px-6">
                        <div class="flex items-center justify-between">
                            <h3 class="text-lg leading-6 font-medium text-white" id="modal-title">
                                Workshop Deep Dive: {{ $workshopDetail['name'] }}
                            </h3>
                            <button type="button" class="text-indigo-200 hover:text-white" wire:click="closeWorkshopModal">
                                <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                        </div>
                        <p class="mt-1 text-sm text-indigo-200">
                            Owner: {{ $workshopDetail['owner_name'] }} | {{ $workshopDetail['address'] }}
                        </p>
                    </div>

                    <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                            {{-- Stats Cards --}}
                            <div class="space-y-4">
                                <div class="bg-gray-50 p-4 rounded-xl border border-gray-100">
                                    <div class="text-xs text-gray-500 uppercase tracking-wide">Total Revenue</div>
                                    <div class="text-2xl font-bold text-gray-900 mt-1">Rp
                                        {{ number_format($workshopDetail['total_revenue'], 0, ',', '.') }}
                                    </div>
                                </div>
                                <div class="bg-gray-50 p-4 rounded-xl border border-gray-100">
                                    <div class="text-xs text-gray-500 uppercase tracking-wide">Transactions</div>
                                    <div class="text-2xl font-bold text-gray-900 mt-1">
                                        {{ $workshopDetail['total_trx'] }}
                                    </div>
                                </div>
                                <div class="bg-gray-50 p-4 rounded-xl border border-gray-100">
                                    <div class="text-xs text-gray-500 uppercase tracking-wide">Avg Rating</div>
                                    <div class="flex items-center gap-1 mt-1">
                                        <span
                                            class="text-2xl font-bold text-gray-900">{{ $workshopDetail['rating'] }}</span>
                                        <svg class="w-5 h-5 text-amber-400" fill="currentColor" viewBox="0 0 20 20">
                                            <path
                                                d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                                        </svg>
                                    </div>
                                </div>
                            </div>

                            {{-- Trend Chart --}}
                            <div class="md:col-span-2">
                                <h4 class="font-bold text-gray-900 text-sm mb-3">Tren Pendapatan (6 Bulan Terakhir)</h4>
                                <div class="h-48 w-full">
                                    {{-- Pass data via data attribute --}}
                                    <canvas id="workshopDetailChart"
                                        data-labels="{{ json_encode(array_keys($workshopDetail['revenue_trend'] ?? [])) }}"
                                        data-values="{{ json_encode(array_values($workshopDetail['revenue_trend'] ?? [])) }}">
                                    </canvas>
                                </div>
                            </div>
                        </div>

                        <div class="mt-6 border-t border-gray-100 pt-4">
                            <h4 class="font-bold text-gray-900 text-sm mb-3">Top 5 Layanan Terlaris</h4>
                            <div class="space-y-2">
                                @foreach($workshopDetail['top_services'] as $idx => $service)
                                    <div class="flex items-center justify-between text-sm">
                                        <div class="flex items-center gap-3">
                                            <div
                                                class="w-6 h-6 rounded-full bg-indigo-50 text-indigo-600 flex items-center justify-center text-xs font-bold">
                                                {{ $idx + 1 }}
                                            </div>
                                            <span class="font-medium text-gray-700">{{ $service['name'] }}</span>
                                        </div>
                                        <span class="text-gray-500">{{ $service['count'] }} request</span>
                                    </div>
                                @endforeach
                            </div>
                        </div>
                    </div>

                    <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                        <button type="button" wire:click="closeWorkshopModal"
                            class="w-full inline-flex justify-center rounded-lg border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none sm:w-auto sm:text-sm">
                            Tutup
                        </button>
                    </div>
                @else
                    <div class="p-10 text-center">
                        <svg class="mx-auto h-12 w-12 text-gray-400 animate-spin" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
                            </circle>
                            <path class="opacity-75" fill="currentColor"
                                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                            </path>
                        </svg>
                        <h3 class="mt-2 text-sm font-medium text-gray-900">Memuat data...</h3>
                    </div>
                @endif
            </div>
        </div>
    </div>

    {{-- 3. Business Outlook (Platform Intelligence) --}}
    <div wire:loading.remove class="mt-8 bg-white rounded-2xl shadow-sm border border-gray-100 p-8" x-show="loaded"
        x-transition:enter="transition ease-out duration-700 delay-200"
        x-transition:enter-start="opacity-0 translate-y-4" x-transition:enter-end="opacity-100 translate-y-0">

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
            {{-- MRR Forecast --}}
            <div class="p-6 bg-gray-50 rounded-xl border border-gray-100">
                <h3 class="font-bold text-gray-900 mb-1">Prediksi Pendapatan (MRR)</h3>
                <p class="text-xs text-gray-500 mb-4">Proyeksi bulan depan berbasis Linear Regression</p>

                <div class="flex items-baseline gap-2 mb-4">
                    <span class="text-3xl font-bold text-gray-900">Rp
                        {{ number_format($platformOutlook['mrr_forecast']['prediction'], 0, ',', '.') }}</span>
                    @if($platformOutlook['mrr_forecast']['growth_rate'] > 0)
                        <span
                            class="text-xs font-bold text-emerald-600 bg-emerald-100 px-2 py-0.5 rounded-full">+{{ number_format($platformOutlook['mrr_forecast']['growth_rate'], 1) }}%</span>
                    @else
                        <span
                            class="text-xs font-bold text-rose-600 bg-rose-100 px-2 py-0.5 rounded-full">{{ number_format($platformOutlook['mrr_forecast']['growth_rate'], 1) }}%</span>
                    @endif
                </div>
                <div class="h-32">
                    <canvas id="mrrForecastChart"></canvas>
                </div>
            </div>

            {{-- Churn Risk --}}
            <div class="p-6 bg-rose-50 rounded-xl border border-rose-100">
                <h3 class="font-bold text-rose-900 mb-1">Resiko Churn (High Risk)</h3>
                <p class="text-xs text-rose-700 mb-4">Bengkel dengan penurunan aktivitas ekstrim (>50%)</p>

                <div class="space-y-3 max-h-48 overflow-y-auto pr-2 custom-scrollbar">
                    @forelse($platformOutlook['churn_candidates'] as $risk)
                        <div
                            class="bg-white p-3 rounded-lg shadow-sm border border-rose-100 flex justify-between items-center">
                            <div>
                                <div class="font-bold text-gray-900 text-sm">{{ $risk['name'] }}</div>
                                <div class="text-xs text-gray-500">{{ $risk['owner'] }}</div>
                            </div>
                            <div class="text-right">
                                <div class="text-xs font-bold text-rose-600">Drop {{ $risk['drop_rate'] }}</div>
                                <div class="text-[10px] text-gray-400">{{ $risk['prev_vol'] }} ->
                                    {{ $risk['current_vol'] }}
                                    trx
                                </div>
                            </div>
                        </div>
                    @empty
                        <div class="text-center py-4 text-rose-400 text-sm">Tidak ada bengkel beresiko saat ini.</div>
                    @endforelse
                </div>
            </div>

            {{-- Upsell Opportunities --}}
            <div class="p-6 bg-emerald-50 rounded-xl border border-emerald-100">
                <h3 class="font-bold text-emerald-900 mb-1">Peluang Upsell (Hot Leads)</h3>
                <p class="text-xs text-emerald-700 mb-4">Pengguna Free dengan volume transaksi tinggi</p>

                <div class="space-y-3 max-h-48 overflow-y-auto pr-2 custom-scrollbar">
                    @forelse($platformOutlook['upsell_candidates'] as $lead)
                        <div
                            class="bg-white p-3 rounded-lg shadow-sm border border-emerald-100 flex justify-between items-center">
                            <div>
                                <div class="font-bold text-gray-900 text-sm">{{ $lead['workshop'] }}</div>
                                <div class="text-xs text-gray-500">{{ $lead['owner'] }}</div>
                            </div>
                            <div class="text-right">
                                <div class="text-xs font-bold text-indigo-600">{{ $lead['volume'] }} Trx/mo</div>
                                <button
                                    class="mt-1 text-[10px] bg-emerald-600 text-white px-2 py-0.5 rounded hover:bg-emerald-700">Tawarkan
                                    Premium</button>
                            </div>
                        </div>
                    @empty
                        <div class="text-center py-4 text-emerald-500 text-sm">Belum ada kandidat upsell potensial.
                        </div>
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
        document.addEventListener('livewire:navigated', initCharts);
        document.addEventListener('DOMContentLoaded', initCharts);
        window.addEventListener('refresh-charts', initCharts); // Listen for Livewire event

        function initCharts() {
            console.log('Starting Chart Initialization (Safe Mode)...');

            // 1. Prioritize Main Chart (Drill-down)
            try {
                initTopWorkshopsChart();
            } catch (e) {
                console.error('CRITICAL: Top Workshops Chart failed', e);
            }

            // 2. Load Secondary Charts (Safe Versions)
            try { initClvChartSafe(); } catch (e) { console.warn('CLV Safe warning:', e); }
            try { initSparklinesSafe(); } catch (e) { console.warn('Sparklines Safe warning:', e); }
            try { initSegmentationChartSafe(); } catch (e) { console.warn('Segmentation Safe warning:', e); }
            try { initMrrForecastChartSafe(); } catch (e) { console.warn('MRR Safe warning:', e); }
            try { initMap(); } catch (e) { console.warn('Map Init failed:', e); }
        }

        // Listen for modal chart init event
        window.addEventListener('init-workshop-chart', event => {
            // Look for canvas inside modal after Livewire updates DOM
            setTimeout(() => {
                initWorkshopDetailChart();
            }, 300); // Slight delay for transition
        });

        function initTopWorkshopsChart() {
            console.log('[DRILL-DOWN] Starting initialization...');
            const ctx = document.getElementById('topWorkshopsChart');
            if (!ctx) {
                console.error('[DRILL-DOWN] Canvas topWorkshopsChart not found!');
                return;
            }
            console.log('[DRILL-DOWN] Canvas found:', ctx);

            const rawData = @json($topWorkshops);
            console.log('[DRILL-DOWN] Top Workshops Data:', rawData);

            if (!rawData || rawData.length === 0) {
                console.warn('No data for Top Workshops Chart');
                return;
            }


            // Safe destroy
            if (window.topWorkshopsChart && typeof window.topWorkshopsChart.destroy === 'function') {
                window.topWorkshopsChart.destroy();
            } else if (window.topWorkshopsChart) {
                window.topWorkshopsChart = null;
            }


            const labels = rawData.map(d => d.name);
            const data = rawData.map(d => d.revenue);
            const ids = rawData.map(d => d.id);

            window.topWorkshopsChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Total Pendapatan',
                        data: data,
                        backgroundColor: 'rgba(79, 70, 229, 0.8)', // Indigo-600
                        borderRadius: 6,
                        barThickness: 20
                    }]
                },
                options: {
                    indexAxis: 'y', // Horizontal Bar
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    let label = context.dataset.label || '';
                                    if (label) {
                                        label += ': ';
                                    }
                                    if (context.parsed.x !== null) {
                                        label += new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR' }).format(context.parsed.x);
                                    }
                                    return label;
                                },
                                afterBody: function () {
                                    return '\n(Klik untuk drill-down)';
                                }
                            }
                        }
                    },
                    onClick: (e, activeEls) => {
                        if (activeEls.length === 0) return;

                        const index = activeEls[0].index;
                        const workshopId = ids[index];

                        // Trigger Livewire Method
                        @this.openWorkshopDetail(workshopId);
                    },
                    onHover: (event, chartElement) => {
                        event.native.target.style.cursor = chartElement[0] ? 'pointer' : 'default';
                    },
                    scales: {
                        x: {
                            grid: { display: false },
                            ticks: {
                                callback: function (value) {
                                    return 'Rp ' + (value / 1000000).toFixed(0) + 'jt';
                                }
                            }
                        },
                        y: {
                            grid: { display: false }
                        }
                    }
                }
            });
        }



        // ... existing charts ...

        function initMrrForecastChartSafe() {
            const ctx = document.getElementById('mrrForecastChart');
            if (!ctx) return;

            if (window.mrrChart && typeof window.mrrChart.destroy === 'function') {
                window.mrrChart.destroy();
            } else if (window.mrrChart) {
                window.mrrChart = null;
            }

            const rawData = @json($platformOutlook['mrr_forecast']['history'] ?? []);
            const labels = rawData.map(d => d.label);
            const values = rawData.map(d => d.y);

            // Add Prediction Point
            const predictedVal = @json($platformOutlook['mrr_forecast']['prediction'] ?? 0);
            labels.push('Next Month (Pred)');
            // Pad values with null for historical line, add prediction at end
            // Actually for simplicity, just append to array
            const historicalData = [...values, null];
            const predictedData = Array(values.length).fill(null);
            predictedData.push(values[values.length - 1]); // Connect lines
            predictedData.push(predictedVal);

            window.mrrChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: 'History',
                            data: historicalData,
                            borderColor: '#4f46e5', // Indigo
                            backgroundColor: '#4f46e5',
                            tension: 0.3
                        },
                        {
                            label: 'AI Forecast',
                            data: predictedData,
                            borderColor: '#9333ea', // Purple
                            borderDash: [5, 5],
                            backgroundColor: '#9333ea',
                            pointStyle: 'star',
                            pointRadius: 6
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } }, // Compact
                    scales: {
                        x: { display: false },
                        y: {
                            display: true,
                            ticks: {
                                callback: (val) => (val / 1000000).toFixed(0) + 'jt' // Abbreviate Millions
                            }
                        }
                    }
                }
            });
        }

        // ... existing functions ...


        function initSegmentationChartSafe() {
            const ctx = document.getElementById('segmentationChart');
            if (!ctx) return;

            // Safe Destroy
            if (window.segmentationChart && typeof window.segmentationChart.destroy === 'function') {
                window.segmentationChart.destroy();
            } else if (window.segmentationChart) {
                window.segmentationChart = null;
            }

            // Check for empty data to avoid Chart.js errors
            const rawData = @json($customerSegmentation['segments'] ?? []);
            if (!rawData || Object.keys(rawData).length === 0) {
                console.warn('Skipping Segmentation Chart: No Data');
                return;
            }

            const labels = Object.keys(rawData);
            const values = Object.values(rawData);

            const colors = {
                'Champions': '#10b981',
                'Loyal Customers': '#3b82f6',
                'Potential Loyalists': '#8b5cf6',
                'New Customers': '#06b6d4',
                'At Risk': '#f59e0b',
                'Hibernating': '#64748b',
                'Others': '#d1d5db'
            };
            const bgColors = labels.map(label => colors[label] || '#9ca3af');

            window.segmentationChart = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: labels,
                    datasets: [{
                        data: values,
                        backgroundColor: bgColors,
                        borderWidth: 0,
                        hoverOffset: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '75%',
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: 'rgba(17, 24, 39, 0.9)',
                            padding: 12,
                            cornerRadius: 8,
                            titleFont: { size: 13 },
                            bodyFont: { size: 12 },
                            callbacks: {
                                label: function (context) {
                                    const label = context.label || '';
                                    const val = context.raw;
                                    const total = context.chart._metasets[context.datasetIndex].total;
                                    const percentage = ((val / total) * 100).toFixed(1) + '%';
                                    return `${label}: ${val} (${percentage})`;
                                }
                            }
                        }
                    }
                }
            });
        }

        function initSparklinesSafe() {
            if (window.sparklineInstances) {
                window.sparklineInstances.forEach(chart => chart.destroy());
            }
            window.sparklineInstances = [];

            // Select all canvases matching pattern
            const canvases = document.querySelectorAll('canvas[id^="sparkline-"]');

            canvases.forEach((canvas) => {
                const chartData = JSON.parse(canvas.dataset.chart);
                const colorName = canvas.dataset.color || 'gray';

                // Simple map for Tailwind Colors to Hex
                const colors = {
                    'emerald': '#10b981', 'blue': '#2563eb', 'cyan': '#06b6d4',
                    'violet': '#8b5cf6', 'amber': '#f59e0b', 'rose': '#f43f5e', 'gray': '#6b7280'
                };
                const hex = colors[colorName] || '#6b7280';

                const chart = new Chart(canvas, {
                    type: 'line',
                    data: {
                        labels: chartData.map((_, i) => i),
                        datasets: [{
                            data: chartData,
                            borderColor: hex,
                            backgroundColor: hex + '1A', // 10% opacity
                            borderWidth: 2,
                            pointRadius: 0,
                            pointHoverRadius: 3,
                            fill: true,
                            tension: 0.4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { display: false }, tooltip: { enabled: false } },
                        scales: {
                            x: { display: false },
                            y: { display: false, min: Math.min(...chartData) * 0.9 }
                        },
                        layout: { padding: 0 }
                    }
                });
                window.sparklineInstances.push(chart);
            });
        }

        function initClvChartSafe() {
            const ctx = document.getElementById('clvBubbleChart');
            if (!ctx) return;

            if (window.clvChart && typeof window.clvChart.destroy === 'function') {
                window.clvChart.destroy();
            } else if (window.clvChart) {
                window.clvChart = null;
            }

            const rawData = @json($clvAnalysis['scatter'] ?? []);

            const data = {
                datasets: [{
                    label: 'Pelanggan',
                    data: rawData,
                    backgroundColor: 'rgba(99, 102, 241, 0.6)',
                    borderColor: 'rgba(99, 102, 241, 1)',
                    borderWidth: 1,
                    hoverBackgroundColor: 'rgba(244, 63, 94, 0.8)',
                    hoverBorderColor: 'rgba(244, 63, 94, 1)'
                }]
            };

            window.clvChart = new Chart(ctx, {
                type: 'bubble',
                data: data,
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: 'rgba(17, 24, 39, 0.9)',
                            padding: 12,
                            cornerRadius: 8,
                            titleFont: { size: 13 },
                            bodyFont: { size: 12 },
                            callbacks: {
                                label: function (context) {
                                    const v = context.raw;
                                    return `Freq: ${v.x} | Value: Rp ${new Intl.NumberFormat('id-ID').format(v.y)}`;
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            title: { display: true, text: 'Frekuensi Pembelian', font: { weight: 'bold' } },
                            beginAtZero: true,
                            grid: { borderDash: [2, 2] }
                        },
                        y: {
                            title: { display: true, text: 'Total Nilai (IDR)', font: { weight: 'bold' } },
                            beginAtZero: true,
                            grid: { borderDash: [2, 2] }
                        }
                    }
                }
            });
        }
    </script>


    <script>
        function initMap() {
            const mapContainer = document.getElementById('marketMap');
            if (!mapContainer) return;

            // Prevent re-initialization
            if (window.marketMapInstance) {
                window.marketMapInstance.remove();
            }

            // Coordinates for major Indonesian cities
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
                'Palembang': [-2.9904, 104.7563],
                'Bogor': [-6.5971, 106.8060],
                'Batam': [1.1085, 104.0450],
                'Balikpapan': [-1.2379, 116.8529]
            };

            // Initialize Map centered on Indonesia
            const map = L.map('marketMap').setView([-2.5489, 118.0149], 5);
            window.marketMapInstance = map;

            // Light Mode Tiles (CartoDB Positron) - Clean & Professional
            L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
                subdomains: 'abcd',
                maxZoom: 19
            }).addTo(map);

            // All Workshops Data
            const allWorkshops = @json($allWorkshops);

            // Group workshops by city and sum revenue
            const cityData = {};
            allWorkshops.forEach(workshop => {
                const city = workshop.city;
                if (!cityData[city]) {
                    cityData[city] = {
                        city: city,
                        totalRevenue: 0,
                        workshopCount: 0,
                        workshops: []
                    };
                }
                cityData[city].totalRevenue += workshop.revenue;
                cityData[city].workshopCount++;
                cityData[city].workshops.push(workshop);
            });

            // Convert to array and sort by revenue
            const citiesArray = Object.values(cityData).sort((a, b) => b.totalRevenue - a.totalRevenue);

            // Identify top 5 cities
            const top5Cities = citiesArray.slice(0, 5).map(c => c.city);

            citiesArray.forEach(cityInfo => {
                const coords = cityCoords[cityInfo.city];
                if (coords) {
                    const isTop5 = top5Cities.includes(cityInfo.city);

                    // Marker size based on whether it's top 5
                    const radius = isTop5 ? 25000 : 10000;

                    // Color based on ranking
                    let color = '#94a3b8'; // gray for regular
                    if (isTop5) {
                        const index = top5Cities.indexOf(cityInfo.city);
                        const colors = ['#ef4444', '#f59e0b', '#10b981', '#3b82f6', '#8b5cf6'];
                        color = colors[index];
                    }

                    const circle = L.circle(coords, {
                        color: color,
                        fillColor: color,
                        fillOpacity: isTop5 ? 0.6 : 0.4,
                        radius: radius,
                        weight: isTop5 ? 3 : 1
                    }).addTo(map);

                    // Tooltip Content
                    const tooltipContent = `
                            <div class="p-2">
                                <h4 class="font-bold text-sm">${cityInfo.city} ${isTop5 ? '⭐' : ''}</h4>
                                <div class="text-xs text-gray-600 mt-1">
                                    Total Revenue: <span class="font-bold text-indigo-600">Rp ${(cityInfo.totalRevenue / 1000000).toFixed(1)}M</span>
                                </div>
                                <div class="text-[10px] text-gray-500 mt-1">
                                    ${cityInfo.workshopCount} bengkel
                                </div>
                            </div>
                        `;
                    circle.bindPopup(tooltipContent);

                    // Auto-open popup for #1 city
                    if (cityInfo === citiesArray[0]) {
                        circle.openPopup();
                    }
                }
            });
        }
    </script>

    <script>
        // Separate script block to handle the dynamic data part for modal
        function initWorkshopDetailChart() {
            const ctx = document.getElementById('workshopDetailChart');
            if (!ctx) return;

            // Destroy existing if any
            if (window.detailChart) window.detailChart.destroy();

            const labels = JSON.parse(ctx.dataset.labels || '[]');
            const values = JSON.parse(ctx.dataset.values || '[]');

            window.detailChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Revenue',
                        data: values,
                        borderColor: '#4f46e5',
                        backgroundColor: 'rgba(79, 70, 229, 0.1)',
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function (value) {
                                    return (value / 1000000).toFixed(1) + 'jt';
                                }
                            }
                        }
                    }
                }
            });
        }
    </script>
@endpush