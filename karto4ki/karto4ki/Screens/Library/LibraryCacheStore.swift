import Foundation

/// Кэш списка наборов в `UserDefaults` (до появления API).
enum LibraryCacheStore {

    private static let decksKey = "karto4ki.library.decks.v1"
    private static let lastFetchKey = "karto4ki.library.lastFetchAt"

    static func loadDecks() -> [LibraryModels.DeckSet]? {
        guard let data = UserDefaults.standard.data(forKey: decksKey) else { return nil }
        return try? JSONDecoder().decode([LibraryModels.DeckSet].self, from: data)
    }

    static func saveDecks(_ decks: [LibraryModels.DeckSet]) {
        guard let data = try? JSONEncoder().encode(decks) else { return }
        UserDefaults.standard.set(data, forKey: decksKey)
    }

    static var lastFetchAt: Date? {
        get {
            let t = UserDefaults.standard.double(forKey: lastFetchKey)
            guard t > 0 else { return nil }
            return Date(timeIntervalSince1970: t)
        }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: lastFetchKey)
            } else {
                UserDefaults.standard.removeObject(forKey: lastFetchKey)
            }
        }
    }
}
