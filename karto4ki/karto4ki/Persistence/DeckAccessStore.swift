import Foundation

/// Хранит время последнего открытия каждой колоды в UserDefaults.
/// Используется для сортировки библиотеки: последняя открытая — первая.
enum DeckAccessStore {

    private static let keyPrefix = "deckLastOpened_"
    private static let defaults = UserDefaults.standard

    /// Записывает время открытия колоды.
    static func markOpened(deckId: UUID) {
        defaults.set(Date(), forKey: keyPrefix + deckId.uuidString)
    }

    /// Возвращает время последнего открытия, или nil если колода ни разу не открывалась.
    static func lastOpened(deckId: UUID) -> Date? {
        defaults.object(forKey: keyPrefix + deckId.uuidString) as? Date
    }

    /// Сортирует колоды: открытые — по убыванию lastOpened, неоткрытые — по убыванию createdAt,
    /// все открытые идут выше всех неоткрытых.
    static func sorted(_ decks: [LibraryModels.DeckSet]) -> [LibraryModels.DeckSet] {
        decks.sorted { a, b in
            let la = lastOpened(deckId: a.id)
            let lb = lastOpened(deckId: b.id)
            switch (la, lb) {
            case (let da?, let db?): return da > db          // обе открывались — новее первая
            case (.some, .none):     return true              // a открывалась, b — нет → a выше
            case (.none, .some):     return false             // b открывалась, a — нет → b выше
            case (.none, .none):     return a.addedAt > b.addedAt  // ни одна — по дате создания
            }
        }
    }
}
