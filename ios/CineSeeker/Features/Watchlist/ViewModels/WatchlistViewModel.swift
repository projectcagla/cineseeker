import Foundation
import Observation
@MainActor @Observable final class WatchlistViewModel {
    var status: WatchStatus?
    var grid = true
    func filtered(_ titles: [SavedTitle]) -> [SavedTitle] { titles.filter { status == nil || $0.status == status } }
}
