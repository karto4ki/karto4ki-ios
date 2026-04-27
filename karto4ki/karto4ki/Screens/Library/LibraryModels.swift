import Foundation
import UIKit

enum LibraryModels {

    struct DeckSet: Codable, Equatable, Identifiable {
        let id: UUID
        var title: String
        var learned: Int
        var total: Int
        /// Когда набор добавлен в библиотеку (сортировка).
        var addedAt: Date
        /// 0…3 — индекс цвета папки из палитры.
        var colorIndex: Int

        var progress: CGFloat {
            guard total > 0 else { return 0 }
            return CGFloat(learned) / CGFloat(total)
        }
    }

    struct ViewModel {
        let decks: [DeckSet]
        let isEmpty: Bool
    }
}
