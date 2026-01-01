<?php

namespace App\Livewire\Admin\Promotions;

use App\Models\Promotion;
use Livewire\Component;
use Livewire\WithFileUploads;
use Livewire\Attributes\Title;
use Livewire\Attributes\Layout;
use Illuminate\Support\Facades\DB;

#[Title('Edit Banner')]
#[Layout('layouts.app')]
class Edit extends Component
{
    use WithFileUploads;

    public Promotion $promotion;

    // Form fields
    public string $title = '';
    public ?string $description = null;
    public ?string $start_date = null;
    public ?string $end_date = null;
    public string $status = 'draft';
    public $image; // new uploaded file (optional)

    // Display
    public string $slotLabel = '';
    public ?string $currentImageUrl = null;

    public function mount(Promotion $promotion)
    {
        $this->promotion = $promotion;
        $this->title = $promotion->title;
        $this->description = $promotion->description;
        $this->start_date = $promotion->start_date?->format('Y-m-d');
        $this->end_date = $promotion->end_date?->format('Y-m-d');
        $this->status = $promotion->status;

        $size = Promotion::getRecommendedSize($promotion->placement_slot);
        $this->slotLabel = $size['label'] . ' (' . $size['width'] . 'x' . $size['height'] . 'px)';
        $this->currentImageUrl = $promotion->banner_url ?? $promotion->getFirstMediaUrl('banner');
    }

    protected function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string', 'max:500'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date', 'after_or_equal:start_date'],
            'status' => ['required', 'string', 'in:draft,active'],
            'image' => ['nullable', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
        ];
    }

    public function save()
    {
        $data = $this->validate();

        DB::transaction(function () use ($data) {
            // Update basic info
            $this->promotion->update([
                'title' => $data['title'],
                'description' => $data['description'],
                'start_date' => $data['start_date'],
                'end_date' => $data['end_date'],
                'status' => $data['status'],
            ]);

            // Update image if new one uploaded
            if ($this->image) {
                // Delete old media
                $this->promotion->clearMediaCollection('banner');

                // Get image dimensions
                $imagePath = $this->image->getRealPath();
                $imageInfo = getimagesize($imagePath);

                if ($imageInfo) {
                    $width = $imageInfo[0];
                    $height = $imageInfo[1];
                } else {
                    $width = null;
                    $height = null;
                }

                // Add new media
                $media = $this->promotion->addMedia($imagePath)
                    ->withCustomProperties([
                        'width' => $width,
                        'height' => $height,
                    ])
                    ->toMediaCollection('banner');

                // Update dimensions
                $this->promotion->update([
                    'image_width' => $width,
                    'image_height' => $height,
                    'image_url' => $media->getUrl(),
                ]);
            }
        });

        session()->flash('success', 'Banner berhasil diupdate.');

        return redirect()->route('admin.promotions.index');
    }

    public function render()
    {
        return view('livewire.admin.promotions.edit');
    }
}
