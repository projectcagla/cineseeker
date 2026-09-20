import Foundation
enum NetworkError: LocalizedError {
    case configuration, invalidResponse, server(Int, String)
    var errorDescription: String? {
        switch self {
        case .configuration: "Bu sürümde katalog erişimi henüz etkinleştirilmedi. Yerel izleme listenizi kullanmaya devam edebilirsiniz."
        case .invalidResponse: "Sunucudan beklenmeyen yanıt alındı."
        case let .server(_, message): message
        }
    }
}
