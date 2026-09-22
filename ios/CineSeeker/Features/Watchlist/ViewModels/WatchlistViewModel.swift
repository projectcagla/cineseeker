import Foundation
import Observation

enum LibrarySort: String, CaseIterable, Identifiable {
    case recent = "Son eklenen", title = "Ada göre", rating = "Puanıma göre"
    var id: String { rawValue }
}
@MainActor @Observable final class WatchlistViewModel {
    var status: WatchStatus?
    var query = ""
    var sort: LibrarySort = .recent
    func filtered(_ titles: [SavedTitle]) -> [SavedTitle] {
        let clean = query.searchKey
        let filtered = titles.filter { item in
            guard status == nil || item.status == status else { return false }
            guard !clean.isEmpty else { return true }
            return item.movie?.displayTitle.searchKey.contains(clean) == true
        }
        return filtered.sorted { lhs, rhs in
            switch sort {
            case .recent: return lhs.updatedAt > rhs.updatedAt
            case .title: return (lhs.movie?.displayTitle ?? "").compare(rhs.movie?.displayTitle ?? "", options: [.caseInsensitive], locale: Locale(identifier: "tr_TR")) == .orderedAscending
            case .rating:
                if lhs.rating != rhs.rating { return (lhs.rating ?? 0) > (rhs.rating ?? 0) }
                return lhs.updatedAt > rhs.updatedAt
            }
        }
    }
}
