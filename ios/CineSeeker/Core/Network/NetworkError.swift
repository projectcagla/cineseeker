import Foundation
enum NetworkError: LocalizedError {
    case configuration, invalidResponse, server(Int, String)
    var errorDescription: String? {
        switch self {
        case .configuration: "Sunucu bağlantısı henüz ayarlanmadı. Hesap bölümünden kurulum bilgisini görebilirsiniz."
        case .invalidResponse: "Sunucudan beklenmeyen yanıt alındı."
        case let .server(_, message): message
        }
    }
}
