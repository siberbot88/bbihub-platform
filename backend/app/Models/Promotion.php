<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;


class Promotion extends Model
{
    protected $fillable = [
        'title',
        'description',
        'start_date',
        'end_date',
        'status',
        'image_url',
        'image_width',
        'image_height',
        'placement_slot',
        'display_order',
        'placement',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    // Placement slot constants
    const SLOT_ADMIN_HOMEPAGE_PROMO_1 = 'admin_homepage_promo_1';
    const SLOT_ADMIN_HOMEPAGE_PROMO_2 = 'admin_homepage_promo_2';
    const SLOT_ADMIN_HOMEPAGE_PROMO_3 = 'admin_homepage_promo_3';
    const SLOT_ADMIN_HOMEPAGE_CHARACTER = 'admin_homepage_character';
    const SLOT_OWNER_DASHBOARD_BANNER_1 = 'owner_dashboard_banner_1';
    const SLOT_WEBSITE_LANDING_HERO = 'website_landing_hero';
    const SLOT_WEBSITE_LANDING_SUB_1 = 'website_landing_sub_1';
    const SLOT_WEBSITE_LANDING_SUB_2 = 'website_landing_sub_2';
    const SLOT_WEBSITE_LANDING_SUB_3 = 'website_landing_sub_3';
    const SLOT_WEBSITE_LANDING_SUB_4 = 'website_landing_sub_4';
    const SLOT_WEBSITE_LANDING_SUB_5 = 'website_landing_sub_5';
    const SLOT_WEBSITE_LANDING_SUB_6 = 'website_landing_sub_6';

    /**
     * Get recommended dimensions for a placement slot
     */
    public static function getRecommendedSize(string $slot): array
    {
        $sizes = [
            self::SLOT_ADMIN_HOMEPAGE_PROMO_1 => ['width' => 1080, 'height' => 1080, 'label' => 'Homepage Admin - Banner Promo 1'],
            self::SLOT_ADMIN_HOMEPAGE_PROMO_2 => ['width' => 1080, 'height' => 1080, 'label' => 'Homepage Admin - Banner Promo 2'],
            self::SLOT_ADMIN_HOMEPAGE_PROMO_3 => ['width' => 1080, 'height' => 1080, 'label' => 'Homepage Admin - Banner Promo 3'],
            self::SLOT_ADMIN_HOMEPAGE_CHARACTER => ['width' => 339, 'height' => 339, 'label' => 'Homepage Admin - Karakter'],
            self::SLOT_OWNER_DASHBOARD_BANNER_1 => ['width' => 1024, 'height' => 512, 'label' => 'Owner Dashboard - Banner'],
            self::SLOT_WEBSITE_LANDING_HERO => ['width' => 1920, 'height' => 600, 'label' => 'Website Landing - Hero Banner'],
            self::SLOT_WEBSITE_LANDING_SUB_1 => ['width' => 400, 'height' => 300, 'label' => 'Website Landing - Sub Banner 1'],
            self::SLOT_WEBSITE_LANDING_SUB_2 => ['width' => 400, 'height' => 300, 'label' => 'Website Landing - Sub Banner 2'],
            self::SLOT_WEBSITE_LANDING_SUB_3 => ['width' => 400, 'height' => 300, 'label' => 'Website Landing - Sub Banner 3'],
            self::SLOT_WEBSITE_LANDING_SUB_4 => ['width' => 400, 'height' => 300, 'label' => 'Website Landing - Sub Banner 4'],
            self::SLOT_WEBSITE_LANDING_SUB_5 => ['width' => 400, 'height' => 300, 'label' => 'Website Landing - Sub Banner 5'],
            self::SLOT_WEBSITE_LANDING_SUB_6 => ['width' => 400, 'height' => 300, 'label' => 'Website Landing - Sub Banner 6'],
        ];

        return $sizes[$slot] ?? ['width' => 1080, 'height' => 1080, 'label' => 'Default'];
    }

    /**
     * Get all available placement slots
     */
    public static function getAllSlots(): array
    {
        return [
            'admin_homepage' => [
                'label' => 'Homepage Admin - Banner Promo',
                'icon' => 'device-phone-mobile',
                'slots' => [
                    self::SLOT_ADMIN_HOMEPAGE_PROMO_1,
                    self::SLOT_ADMIN_HOMEPAGE_PROMO_2,
                    self::SLOT_ADMIN_HOMEPAGE_PROMO_3,
                ],
            ],
            'admin_character' => [
                'label' => 'Homepage Admin - Karakter',
                'icon' => 'user',
                'slots' => [
                    self::SLOT_ADMIN_HOMEPAGE_CHARACTER,
                ],
            ],
            'owner_dashboard' => [
                'label' => 'Owner Dashboard - Banner',
                'icon' => 'chart-bar',
                'slots' => [
                    self::SLOT_OWNER_DASHBOARD_BANNER_1,
                ],
                'coming_soon' => true,
            ],
            'website_hero' => [
                'label' => 'Website Landing - Hero Banner',
                'icon' => 'computer-desktop',
                'slots' => [
                    self::SLOT_WEBSITE_LANDING_HERO,
                ],
            ],
            'website_sub' => [
                'label' => 'Website Landing - Sub Banners',
                'icon' => 'squares-2x2',
                'slots' => [
                    self::SLOT_WEBSITE_LANDING_SUB_1,
                    self::SLOT_WEBSITE_LANDING_SUB_2,
                    self::SLOT_WEBSITE_LANDING_SUB_3,
                    self::SLOT_WEBSITE_LANDING_SUB_4,
                    self::SLOT_WEBSITE_LANDING_SUB_5,
                    self::SLOT_WEBSITE_LANDING_SUB_6,
                ],
            ],
        ];
    }

    /**
     * Check if slot is available (not occupied)
     */
    public static function isSlotAvailable(string $slot): bool
    {
        return !self::where('placement_slot', $slot)->exists();
    }
}

