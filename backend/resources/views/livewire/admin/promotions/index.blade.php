<div wire:key="promotions-root" class="w-full px-2 lg:px-4 space-y-6">

  {{-- PAGE TITLE + ACTIONS --}}
  <div class="flex flex-wrap items-center gap-3">
    <div>
      <h1 class="text-2xl font-bold text-neutral-800">Manajemen Banner</h1>
      <div class="text-neutral-500">Kelola banner untuk berbagai penempatan platform</div>
    </div>
    <div class="ms-auto flex items-center gap-2">
      <button wire:click="refresh" type="button"
        class="inline-flex items-center gap-2 rounded-lg border px-3 py-2 hover:bg-neutral-50 transition-colors">
        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
        Refresh
      </button>
    </div>
  </div>

  {{-- BANNER SLOTS BY GROUPS --}}
  @foreach($slotGroups as $groupKey => $group)
    <div class="rounded-2xl border bg-white overflow-hidden">
      {{-- GROUP HEADER --}}
      <div class="px-6 py-4 border-b bg-gradient-to-r from-neutral-50 to-white">
        <div class="flex items-center gap-3">
          {{-- Heroicon --}}
          @if($group['icon'] === 'device-phone-mobile')
            <svg class="h-6 w-6 text-neutral-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
            </svg>
          @elseif($group['icon'] === 'user')
            <svg class="h-6 w-6 text-neutral-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
          @elseif($group['icon'] === 'chart-bar')
            <svg class="h-6 w-6 text-neutral-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
          @elseif($group['icon'] === 'computer-desktop')
            <svg class="h-6 w-6 text-neutral-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
            </svg>
          @elseif($group['icon'] === 'squares-2x2')
            <svg class="h-6 w-6 text-neutral-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M3 10h8V2H3v8zm10 0h8V2h-8v8zM3 22h8v-8H3v8zm10 0h8v-8h-8v8z" />
            </svg>
          @endif

          <div class="flex-1">
            <h2 class="text-lg font-semibold text-neutral-800">{{ $group['label'] }}</h2>
            @if(isset($group['coming_soon']) && $group['coming_soon'])
              <span
                class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-amber-100 text-amber-800 mt-1">
                Coming Soon
              </span>
            @endif
          </div>
        </div>
      </div>

      {{-- SLOTS GRID --}}
      <div class="p-6">
        <div
          class="grid grid-cols-1 {{ count($bannersBySlot[$groupKey]) === 1 && str_contains($group['icon'], 'user') ? 'md:grid-cols-1 max-w-xs' : (count($bannersBySlot[$groupKey]) <= 3 ? 'md:grid-cols-3' : 'md:grid-cols-3 lg:grid-cols-3') }} gap-4">
          @foreach($bannersBySlot[$groupKey] as $slotData)
            @php
              $isComingSoon = isset($group['coming_soon']) && $group['coming_soon'];
              // Character is square, website subs are 4:3, hero is wide, promo banners are square, owner is 2:1
              $aspectClass = 'aspect-square'; // default square
              if (str_contains($slotData['slot'], 'website_landing_hero')) {
                $aspectClass = 'aspect-[16/5]';
              } elseif (str_contains($slotData['slot'], 'website_landing_sub')) {
                $aspectClass = 'aspect-[4/3]';
              } elseif (str_contains($slotData['slot'], 'owner_dashboard')) {
                $aspectClass = 'aspect-[2/1]';
              }
            @endphp

            <div class="relative group">
              {{-- EMPTY STATE --}}
              @if($slotData['is_available'])
                <div class="border-2 border-dashed border-neutral-300 rounded-xl bg-gradient-to-br from-white to-neutral-50 
                                              {{ $aspectClass }}
                                              {{ $isComingSoon ? 'opacity-50 cursor-not-allowed' : 'hover:border-neutral-400 hover:bg-neutral-50 transition-all cursor-pointer' }}
                                              flex flex-col items-center justify-center p-6">

                  {{-- Upload Icon --}}
                  <svg class="h-12 w-12 text-neutral-400 mb-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                  </svg>

                  <p class="text-sm font-medium text-neutral-600 mb-1">
                    {{ str_replace(['admin_homepage_promo_', 'admin_homepage_', 'website_landing_sub_', 'website_landing_', 'owner_dashboard_banner_'], ['Slot ', 'Slot ', 'Slot ', '', 'Slot '], $slotData['slot']) }}
                  </p>

                  <p class="text-xs text-neutral-500 mb-4">Recommended Size:</p>
                  <p class="text-sm font-bold text-neutral-700 mb-4">
                    {{ $slotData['recommended_width'] }} × {{ $slotData['recommended_height'] }} px
                  </p>

                  @if(!$isComingSoon)
                    <button type="button" wire:click="openCreate"
                      class="inline-flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors text-sm font-medium">
                      <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                      </svg>
                      Upload Banner
                    </button>
                  @endif
                </div>

                {{-- FILLED STATE --}}
              @else
                @php
                  $banner = $slotData['banner'];
                  $imgUrl = $banner->banner_url ?? $banner->getFirstMediaUrl('banner') ?? asset('images/placeholder.svg');
                @endphp

                <div class="relative rounded-xl overflow-hidden shadow-md 
                                              {{ $aspectClass }}
                                              group-hover:shadow-xl transition-shadow">

                  {{-- Banner Image --}}
                  <img src="{{ $imgUrl }}" alt="{{ $banner->title }}" class="w-full h-full object-cover">

                  {{-- Overlay Gradient --}}
                  <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent"></div>

                  {{-- Status Badge --}}
                  <div class="absolute top-3 right-3">
                    @php
                      $status = $banner->status ?? 'draft';
                      $statusColors = [
                        'active' => 'bg-green-500',
                        'draft' => 'bg-amber-500',
                        'expired' => 'bg-red-500',
                      ];
                      $statusColor = $statusColors[$status] ?? 'bg-neutral-500';
                    @endphp
                    <span
                      class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium text-white {{ $statusColor }}">
                      {{ ucfirst($status) }}
                    </span>
                  </div>

                  {{-- Bottom Info --}}
                  <div class="absolute bottom-0 left-0 right-0 p-4">
                    <h3 class="text-white font-semibold text-sm mb-1 line-clamp-1">{{ $banner->title }}</h3>
                    <p class="text-white/80 text-xs">
                      {{ $slotData['recommended_width'] }} × {{ $slotData['recommended_height'] }} px
                      @if($banner->updated_at)
                        • {{ $banner->updated_at->diffForHumans() }}
                      @endif
                    </p>
                  </div>

                  {{-- Action Buttons (Show on Hover) --}}
                  <div
                    class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                    {{-- View --}}
                    <button type="button" class="p-3 bg-white rounded-full hover:bg-neutral-100 transition-colors shadow-lg"
                      title="Lihat Detail">
                      <svg class="h-5 w-5 text-neutral-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                      </svg>
                    </button>

                    {{-- Edit --}}
                    <button type="button" wire:click="edit({{ $banner->id }})"
                      class="p-3 bg-white rounded-full hover:bg-neutral-100 transition-colors shadow-lg" title="Edit Banner">
                      <svg class="h-5 w-5 text-neutral-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </button>

                    {{-- Delete --}}
                    <button type="button" wire:click="delete({{ $banner->id }})"
                      wire:confirm="Yakin ingin menghapus banner ini?"
                      class="p-3 bg-red-600 rounded-full hover:bg-red-700 transition-colors shadow-lg" title="Hapus Banner">
                      <svg class="h-5 w-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </div>
                </div>
              @endif
            </div>
          @endforeach
        </div>
      </div>
    </div>
  @endforeach

</div>