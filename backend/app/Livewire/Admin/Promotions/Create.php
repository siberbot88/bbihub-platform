<?php

namespace App\Livewire\Admin\Promotions;

use App\Models\Promotion;
use Livewire\Component;
use Livewire\WithFileUploads;
use Livewire\Attributes\Title;
use Livewire\Attributes\Layout;
use Illuminate\Support\Facades\DB;

#[Title('Tambah Banner')]
#[Layout('layouts.app')]
class Create extends Component
{
    use WithFileUploads;

    // Form fields
    public string $title = '';
    public ?string $description = null;
    public ?string $placement_slot = null;
    public ?string $start_date = null;
    public ?string $end_date = null;
    public string $status = 'draft';
    public $image; // uploaded file

    // Computed
    public array $slotOptions = [];
    public array $statusOptions = [
        'draft' => 'Draft',
        'active' => 'Aktif',
    ];

    public function mount(?string $slot = null)
    {
        // Build slot options from available slots
        $allSlots = Promotion::getAllSlots();
        foreach ($allSlots as $groupKey => $group) {
            // Skip coming soon
            if (isset($group['coming_soon']) && $group['coming_soon']) {
                continue;
            }

            foreach ($group['slots'] as $slotKey) {
                $size = Promotion::getRecommendedSize($slotKey);
                $isAvailable = Promotion::isSlotAvailable($slotKey);

                // Only show available slots
                if ($isAvailable) {
                    $this->slotOptions[$slotKey] = $size['label'] . ' (' . $size['width'] . 'x' . $size['height'] . 'px)';
                }
            }
        }

        // Pre-select slot if provided
        if ($slot && isset($this->slotOptions[$slot])) {
            $this->placement_slot = $slot;
        }
    }

    protected function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string', 'max:500'],
            'placement_slot' => ['required', 'string'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date', 'after_or_equal:start_date'],
            'status' => ['required', 'string', 'in:draft,active'],
            'image' => ['required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'], // 5 MB
        ];
    }

    public function save()
    {
        $data = $this->validate();

        DB::transaction(function () use ($data) {
            // Create promotion
            $promotion = Promotion::create([
                'title' => $data['title'],
                'description' => $data['description'],
                'placement_slot' => $data['placement_slot'],
                'start_date' => $data['start_date'],
                'end_date' => $data['end_date'],
                'status' => $data['status'],
                'display_order' => 0,
            ]);

            // Upload image using Spatie Media Library
            if ($this->image) {
                // Get image dimensions using native PHP
                $imagePath = $this->image->getRealPath();
                $imageInfo = getimagesize($imagePath);

                if ($imageInfo) {
                    $width = $imageInfo[0];
                    $height = $imageInfo[1];
                } else {
                    $width = null;
                    $height = null;
                }

                // Add media
                $media = $promotion->addMedia($imagePath)
                    ->withCustomProperties([
                        'width' => $width,
                        'height' => $height,
                    ])
                    ->toMediaCollection('banner');

                // Update dimensions in model
                $promotion->update([
                    'image_width' => $width,
                    'image_height' => $height,
                    'image_url' => $media->getUrl(),
                ]);
            }
        });

        session()->flash('success', 'Banner berhasil dibuat.');

        return redirect()->route('admin.promotions.index');
    }

    public function getRecommendedSize()
    {
        if (!$this->placement_slot) {
            return null;
        }

        return Promotion::getRecommendedSize($this->placement_slot);
    }

    public function render()
    {
        return view('livewire.admin.promotions.create', [
            'slotOptions' => $this->slotOptions,
            'statusOptions' => $this->statusOptions,
            'recommendedSize' => $this->getRecommendedSize(),
        ]);
    }
}
