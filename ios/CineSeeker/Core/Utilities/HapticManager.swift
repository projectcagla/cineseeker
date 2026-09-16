import UIKit
@MainActor enum HapticManager {
    static func selection() { UISelectionFeedbackGenerator().selectionChanged() }
}
