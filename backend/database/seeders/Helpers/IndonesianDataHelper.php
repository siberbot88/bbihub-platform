<?php

namespace Database\Seeders\Helpers;

/**
 * Helper class untuk generate data Indonesia yang realistic
 * Digunakan oleh semua seeders untuk consistency
 */
class IndonesianDataHelper
{
    /**
     * Indonesian cities dengan province, coordinates, dan plate code
     */
    public static function cities(): array
    {
        return [
            ['city' => 'Jakarta', 'province' => 'DKI Jakarta', 'lat' => -6.2088, 'lon' => 106.8456, 'plate' => 'B', 'postal' => '10110'],
            ['city' => 'Bandung', 'province' => 'Jawa Barat', 'lat' => -6.9175, 'lon' => 107.6191, 'plate' => 'D', 'postal' => '40111'],
            ['city' => 'Surabaya', 'province' => 'Jawa Timur', 'lat' => -7.2575, 'lon' => 112.7521, 'plate' => 'L', 'postal' => '60111'],
            ['city' => 'Medan', 'province' => 'Sumatera Utara', 'lat' => 3.5952, 'lon' => 98.6722, 'plate' => 'BK', 'postal' => '20111'],
            ['city' => 'Semarang', 'province' => 'Jawa Tengah', 'lat' => -6.9667, 'lon' => 110.4167, 'plate' => 'H', 'postal' => '50111'],
            ['city' => 'Makassar', 'province' => 'Sulawesi Selatan', 'lat' => -5.1477, 'lon' => 119.4327, 'plate' => 'DD', 'postal' => '90111'],
            ['city' => 'Palembang', 'province' => 'Sumatera Selatan', 'lat' => -2.9761, 'lon' => 104.7754, 'plate' => 'BG', 'postal' => '30111'],
            ['city' => 'Tangerang', 'province' => 'Banten', 'lat' => -6.1783, 'lon' => 106.6319, 'plate' => 'B', 'postal' => '15111'],
            ['city' => 'Bekasi', 'province' => 'Jawa Barat', 'lat' => -6.2349, 'lon' => 106.9896, 'plate' => 'B', 'postal' => '17111'],
            ['city' => 'Bogor', 'province' => 'Jawa Barat', 'lat' => -6.5971, 'lon' => 106.8060, 'plate' => 'F', 'postal' => '16111'],
            ['city' => 'Malang', 'province' => 'Jawa Timur', 'lat' => -7.9666, 'lon' => 112.6326, 'plate' => 'N', 'postal' => '65111'],
            ['city' => 'Denpasar', 'province' => 'Bali', 'lat' => -8.6705, 'lon' => 115.2126, 'plate' => 'DK', 'postal' => '80111'],
            ['city' => 'Balikpapan', 'province' => 'Kalimantan Timur', 'lat' => -1.2379, 'lon' => 116.8529, 'plate' => 'KT', 'postal' => '76111'],
            ['city' => 'Pontianak', 'province' => 'Kalimantan Barat', 'lat' => -0.0263, 'lon' => 109.3425, 'plate' => 'KB', 'postal' => '78111'],
            ['city' => 'Banjarmasin', 'province' => 'Kalimantan Selatan', 'lat' => -3.3194, 'lon' => 114.5897, 'plate' => 'DA', 'postal' => '70111'],
            ['city' => 'Manado', 'province' => 'Sulawesi Utara', 'lat' => 1.4748, 'lon' => 124.8421, 'plate' => 'DB', 'postal' => '95111'],
            ['city' => 'Pekanbaru', 'province' => 'Riau', 'lat' => 0.5071, 'lon' => 101.4478, 'plate' => 'BM', 'postal' => '28111'],
            ['city' => 'Yogyakarta', 'province' => 'DI Yogyakarta', 'lat' => -7.7956, 'lon' => 110.3695, 'plate' => 'AB', 'postal' => '55111'],
            ['city' => 'Depok', 'province' => 'Jawa Barat', 'lat' => -6.4025, 'lon' => 106.7942, 'plate' => 'B', 'postal' => '16411'],
            ['city' => 'Samarinda', 'province' => 'Kalimantan Timur', 'lat' => -0.5022, 'lon' => 117.1536, 'plate' => 'KT', 'postal' => '75111'],
        ];
    }

