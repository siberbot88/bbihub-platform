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
        <h1 class="text-2xl font-semibold text-neutral-900">Edit Banner</h1>
        <p class="mt-1 text-sm text-neutral-500">
            Update banner yang sudah ada atau ganti gambar.
        </p>
    </div>

    <form wire:submit.prevent="save" class="space-y-6 rounded-2xl border border-neutral-200 bg-white p-6 shadow-sm">

        @if (session('success'))
            <div class="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
                {{ session('success') }}
            </div>
        @endif

        {{-- Current Banner Preview --}}
        @if($currentImageUrl)
            <div class="rounded-lg border border-neutral-200 p-4 bg-neutral-50">
                <p class="text-sm font-medium text-neutral-700 mb-2">Banner Saat Ini:</p>
                <img src="{{ $currentImageUrl }}" alt="Current Banner"
                    class="max-h-48 rounded-lg border border-neutral-300 object-cover">
                <p class="text-xs text-neutral-500 mt-2">Upload gambar baru untuk mengganti atau biarkan kosong untuk tetap
                    menggunakan gambar ini</p>
            </div>
        @endif

        {{-- Upload gambar baru (optional) --}}
        <div class="space-y-2">
            <label class="text-sm font-medium text-neutral-800">
                Ganti Gambar Banner (Opsional)
            </label>

            <div class="relative flex cursor-pointer flex-col items-center justify-center rounded-2xl border-2 border-dashed border-red-200 bg-red-50/60 px-6 py-10 text-center"
                onclick="document.getElementById('banner-image-input-edit').click()">
                <div class="mb-3 flex h-14 w-14 items-center justify-center rounded-full bg-white">
                    <svg class="h-7 w-7 text-red-500" viewBox="0 0 24 24" fill="none">
                        <path d="M4 16v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2" stroke="currentColor" stroke-width="2"
                            stroke-linecap="round" stroke-linejoin="round" />
                        <path d="M12 4v12M7 9l5-5 5 5" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                            stroke-linejoin="round" />
                    </svg>
                </div>

                <div class="text-sm text-neutral-700">
                    <span class="font-medium text-red-600">Klik untuk upload</span> atau drag &amp; drop
                </div>
                <p class="mt-1 text-xs text-neutral-500">
                    Format JPG/PNG/WebP · Maksimal 5MB
                </p>

                @if ($image)
                    <div class="mt-4">
                        <p class="mb-2 text-xs font-medium text-neutral-600">Preview Gambar Baru:</p>
                        <img src="{{ $image->temporaryUrl() }}"
                            class="max-h-40 rounded-xl border border-neutral-200 object-cover" alt="Preview banner">
                    </div>
                @endif
            </div>

            <input id="banner-image-input-edit" type="file" class="hidden" wire:model="image"
                accept="image/jpeg,image/png,image/jpg,image/webp">

            @error('image')
                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
            @enderror
        </div>

        {{-- Judul & Description --}}
        <div class="space-y-4">
            <div class="space-y-1.5">
                <label class="text-sm font-medium text-neutral-800">
                    Judul Banner <span class="text-red-500">*</span>
                </label>
                <input type="text" wire:model.defer="title"
                    class="h-11 w-full rounded-xl border border-neutral-200 bg-white px-3 text-sm text-neutral-800 focus:border-red-400 focus:outline-none focus:ring-1 focus:ring-red-400"
                    placeholder="Contoh: Promo Servis Berkala">
                @error('title')
                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                @enderror
            </div>

            <div class="space-y-1.5">
                <label class="text-sm font-medium text-neutral-800">
                    Deskripsi (Opsional)
                </label>
                <textarea wire:model.defer="description" rows="3"
                    class="w-full rounded-xl border border-neutral-200 bg-white px-3 py-2 text-sm text-neutral-800 focus:border-red-400 focus:outline-none focus:ring-1 focus:ring-red-400"
                    placeholder="Deskripsi singkat tentang banner ini..."></textarea>
                @error('description')
                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                @enderror
            </div>
        </div>

        {{-- Slot (Read-only, shown for reference) --}}
        <div class="space-y-1.5">
            <label class="text-sm font-medium text-neutral-800">
                Slot Banner
            </label>
            <div
                class="h-11 w-full rounded-xl border border-neutral-200 bg-neutral-100 px-3 flex items-center text-sm text-neutral-600">
                {{ $slotLabel }}
            </div>
            <p class="text-xs text-neutral-500">Slot tidak dapat diubah setelah banner dibuat</p>
        </div>

        {{-- Periode & Status --}}
        <div class="grid gap-4 md:grid-cols-3">
            <div class="space-y-1.5">
                <label class="text-sm font-medium text-neutral-800">
                    Tanggal Mulai
                </label>
                <input type="date" wire:model.defer="start_date"
                    class="h-11 w-full rounded-xl border border-neutral-200 bg-white px-3 text-sm text-neutral-800 focus:border-red-400 focus:outline-none focus:ring-1 focus:ring-red-400">
                @error('start_date')
                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                @enderror
            </div>

            <div class="space-y-1.5">
                <label class="text-sm font-medium text-neutral-800">
                    Tanggal Berakhir
                </label>
                <input type="date" wire:model.defer="end_date"
                    class="h-11 w-full rounded-xl border border-neutral-200 bg-white px-3 text-sm text-neutral-800 focus:border-red-400 focus:outline-none focus:ring-1 focus:ring-red-400">
                @error('end_date')
                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                @enderror
            </div>

            <div class="space-y-1.5">
                <label class="text-sm font-medium text-neutral-800">
                    Status <span class="text-red-500">*</span>
                </label>
                <select wire:model="status"
                    class="h-11 w-full rounded-xl border border-neutral-200 bg-white px-3 text-sm text-neutral-800 focus:border-red-400 focus:outline-none focus:ring-1 focus:ring-red-400">
                    <option value="draft">Draft</option>
                    <option value="active">Aktif</option>
                </select>
                @error('status')
                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                @enderror
            </div>
        </div>

        {{-- Footer --}}
        <div class="flex items-center justify-end gap-3 pt-2">
            <a href="{{ route('admin.promotions.index') }}"
                class="inline-flex h-10 items-center rounded-xl border border-neutral-200 px-4 text-sm font-medium text-neutral-700 hover:bg-neutral-50">
                Batal
            </a>
            <button type="submit"
                class="inline-flex h-10 items-center rounded-xl bg-red-600 px-5 text-sm font-semibold text-white shadow-sm hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-400 focus:ring-offset-1"
                wire:loading.attr="disabled">
                <span wire:loading.remove>Update Banner</span>
                <span wire:loading class="inline-flex items-center gap-1">
                    <svg class="h-4 w-4 animate-spin" viewBox="0 0 24 24" fill="none">
                        <circle cx="12" cy="12" r="9" stroke="currentColor" stroke-opacity=".25" stroke-width="3" />
                        <path d="M21 12a9 9 0 0 0-9-9" stroke="currentColor" stroke-width="3" stroke-linecap="round" />
                    </svg>
                    Menyimpan...
                </span>
            </button>
        </div>

    </form>
</div>