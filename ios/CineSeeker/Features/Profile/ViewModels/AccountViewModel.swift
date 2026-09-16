import Foundation
import Observation
@MainActor @Observable final class AccountViewModel {
    var user: User?
    var busy = false
    var message: String?
    private let network = NetworkManager.shared
    func restore(_ storage: StorageManager) async {
        do {
            user = try storage.metadata("lastUser", as: User.self)
            if let user { try storage.switchOwner(user.id) }
            guard AppConfiguration.baseURL != nil else { return }
            let response: SessionResponse? = try await network.request(.init(path: "api/auth/get-session"))
            user = response?.user
            if let user { try storage.storeMetadata(user, key: "lastUser"); try storage.switchOwner(user.id); await storage.sync() }
            else { try storage.storeMetadata(Optional<User>.none, key: "lastUser"); try storage.switchOwner("guest") }
        } catch { message = error.localizedDescription }
    }
    func authenticate(email: String, password: String, name: String, registering: Bool, storage: StorageManager) async {
        busy = true; defer { busy = false }
        do {
            let body = try JSONSerialization.data(withJSONObject: ["email": email, "password": password, "name": name])
            let data = try await network.data(.init(path: registering ? "api/auth/sign-up/email" : "api/auth/sign-in/email", method: "POST", body: body))
            if registering { message = "Doğrulama bağlantısı e-posta adresinize gönderildi. Doğruladıktan sonra giriş yapın." }
            else {
                let response = try JSONDecoder().decode(SessionResponse.self, from: data)
                user = response.user; try storage.storeMetadata(response.user, key: "lastUser")
                try storage.switchOwner(response.user.id); await storage.sync()
            }
        } catch { message = error.localizedDescription }
    }
    func resetPassword(email: String) async {
        busy = true; defer { busy = false }
        do {
            guard let base = AppConfiguration.baseURL else { throw NetworkError.configuration }
            let body = try JSONSerialization.data(withJSONObject: ["email": email, "redirectTo": base.appendingPathComponent("sifre-sifirla").absoluteString])
            _ = try await network.data(.init(path: "api/auth/request-password-reset", method: "POST", body: body))
            message = "Bu adrese bağlı hesap varsa şifre sıfırlama bağlantısı gönderildi."
        } catch { message = error.localizedDescription }
    }
    func updateName(_ name: String, storage: StorageManager) async {
        busy = true; defer { busy = false }
        do {
            _ = try await network.data(.init(path: "api/auth/update-user", method: "POST", body: JSONSerialization.data(withJSONObject: ["name": name])))
            user?.name = name
            if let user { try storage.storeMetadata(user, key: "lastUser") }
            message = "Profil güncellendi."
        } catch { message = error.localizedDescription }
    }
    func changeEmail(_ email: String) async {
        busy = true; defer { busy = false }
        do {
            _ = try await network.data(.init(path: "api/auth/change-email", method: "POST", body: JSONSerialization.data(withJSONObject: ["newEmail": email])))
            message = "Yeni adresine doğrulama bağlantısı gönderildi. Doğruladıktan sonra yeni adresinle giriş yap."
        } catch { message = error.localizedDescription }
    }
    func signOut(_ storage: StorageManager) async {
        busy = true; defer { busy = false }
        do {
            _ = try await network.data(.init(path: "api/auth/sign-out", method: "POST", body: Data("{}".utf8)))
            try await network.clearSession(); user = nil
            try storage.storeMetadata(Optional<User>.none, key: "lastUser"); try storage.switchOwner("guest")
        } catch { message = error.localizedDescription }
    }
    func deleteAccount(_ storage: StorageManager) async {
        guard let id = user?.id else { return }
        busy = true; defer { busy = false }
        do {
            _ = try await network.data(.init(path: "api/user/delete", method: "POST", body: Data("{}".utf8)))
            try await network.clearSession(); user = nil; try storage.eraseAccount(id)
            message = "Hesabınız ve hesap verileriniz silindi."
        } catch { message = error.localizedDescription }
    }
    func export(_ storage: StorageManager) async throws -> URL {
        let local = try JSONSerialization.jsonObject(with: storage.localExport())
        var payload: [String: Any] = ["device": local]
        if user != nil {
            let remoteData = try await network.data(.init(path: "api/user/export"))
            payload["account"] = try JSONSerialization.jsonObject(with: remoteData)
        }
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("CineSeekerExport", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("CineSeeker-verilerim.json")
        try data.write(to: url, options: [.atomic, .completeFileProtection])
        return url
    }
}
