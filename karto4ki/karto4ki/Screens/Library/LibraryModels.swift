import Foundation
import UIKit

enum LibraryModels {

    /// Цвета папок (как в библиотеке и на экране набора).
    enum FolderPalette {
        private static let colors: [UIColor] = [
            UIColor(red: 0.55, green: 0.45, blue: 0.95, alpha: 1),
            UIColor(red: 0.35, green: 0.78, blue: 0.55, alpha: 1),
            UIColor(red: 0.98, green: 0.62, blue: 0.32, alpha: 1),
            UIColor(red: 0.38, green: 0.65, blue: 0.98, alpha: 1)
        ]

        static func folderColor(colorIndex: Int) -> UIColor {
            colors[colorIndex % colors.count]
        }
    }

    struct DeckSet: Codable, Equatable, Identifiable {
        let id: UUID
        var title: String
        var learned: Int
        var total: Int
        /// Когда набор добавлен в библиотеку (сортировка).
        var addedAt: Date
        /// 0…3 — индекс цвета папки из палитры.
        var colorIndex: Int
        /// Набор текущего пользователя; для чужих — кнопка «В библиотеку».
        var isUserOwned: Bool
        /// Имя автора набора (может быть nil для старых записей).
        var authorName: String?

        var progress: CGFloat {
            guard total > 0 else { return 0 }
            return CGFloat(learned) / CGFloat(total)
        }

        enum CodingKeys: String, CodingKey {
            case id, title, learned, total, addedAt, colorIndex, isUserOwned, authorName
        }

        /// Создаёт DeckSet из API-ответа.
        init(from api: CardSetAPI) {
            self.id = UUID(uuidString: api.id) ?? UUID()
            self.title = api.name
            self.learned = api.learnedCount
            self.total = api.cardCount
            // Цвет — стабильный хэш от id, чтобы не прыгал при перезагрузке
            self.colorIndex = abs(api.id.hashValue) % 4
            self.isUserOwned = true
            // Предпочитаем username; если он пустой или nil — берём name, но не показываем email
            let name = api.author?.name
            let username = api.author?.username
            let nameIsEmail = name?.contains("@") == true
            self.authorName = username?.isEmpty == false ? username : (nameIsEmail ? nil : name)
            // Парсим дату создания (ISO8601)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            self.addedAt = formatter.date(from: api.createdAt)
                ?? ISO8601DateFormatter().date(from: api.createdAt)
                ?? Date()
        }

        init(id: UUID, title: String, learned: Int, total: Int, addedAt: Date, colorIndex: Int, isUserOwned: Bool = true, authorName: String? = nil) {
            self.id = id
            self.title = title
            self.learned = learned
            self.total = total
            self.addedAt = addedAt
            self.colorIndex = colorIndex
            self.isUserOwned = isUserOwned
            self.authorName = authorName
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            id = try c.decode(UUID.self, forKey: .id)
            title = try c.decode(String.self, forKey: .title)
            learned = try c.decode(Int.self, forKey: .learned)
            total = try c.decode(Int.self, forKey: .total)
            addedAt = try c.decode(Date.self, forKey: .addedAt)
            colorIndex = try c.decode(Int.self, forKey: .colorIndex)
            isUserOwned = try c.decodeIfPresent(Bool.self, forKey: .isUserOwned) ?? true
            authorName = try c.decodeIfPresent(String.self, forKey: .authorName)
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(id, forKey: .id)
            try c.encode(title, forKey: .title)
            try c.encode(learned, forKey: .learned)
            try c.encode(total, forKey: .total)
            try c.encode(addedAt, forKey: .addedAt)
            try c.encode(colorIndex, forKey: .colorIndex)
            try c.encode(isUserOwned, forKey: .isUserOwned)
            try c.encodeIfPresent(authorName, forKey: .authorName)
        }
    }

    struct ViewModel {
        let decks: [DeckSet]
        let isEmpty: Bool
    }
}