    /**
     * Indonesian first names
     */
    public static function firstNames(): array
    {
        return [
            'Budi',
            'Siti',
            'Ahmad',
            'Dewi',
            'Andi',
            'Sri',
            'Rudi',
            'Ani',
            'Agus',
            'Ratna',
            'Hadi',
            'Rina',
            'Dedi',
            'Wati',
            'Eko',
            'Yuni',
            'Joko',
            'Sari',
            'Tono',
            'Lilis',
            'Bambang',
            'Indah',
            'Sutrisno',
            'Endah',
            'Haryanto',
            'Fitri',
            'Suryanto',
            'Maya',
            'Arief',
            'Diah',
            'Wahyu',
            'Retno',
            'Teguh',
            'Sinta',
            'Yanto',
            'Ayu',
            'Faisal',
            'Nurul',
            'Rizki',
            'Putri',
            'Dwi',
            'Mega',
            'Tri',
            'Desi',
            'Muhammad',
            'Lina',
            'Abdul',
            'Ika',
            'Hendro',
            'Wulan',
            'Gunawan',
            'Nur',
            'Wisnu',
            'Sinta',
            'Dadang',
            'Lia',
            'Iwan',
            'Anis'
        ];
    }

    /**
     * Indonesian last names
     */
    public static function lastNames(): array
    {
        return [
            'Kusuma',
            'Pratama',
            'Wijaya',
            'Santoso',
            'Putra',
            'Putri',
            'Hartono',
            'Suryadi',
            'Setiawan',
            'Wibowo',
            'Nugroho',
            'Permana',
            'Saputra',
            'Gunawan',
            'Hidayat',
            'Rahman',
            'Firmansyah',
            'Hakim',
            'Lestari',
            'Purnomo',
            'Cahyadi',
            'Mulyadi',
            'Kurniawan',
            'Susanto',
            'Prasetyo',
            'Suharto',
            'Budiman',
            'Utomo',
            'Pranata',
            'Dharma'
        ];
    }

    /**
     * Generate random Indonesian name
     */
    public static function randomName(): string
    {
        $first = self::firstNames()[array_rand(self::firstNames())];
        $last = self::lastNames()[array_rand(self::lastNames())];
        return "$first $last";
    }

    /**
     * Generate random Indonesian phone number
     */
    public static function randomPhone(): string
    {
        $operators = ['811', '812', '813', '821', '822', '823', '851', '852', '853', '895', '896', '897', '898', '899'];
        $operator = $operators[array_rand($operators)];
        $number = str_pad(rand(10000000, 99999999), 8, '0', STR_PAD_LEFT);
        return "+62{$operator}{$number}";
    }

