import Foundation
import Observation
@MainActor @Observable final class ProfileViewModel {
    var exportURL: URL?
    var message: String?
    func export(_ storage: StorageManager) {
        do {
            let directory = FileManager.default.temporaryDirectory.appendingPathComponent("CineSeekerExport", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let url = directory.appendingPathComponent("CineSeeker-verilerim.json")
            try storage.localExport().write(to: url, options: [.atomic, .completeFileProtection])
            exportURL = url
        } catch { message = error.localizedDescription }
    }
    func clearExport() {
        guard let exportURL else { return }
        do { try FileManager.default.removeItem(at: exportURL); self.exportURL = nil }
        catch { message = error.localizedDescription }
    }
    func reset(_ storage: StorageManager) {
        do { try storage.resetLocalData(); clearExport(); message = "Bu cihazdaki kişisel verilerin silindi." }
        catch { storage.context.rollback(); message = error.localizedDescription }
    }
}
