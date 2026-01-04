<div class="relative" x-data="{ open: false }" @click.away="open = false">
    {{-- Bell Button --}}
    <button @click="open = !open"
        class="relative rounded-full p-2 text-gray-500 hover:bg-gray-50 hover:text-gray-700 transition-colors"
        title="Notifikasi">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="h-5 w-5">
            <path d="M14.25 18.5a2.25 2.25 0 1 1-4.5 0h4.5Z" />
            <path
                d="M5 10.75a7 7 0 1 1 14 0v3.318l1.106 1.658A1 1 0 0 1 19.25 17H4.75a1 1 0 0 1-.856-1.574L5 14.068v-3.318Z" />
        </svg>

        @if($unreadCount > 0)
            <span
                class="absolute -top-1 -right-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-600 text-xs font-bold text-white shadow-sm">
                {{ $unreadCount > 9 ? '9+' : $unreadCount }}
            </span>
        @endif
    </button>

    {{-- Dropdown --}}
    <div x-show="open" x-transition:enter="transition ease-out duration-200"
        x-transition:enter-start="transform opacity-0 scale-95" x-transition:enter-end="transform opacity-100 scale-100"
        x-transition:leave="transition ease-in duration-75" x-transition:leave-start="transform opacity-100 scale-100"
        x-transition:leave-end="transform opacity-0 scale-95"
        class="absolute right-0 top-full mt-2 w-96 rounded-xl bg-white shadow-xl border border-gray-100 z-50"
        style="display: none;">

        {{-- Header --}}
        <div class="flex items-center justify-between border-b border-gray-100 px-4 py-3">
            <h3 class="text-sm font-semibold text-gray-900">Notifikasi</h3>
            @if($unreadCount > 0)
                <button wire:click="markAllAsRead"
                    class="text-xs font-medium text-red-600 hover:text-red-700 hover:underline">
                    Tandai Semua Dibaca
                </button>
            @endif
        </div>

        {{-- Notifications List --}}
        <div class="max-h-96 overflow-y-auto">
            @forelse($notifications as $notification)
                <a href="{{ $notification['url'] }}" wire:click="markAsRead('{{ $notification['id'] }}')"
                    class="block border-b border-gray-50 px-4 py-3 hover:bg-gray-50 transition-colors">
                    <div class="flex items-start gap-3">
                        {{-- Icon --}}
                        <div class="mt-0.5 flex-shrink-0">
                            @if($notification['type'] === 'workshop_verification')
                                <div
                                    class="flex h-10 w-10 items-center justify-center rounded-full bg-yellow-100 text-yellow-600">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                        stroke="currentColor" class="w-5 h-5">
                                        <path stroke-linecap="round" stroke-linejoin="round"
                                            d="M13.5 21v-7.5a.75.75 0 0 1 .75-.75h3a.75.75 0 0 1 .75.75V21m-4.5 0H2.36m11.14 0H18m0 0h3.64m-1.39 0V9.349M3.75 21V9.349m0 0a3.001 3.001 0 0 0 3.75-.615A2.993 2.993 0 0 0 9.75 9.75c.896 0 1.7-.393 2.25-1.016a2.993 2.993 0 0 0 2.25 1.016c.896 0 1.7-.393 2.25-1.015a3.001 3.001 0 0 0 3.75.614m-16.5 0a3.004 3.004 0 0 1-.621-4.72l1.189-1.19A1.5 1.5 0 0 1 5.378 3h13.243a1.5 1.5 0 0 1 1.06.44l1.19 1.189a3 3 0 0 1-.621 4.72M6.75 18h3.75a.75.75 0 0 0 .75-.75V13.5a.75.75 0 0 0-.75-.75H6.75a.75.75 0 0 0-.75.75v3.75c0 .414.336.75.75.75Z" />
                                    </svg>
                                </div>
                            @elseif($notification['type'] === 'new_report')
                                <div
                                    class="flex h-10 w-10 items-center justify-center rounded-full bg-indigo-100 text-indigo-600">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                        stroke="currentColor" class="w-5 h-5">
                                        <path stroke-linecap="round" stroke-linejoin="round"
                                            d="M10.34 15.84c-.688-.06-1.386-.09-2.09-.09H7.5a4.5 4.5 0 110-9h.75c.704 0 1.402-.03 2.09-.09m0 9.18c.253.962.584 1.892.985 2.783.247.55.06 1.21-.463 1.511l-.657.38c-.551.318-1.26.117-1.527-.461a20.845 20.845 0 01-1.44-4.282m3.102.069a18.03 18.03 0 01-.59-4.59c0-1.586.205-3.124.59-4.59m0 9.18a23.848 23.848 0 018.835 2.535M10.34 6.66a23.847 23.847 0 008.835-2.535m0 0A23.74 23.74 0 0018.795 3m.38 1.125a23.91 23.91 0 011.014 5.395m-1.014 8.855c-.118.38-.245.754-.38 1.125m.38-1.125a23.91 23.91 0 001.014-5.395m0-3.467a23.849 23.849 0 010 3.467m0-3.467a23.849 23.849 0 000 3.467" />
                                    </svg>
                                </div>
                            @else
                                <div class="flex h-10 w-10 items-center justify-center rounded-full bg-gray-100 text-gray-600">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                        stroke="currentColor" class="w-5 h-5">
                                        <path stroke-linecap="round" stroke-linejoin="round"
                                            d="M14.857 17.082a23.848 23.848 0 005.454-1.31A8.967 8.967 0 0118 9.75v-.7V9A6 6 0 006 9v.75a8.967 8.967 0 01-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 01-5.714 0m5.714 0a3 3 0 11-5.714 0" />
                                    </svg>
                                </div>
                            @endif
                        </div>

                        {{-- Content --}}
                        <div class="flex-1 min-w-0">
                            <p class="text-sm font-medium text-gray-900">{{ $notification['message'] }}</p>
                            @if($notification['workshop_name'])
                                <p class="text-xs text-gray-500 mt-0.5">{{ $notification['workshop_name'] }}</p>
                            @endif
                            <p class="text-xs text-gray-400 mt-1">{{ $notification['created_at'] }}</p>
                        </div>

                        {{-- Unread Indicator --}}
                        <div class="mt-1.5 flex-shrink-0">
                            <div class="h-2 w-2 rounded-full bg-blue-600"></div>
                        </div>
                    </div>
                </a>
            @empty
                <div class="px-4 py-8 text-center">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                        stroke="currentColor" class="mx-auto h-12 w-12 text-gray-300">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M14.857 17.082a23.848 23.848 0 005.454-1.31A8.967 8.967 0 0118 9.75v-.7V9A6 6 0 006 9v.75a8.967 8.967 0 01-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 01-5.714 0m5.714 0a3 3 0 11-5.714 0" />
                    </svg>
                    <p class="mt-2 text-sm text-gray-500">Tidak ada notifikasi</p>
                </div>
            @endforelse
        </div>
    </div>
</div>

@push('scripts')
    <script>
        // Real-time notification updates via Livewire Echo
        if (window.Echo) {
            window.Echo.private('App.Models.User.{{ auth()->id() }}')
                .listen('.Illuminate\\Notifications\\Events\\BroadcastNotificationCreated', (e) => {
                    console.log('New notification received:', e);
                    // Reload notifications in Livewire component
                    Livewire.dispatch('notificationReceived');
                });
        }
    </script>
@endpush