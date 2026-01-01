<div class="w-full px-2 lg:px-4 space-y-5">

    {{-- Back + Title --}}
    <div class="mb-4 flex items-center justify-between">
        <a href="{{ route('admin.promotions.index') }}"
            class="inline-flex items-center gap-1 text-sm text-neutral-500 hover:text-neutral-700">
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none">
                <path d="M15 19 8 12l7-7" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                    stroke-linejoin="round" />
            </svg>
            <span>Kembali</span>
        </a>
    </div>

    <div class="mb-6">
        <h1 class="text-2xl font-semibold text-neutral-900">Detail Banner</h1>
        <p class="mt-1 text-sm text-neutral-500">
            Informasi lengkap dari banner ini.
        </p>
    </div>

    <div class="space-y-6">
        {{-- Banner Image --}}
        <div class="rounded-2xl border border-neutral-200 bg-white p-6 shadow-sm">
            <h2 class="text-base font-semibold text-neutral-900 mb-4">Preview Banner</h2>

            @if($imageUrl)
                <div class="flex justify-center">
                    <img src="{{ $imageUrl }}" alt="{{ $promotion->title }}"
                        class="max-h-96 rounded-xl border border-neutral-300 object-contain shadow-md">
                </div>

                <div class="mt-4 flex items-center justify-center gap-4 text-sm text-neutral-600">
                    <span class="flex items-center gap-1">
                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                        </svg>
                        {{ $promotion->image_width ?? '-' }} × {{ $promotion->image_height ?? '-' }} px
                    </span>
                </div>
            @else
                <div class="flex flex-col items-center justify-center rounded-xl bg-neutral-100 py-12 text-neutral-500">
                    <svg class="h-12 w-12 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    <p class="text-sm">Tidak ada gambar</p>
                </div>
            @endif
        </div>

        {{-- Banner Info --}}
        <div class="rounded-2xl border border-neutral-200 bg-white p-6 shadow-sm space-y-4">
            <h2 class="text-base font-semibold text-neutral-900">Informasi Banner</h2>

            <div class="grid gap-4 md:grid-cols-2">
                <div>
                    <label class="text-xs font-medium text-neutral-500 uppercase tracking-wide">Judul</label>
                    <p class="mt-1 text-sm text-neutral-900">{{ $promotion->title }}</p>
                </div>

                <div>
                    <label class="text-xs font-medium text-neutral-500 uppercase tracking-wide">Status</label>
                    <div class="mt-1">
                        @if($promotion->status === 'active')
                            <span
                                class="inline-flex items-center gap-1 rounded-full bg-emerald-100 px-2.5 py-0.5 text-xs font-medium text-emerald-800">
                                <span class="h-1.5 w-1.5 rounded-full bg-emerald-600"></span>
                                Aktif
                            </span>
                        @else
                            <span
                                class="inline-flex items-center gap-1 rounded-full bg-neutral-100 px-2.5 py-0.5 text-xs font-medium text-neutral-800">
                                <span class="h-1.5 w-1.5 rounded-full bg-neutral-600"></span>
                                Draft
                            </span>
                        @endif
                    </div>
                </div>

                <div class="md:col-span-2">
                    <label class="text-xs font-medium text-neutral-500 uppercase tracking-wide">Deskripsi</label>
                    <p class="mt-1 text-sm text-neutral-700">{{ $promotion->description ?? '-' }}</p>
                </div>

                <div>
                    <label class="text-xs font-medium text-neutral-500 uppercase tracking-wide">Slot Banner</label>
                    <p class="mt-1 text-sm text-neutral-900">{{ $sizeInfo['label'] }}</p>
                </div>

                <div>
                    <label class="text-xs font-medium text-neutral-500 uppercase tracking-wide">Ukuran
                        Rekomendasi</label>
                    <p class="mt-1 text-sm text-neutral-900">{{ $sizeInfo['width'] }} × {{ $sizeInfo['height'] }} px</p>
                </div>

                <div>
                    <label class="text-xs font-medium text-neutral-500 uppercase tracking-wide">Tanggal Mulai</label>
                    <p class="mt-1 text-sm text-neutral-900">
                        {{ $promotion->start_date ? $promotion->start_date->format('d M Y') : '-' }}</p>
                </div>

                <div>
                    <label class="text-xs font-medium text-neutral-500 uppercase tracking-wide">Tanggal Berakhir</label>
                    <p class="mt-1 text-sm text-neutral-900">
                        {{ $promotion->end_date ? $promotion->end_date->format('d M Y') : '-' }}</p>
                </div>

                <div>
                    <label class="text-xs font-medium text-neutral-500 uppercase tracking-wide">Dibuat</label>
                    <p class="mt-1 text-sm text-neutral-700">{{ $promotion->created_at->format('d M Y, H:i') }}</p>
                </div>

                <div>
                    <label class="text-xs font-medium text-neutral-500 uppercase tracking-wide">Terakhir
                        Diupdate</label>
                    <p class="mt-1 text-sm text-neutral-700">{{ $promotion->updated_at->format('d M Y, H:i') }}</p>
                </div>
            </div>
        </div>

        {{-- Actions --}}
        <div class="flex items-center justify-end gap-3">
            <a href="{{ route('admin.promotions.index') }}"
                class="inline-flex h-10 items-center rounded-xl border border-neutral-200 px-4 text-sm font-medium text-neutral-700 hover:bg-neutral-50">
                Kembali
            </a>
            <a href="{{ route('admin.promotions.edit', $promotion->id) }}"
                class="inline-flex h-10 items-center rounded-xl bg-red-600 px-5 text-sm font-semibold text-white shadow-sm hover:bg-red-700">
                Edit Banner
            </a>
        </div>
    </div>

</div>