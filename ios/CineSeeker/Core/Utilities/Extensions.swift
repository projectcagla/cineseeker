import Foundation
extension String {
    /// A forgiving Turkish search key: dotted/dotless I and unaccented input match.
    var searchKey: String {
        let locale = Locale(identifier: "tr_TR")
        return trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased(with: locale)
            .folding(options: [.diacriticInsensitive, .widthInsensitive], locale: locale)
            .replacingOccurrences(of: "ı", with: "i")
    }
    var nonEmpty: String? { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : self }
}