    /**
     * Generate plate number based on city code
     */
    public static function randomPlateNumber(string $cityPlateCode): string
    {
        $number = rand(1000, 9999);
        $letters = strtoupper(substr(str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZ'), 0, rand(2, 3)));
        return "{$cityPlateCode} {$number} {$letters}";
    }

    /**
     * Workshop types
     */
    public static function workshopTypes(): array
    {
        return [
            'Bengkel',
            'AutoRepair',
            'Service Center',
            'Motor Care',
            'Garage',
            'Workshop',
            'Tech Service',
            'Pro Repair',
            'Speed Service',
            'Ultimate Care'
        ];
    }

    /**
     * Workshop name suffixes
     */
    public static function workshopSuffixes(): array
    {
        return ['Jaya', 'Maju', 'Sejahtera', 'Express', 'Sentosa', 'Pratama', 'Sentral', 'Prima', 'Utama'];
    }

    /**
     * Street names
     */
    public static function streetNames(): array
    {
        return [
            'Raya',
            'Utama',
            'Merdeka',
            'Sudirman',
            'Diponegoro',
            'Ahmad Yani',
            'Gatot Subroto',
            'Pemuda',
            'Veteran',
            'Proklamasi',
            'Pancasila'
        ];
    }

    /**
     * Vehicle brands for motorcycles
     */
    public static function motorcycleBrands(): array
    {
        return [
            'Honda' => ['Beat', 'Vario', 'Scoopy', 'PCX', 'CB150R', 'CRF150L', 'ADV 160'],
            'Yamaha' => ['NMAX', 'Aerox', 'Mio', 'Vixion', 'R15', 'XSR155', 'Lexi'],
            'Suzuki' => ['Nex', 'Address', 'Satria', 'GSX-R150', 'Smash', 'GSX-S150'],
            'Kawasaki' => ['Ninja', 'Versys', 'W175', 'KLX'],
        ];
    }

    /**
     * Vehicle brands for cars
     */
    public static function carBrands(): array
    {
        return [
            'Toyota' => ['Avanza', 'Innova', 'Fortuner', 'Rush', 'Agya', 'Calya', 'Yaris', 'Vios', 'Camry'],
            'Daihatsu' => ['Xenia', 'Terios', 'Sigra', 'Ayla', 'Gran Max', 'Luxio'],
            'Honda' => ['Brio', 'Mobilio', 'BR-V', 'CR-V', 'Jazz', 'Civic', 'HR-V', 'City'],
            'Suzuki' => ['Ertiga', 'XL7', 'Ignis', 'Baleno', 'Carry', 'APV'],
            'Mitsubishi' => ['Xpander', 'Pajero', 'L300', 'Triton', 'Outlander'],
        ];
    }

    /**
     * Vehicle colors
     */
    public static function vehicleColors(): array
    {
        return [
            'Hitam',
            'Putih',
            'Silver',
            'Merah',
            'Biru',
            'Abu-abu',
            'Kuning',
            'Hijau',
            'Coklat',
            'Orange'
        ];
    }

    /**
     * Service categories
     */
    public static function serviceCategories(): array
    {
        return [
            'Tune Up',
            'Ganti Oli',
            'Service Rutin',
            'Perbaikan Mesin',
            'Ganti Ban',
            'Service AC',
            'Perbaikan Transmisi',
            'Ganti Aki',
            'Service Rem',
            'Cuci Steam',
            'Spooring Balancing',
            'Ganti Filter',
            'Ganti Kampas Rem',
            'Service Berkala',
            'Perbaikan Kelistrikan',
        ];
    }

    /**
     * Service parts/items
     */
    public static function serviceParts(): array
    {
        return [
            ['name' => 'Oli Mesin', 'price_min' => 50000, 'price_max' => 250000],
            ['name' => 'Filter Oli', 'price_min' => 25000, 'price_max' => 75000],
            ['name' => 'Busi', 'price_min' => 15000, 'price_max' => 100000],
            ['name' => 'Aki', 'price_min' => 300000, 'price_max' => 1500000],
            ['name' => 'Ban', 'price_min' => 200000, 'price_max' => 2000000],
            ['name' => 'Kampas Rem', 'price_min' => 75000, 'price_max' => 500000],
            ['name' => 'Minyak Rem', 'price_min' => 30000, 'price_max' => 80000],
            ['name' => 'Filter Udara', 'price_min' => 35000, 'price_max' => 150000],
            ['name' => 'V-Belt', 'price_min' => 50000, 'price_max' => 200000],
            ['name' => 'Coolant', 'price_min' => 40000, 'price_max' => 120000],
        ];
    }

    /**
     * Labor services dengan harga
     */
    public static function laborServices(): array
    {
        return [
            ['name' => 'Jasa Service Rutin', 'price' => 75000],
            ['name' => 'Jasa Ganti Oli', 'price' => 35000],
            ['name' => 'Jasa Tune Up', 'price' => 150000],
            ['name' => 'Jasa Ganti Ban', 'price' => 50000],
            ['name' => 'Jasa Service AC', 'price' => 200000],
            ['name' => 'Jasa Spooring Balancing', 'price' => 120000],
            ['name' => 'Jasa Cuci Steam', 'price' => 50000],
            ['name' => 'Jasa Perbaikan Mesin', 'price' => 350000],
            ['name' => 'Jasa Ganti Kampas Rem', 'price' => 100000],
        ];
    }

    /**
     * Mechanic specialists
     */
    public static function mechanicSpecialists(): array
    {
        return [
            'Mesin',
            'Transmisi',
            'Kelistrikan',
            'AC',
            'Body & Cat',
            'Kaki-kaki',
            'General',
        ];
    }

    /**
     * Admin job descriptions
     */
    public static function adminJobdesks(): array
    {
        return [
            'Customer Service',
            'Kasir',
            'Admin Bengkel',
            'Koordinator Service',
            'Supervisor',
        ];
    }

    /**
     * Get random city data
     */
    public static function randomCity(): array
    {
        $cities = self::cities();
        return $cities[array_rand($cities)];
    }

    /**
     * Generate workshop address
     */
    public static function generateWorkshopAddress(string $city): string
    {
        $street = self::streetNames()[array_rand(self::streetNames())];
        $number = rand(1, 999);
        return "Jl. {$street} No. {$number}, {$city}";
    }

    /**
     * Generate customer address
     */
    public static function generateCustomerAddress(string $city): string
    {
        $street = self::streetNames()[array_rand(self::streetNames())];
        $number = rand(1, 250);
        $rt = str_pad(rand(1, 20), 3, '0', STR_PAD_LEFT);
        $rw = str_pad(rand(1, 10), 3, '0', STR_PAD_LEFT);
        return "Jl. {$street} No. {$number} RT {$rt}/RW {$rw}, {$city}";
    }
}
