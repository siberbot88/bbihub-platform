<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;


use App\Models\Promotion;

class BannerController extends Controller
{
    /**
     * Get banners for admin homepage
     * Returns 3 promo banners + 1 character image
     */
    public function adminHomepage()
    {
        $promoBanners = Promotion::whereIn('placement_slot', [
            Promotion::SLOT_ADMIN_HOMEPAGE_PROMO_1,
            Promotion::SLOT_ADMIN_HOMEPAGE_PROMO_2,
            Promotion::SLOT_ADMIN_HOMEPAGE_PROMO_3,
        ])
            ->where('status', 'active')
            ->orderBy('display_order')
            ->get()
            ->map(function ($banner) {
                $imageUrl = $banner->banner_url ?? $banner->getFirstMediaUrl('banner');
                // Replace localhost with 10.0.2.2 for Android emulator
                $imageUrl = str_replace('http://localhost:8000', 'http://10.0.2.2:8000', $imageUrl);

                return [
                    'id' => $banner->id,
                    'title' => $banner->title,
                    'description' => $banner->description,
                    'image_url' => $imageUrl,
                    'placement_slot' => $banner->placement_slot,
                    'status' => $banner->status,
                ];
            });

        $characterBanner = Promotion::where('placement_slot', Promotion::SLOT_ADMIN_HOMEPAGE_CHARACTER)
            ->where('status', 'active')
            ->first();

        $characterImageUrl = null;
        if ($characterBanner) {
            $characterImageUrl = $characterBanner->banner_url ?? $characterBanner->getFirstMediaUrl('banner');
            $characterImageUrl = str_replace('http://localhost:8000', 'http://10.0.2.2:8000', $characterImageUrl);
        }

        return response()->json([
            'success' => true,
            'banners' => $promoBanners,
            'character' => $characterBanner ? [
                'id' => $characterBanner->id,
                'title' => $characterBanner->title ?? 'Character Image',
                'description' => $characterBanner->description,
                'image_url' => $characterImageUrl,
                'placement_slot' => $characterBanner->placement_slot,
                'status' => $characterBanner->status,
            ] : null,
        ]);
    }

    /**
     * Get banners for owner dashboard
     */
    public function ownerDashboard()
    {
        $banners = Promotion::where('placement_slot', Promotion::SLOT_OWNER_DASHBOARD_BANNER_1)
            ->where('status', 'active')
            ->orderBy('display_order')
            ->get()
            ->map(function ($banner) {
                return [
                    'id' => $banner->id,
                    'title' => $banner->title,
                    'description' => $banner->description,
                    'image_url' => $banner->image_url ? url($banner->image_url) : null,
                    'slot' => $banner->placement_slot,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $banners,
        ]);
    }

    /**
     * Get banners for website landing page
     * Returns 1 hero banner + 6 sub banners
     */
    public function websiteLanding()
    {
        $heroBanner = Promotion::where('placement_slot', Promotion::SLOT_WEBSITE_LANDING_HERO)
            ->where('status', 'active')
            ->first();

        $subBanners = Promotion::whereIn('placement_slot', [
            Promotion::SLOT_WEBSITE_LANDING_SUB_1,
            Promotion::SLOT_WEBSITE_LANDING_SUB_2,
            Promotion::SLOT_WEBSITE_LANDING_SUB_3,
            Promotion::SLOT_WEBSITE_LANDING_SUB_4,
            Promotion::SLOT_WEBSITE_LANDING_SUB_5,
            Promotion::SLOT_WEBSITE_LANDING_SUB_6,
        ])
            ->where('status', 'active')
            ->orderBy('display_order')
            ->get()
            ->map(function ($banner) {
                return [
                    'id' => $banner->id,
                    'title' => $banner->title,
                    'description' => $banner->description,
                    'image_url' => $banner->image_url ? url($banner->image_url) : null,
                    'slot' => $banner->placement_slot,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'hero_banner' => $heroBanner ? [
                    'id' => $heroBanner->id,
                    'title' => $heroBanner->title,
                    'description' => $heroBanner->description,
                    'image_url' => $heroBanner->image_url ? url($heroBanner->image_url) : null,
                ] : null,
                'sub_banners' => $subBanners,
            ],
        ]);
    }
}

