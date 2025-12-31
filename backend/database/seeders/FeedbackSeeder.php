<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Faker\Factory as Faker;

class FeedbackSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $faker = Faker::create('id_ID');

        // Only create feedback for completed transactions (success)
        $transactions = DB::table('transactions')
            ->where('status', 'success')
            ->pluck('id');

        $feedbackData = [];
        foreach ($transactions as $index => $trxId) {
            // Not every transaction gets feedback (e.g. 60%)
            if (rand(1, 100) > 60) {
                continue;
            }

            // Weighted Rating (Bias towards 4 & 5 stars for realistic demo)
            // 5 stars: 60%, 4 stars: 25%, 3 stars: 10%, 1-2 stars: 5%
            $rand = rand(1, 100);
            if ($rand <= 60) {
                $rating = 5;
                $comment = $faker->randomElement([
                    'Sangat puas dengan pelayanannya!',
                    'Mekanik ramah dan cepat.',
                    'Service memuaskan, harga terjangkau.',
                    'Recommended banget!',
                    'Mantap, mobil jadi enak lagi.',
                    'Pelayanan prima, terima kasih.',
                    'Pengerjaan rapi dan bersih.',
                    'Top markotop!',
                    'Bengkel langganan keluarga.',
                    'Cepat dan tepat sasaran.'
                ]);
            } elseif ($rand <= 85) {
                $rating = 4;
                $comment = $faker->randomElement([
                    'Bagus, tapi antriannya lumayan.',
                    'Hasil service oke, ruang tunggu nyaman.',
                    'Cukup memuaskan.',
                    'Mekanik informatif.',
                    'Harga bersaing.'
                ]);
            } elseif ($rand <= 95) {
                $rating = 3;
                $comment = $faker->randomElement([
                    'Biasa saja.',
                    'Lumayan lama nunggunya.',
                    'Perlu ditingkatkan kebersihannya.',
                    'Harga agak mahal dibanding tempat lain.'
                ]);
            } else {
                $rating = rand(1, 2);
                $comment = $faker->randomElement([
                    'Kecewa, masalah tidak tuntas.',
                    'Pelayanan kurang ramah.',
                    'Mahal dan lama.',
                    'Tidak recommended.'
                ]);
            }

            $feedbackData[] = [
                'id' => \Illuminate\Support\Str::uuid(),
                'transaction_uuid' => $trxId,
                'rating' => $rating,
                'comment' => $comment, // Fixed: singular 'comment'
                'submitted_at' => now(), // Added: missing column
                'created_at' => now(),
                'updated_at' => now(),
            ];

            // Batch insert every 500
            if (count($feedbackData) >= 500) {
                DB::table('feedback')->insert($feedbackData);
                $feedbackData = [];
            }
        }

        // Insert remaining
        if (!empty($feedbackData)) {
            DB::table('feedback')->insert($feedbackData);
        }

        $this->command->info("✅ Generated feedback for completed transactions.");
    }
}
