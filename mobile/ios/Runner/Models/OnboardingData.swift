import Foundation

struct OnboardingPage {
    let title: String
    let description: String
    let imageURL: String
    let buttonText: String
}

class OnboardingData {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Order langsung masuk",
            description: "Dapatkan notifikasi pesanan servis dari\npelanggan secara real-time. Tidak perlu repot\ncari pelanggan, cukup tunggu order masuk\ndan siap melayani.",
            imageURL: "https://api.builder.io/api/v1/image/assets/TEMP/81028da050b23d849d625e316d1159162028529e?width=760",
            buttonText: "Lanjutkan"
        ),
        OnboardingPage(
            title: "Kelola pesanan dengan mudah",
            description: "Atur jadwal servis, pantau progress\npekerjaan, dan komunikasi dengan\npelanggan dalam satu platform\nyang terintegrasi.",
            imageURL: "https://api.builder.io/api/v1/image/assets/TEMP/81028da050b23d849d625e316d1159162028529e?width=760",
            buttonText: "Lanjutkan"
        ),
        OnboardingPage(
            title: "Tingkatkan pendapatan",
            description: "Raih lebih banyak pelanggan dan\ntingkatkan omzet bengkel Anda\ndengan sistem booking online\nyang efisien.",
            imageURL: "https://api.builder.io/api/v1/image/assets/TEMP/81028da050b23d849d625e316d1159162028529e?width=760",
            buttonText: "Mulai Sekarang"
        )
    ]
}
