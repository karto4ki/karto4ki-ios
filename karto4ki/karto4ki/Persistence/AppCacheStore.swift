import Foundation

/// Централизованный трекер свежести кэша.
/// Хранит только временны́е метки в UserDefaults — данные лежат в LocalDataStore (SwiftData).
///
/// TTL:
///   - профиль:           нет (живёт до выхода из аккаунта)
///   - список наборов:    3 минуты
///   - карточки набора:   5 минут (независимо для каждого setId)
enum AppCacheStore {

    // MARK: - TTL

    static let setsTTL:  TimeInterval = 180   // 3 min
    static let cardsTTL: TimeInterval = 300   // 5 min

    // MARK: - Keys

    private static let setsKey  = "cache.sets.lastFetchAt"
    private static func cardsKey(_ setId: String) -> String { "cache.cards.\(setId).lastFetchAt" }

    // MARK: - Sets

    static var setsLastFetchAt: Date? {
        get {
            let t = UserDefaults.standard.double(forKey: setsKey)
            return t > 0 ? Date(timeIntervalSince1970: t) : nil
        }
        set {
            if let v = newValue {
                UserDefaults.standard.set(v.timeIntervalSince1970, forKey: setsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: setsKey)
            }
        }
    }

    /// `true` если кэш наборов устарел или отсутствует и нужен сетевой запрос.
    static var setsExpired: Bool {
        guard let last = setsLastFetchAt else { return true }
        return Date().timeIntervalSince(last) >= setsTTL
    }

    // MARK: - Cards per set

    static func cardsLastFetchAt(setId: String) -> Date? {
        let t = UserDefaults.standard.double(forKey: cardsKey(setId))
        return t > 0 ? Date(timeIntervalSince1970: t) : nil
    }

    static func markCardsFetched(setId: String) {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: cardsKey(setId))
    }

    /// `true` если кэш карточек для набора устарел или отсутствует.
    static func cardsExpired(setId: String) -> Bool {
        guard let last = cardsLastFetchAt(setId: setId) else { return true }
        return Date().timeIntervalSince(last) >= cardsTTL
    }

    // MARK: - Invalidation

    /// Сбрасываем TTL наборов (например, после создания/удаления набора).
    static func invalidateSets() {
        setsLastFetchAt = nil
    }

    /// Сбрасываем TTL карточек конкретного набора (например, после добавления/удаления карточки).
    static func invalidateCards(setId: String) {
        UserDefaults.standard.removeObject(forKey: cardsKey(setId))
    }

    /// Полная очистка всех меток — вызывается при выходе из аккаунта.
    static func invalidateAll() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: setsKey)
        // Удаляем все ключи карточек
        defaults.dictionaryRepresentation().keys
            .filter { $0.hasPrefix("cache.cards.") }
            .forEach { defaults.removeObject(forKey: $0) }
    }
}
