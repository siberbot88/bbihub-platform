<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('promotions', function (Blueprint $table) {
            // Placement slot untuk slot-slot spesifik
            // Format: 'admin_homepage_promo_1', 'admin_homepage_promo_2', 'admin_homepage_promo_3',
            //         'admin_homepage_character', 'owner_dashboard_banner_1', 
            //         'website_landing_hero', 'website_landing_sub_1' s/d 'website_landing_sub_6'
            $table->string('placement_slot', 50)->after('status')->nullable()->index();

            // Rename banner_url ke image_url dan extend length
            $table->renameColumn('banner_url', 'image_url');

            // Dimensions untuk validasi dan display
            $table->integer('image_width')->after('image_url')->nullable();
            $table->integer('image_height')->after('image_width')->nullable();

            // Display order untuk sorting dalam slot yang sama
            $table->integer('display_order')->after('image_height')->default(0);

            // Add placement field for backward compatibility (home/product)
            $table->string('placement', 20)->after('display_order')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('promotions', function (Blueprint $table) {
            $table->dropColumn(['placement_slot', 'image_width', 'image_height', 'display_order', 'placement']);
            $table->renameColumn('image_url', 'banner_url');
        });
    }
};
