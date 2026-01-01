<?php

namespace App\Livewire\Admin\Promotions;

use App\Models\Promotion;
use Livewire\Component;
use Livewire\Attributes\Title;
use Livewire\Attributes\Layout;

#[Title('Detail Banner')]
#[Layout('layouts.app')]
class Show extends Component
{
    public Promotion $promotion;
    public array $sizeInfo = [];
    public ?string $imageUrl = null;

    public function mount(Promotion $promotion)
    {
        $this->promotion = $promotion;
        $this->sizeInfo = Promotion::getRecommendedSize($promotion->placement_slot);
        $this->imageUrl = $promotion->banner_url ?? $promotion->getFirstMediaUrl('banner');
    }

    public function render()
    {
        return view('livewire.admin.promotions.show');
    }
}
