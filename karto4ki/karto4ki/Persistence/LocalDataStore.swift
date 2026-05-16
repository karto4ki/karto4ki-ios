import Foundation
import SwiftData

final class LocalDataStore {

    static let shared = LocalDataStore()

    let container: ModelContainer

    private init() {
        let schema = Schema([SDUserProfile.self, SDCardSet.self, SDCard.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("LocalDataStore: failed to create ModelContainer – \(error)")
        }
    }

    // MARK: - Profile

    func saveProfile(_ profile: PrivateUserProfile) async {
        print(profile)
        await MainActor.run {
            let ctx = container.mainContext
            let id = profile.id
            let desc = FetchDescriptor<SDUserProfile>(predicate: #Predicate { $0.id == id })
            if let existing = try? ctx.fetch(desc).first {
                existing.name = profile.name
                existing.username = profile.username
                existing.email = profile.email
                existing.photo = profile.photo
                existing.createdAt = profile.createdAt
                existing.notificationEnabled = profile.notificationEnabled
            } else {
                ctx.insert(SDUserProfile(
                    id: profile.id,
                    name: profile.name,
                    username: profile.username,
                    email: profile.email,
                    photo: profile.photo,
                    createdAt: profile.createdAt,
                    notificationEnabled: profile.notificationEnabled
                ))
            }
            try? ctx.save()
        }
    }

    func loadProfile() async -> PrivateUserProfile? {
        await MainActor.run {
            let ctx = container.mainContext
            let desc = FetchDescriptor<SDUserProfile>()

            guard let models = try? ctx.fetch(desc) else {
                return nil
            }

            return models.first?.toPrivateUserProfile()
        }
    }

    // MARK: - Card Sets (library)

    /// Replaces all stored card sets with the freshly loaded list.
    func saveCardSets(_ sets: [CardSetAPI]) async {
        await MainActor.run {
            let ctx = container.mainContext
            try? ctx.delete(model: SDCardSet.self)
            sets.forEach { ctx.insert(SDCardSet(from: $0)) }
            try? ctx.save()
        }
    }

    func loadCardSets() async -> [CardSetAPI]? {
        await MainActor.run {
            let ctx = container.mainContext
            let desc = FetchDescriptor<SDCardSet>()
            guard let models = try? ctx.fetch(desc), !models.isEmpty else { return nil }
            return models.map { $0.toCardSetAPI() }
        }
    }

    // MARK: - Cards

    /// Replaces stored cards for the given set with the freshly loaded list.
    func saveCards(_ cards: [CardAPI], forSetId setId: String) async {
        await MainActor.run {
            let ctx = container.mainContext
            let desc = FetchDescriptor<SDCard>(predicate: #Predicate { $0.setId == setId })
            if let existing = try? ctx.fetch(desc) {
                existing.forEach { ctx.delete($0) }
            }
            cards.forEach { ctx.insert(SDCard(from: $0)) }
            try? ctx.save()
        }
    }

    func loadCards(forSetId setId: String) async -> [CardAPI]? {
        await MainActor.run {
            let ctx = container.mainContext
            let desc = FetchDescriptor<SDCard>(predicate: #Predicate { $0.setId == setId })
            guard let models = try? ctx.fetch(desc), !models.isEmpty else { return nil }
            return models.map { $0.toCardAPI() }
        }
    }

    // MARK: - Card Sets: individual mutations

    /// Добавляет один набор (после createSet).
    func appendSet(_ set: CardSetAPI) async {
        await MainActor.run {
            let ctx = container.mainContext
            let id = set.id
            let desc = FetchDescriptor<SDCardSet>(predicate: #Predicate { $0.id == id })
            guard (try? ctx.fetch(desc).first) == nil else { return }
            ctx.insert(SDCardSet(from: set))
            try? ctx.save()
        }
    }

    /// Обновляет один набор (после updateSet).
    func updateSet(_ set: CardSetAPI) async {
        await MainActor.run {
            let ctx = container.mainContext
            let id = set.id
            let desc = FetchDescriptor<SDCardSet>(predicate: #Predicate { $0.id == id })
            if let existing = try? ctx.fetch(desc).first {
                existing.name = set.name
                existing.setDescription = set.description
                existing.cardCount = set.cardCount
                existing.learnedCount = set.learnedCount
                existing.isPublic = set.isPublic
                try? ctx.save()
            }
        }
    }

    /// Удаляет один набор и все его карточки (после deleteSet).
    func deleteSet(setId: String) async {
        await MainActor.run {
            let ctx = container.mainContext
            let descSet = FetchDescriptor<SDCardSet>(predicate: #Predicate { $0.id == setId })
            if let existing = try? ctx.fetch(descSet).first {
                ctx.delete(existing)
            }
            let descCards = FetchDescriptor<SDCard>(predicate: #Predicate { $0.setId == setId })
            if let cards = try? ctx.fetch(descCards) {
                cards.forEach { ctx.delete($0) }
            }
            try? ctx.save()
        }
    }

    // MARK: - Cards: individual mutations

    /// Добавляет одну карточку (после createCard).
    func appendCard(_ card: CardAPI) async {
        await MainActor.run {
            let ctx = container.mainContext
            let id = card.id
            let desc = FetchDescriptor<SDCard>(predicate: #Predicate { $0.id == id })
            guard (try? ctx.fetch(desc).first) == nil else { return }
            ctx.insert(SDCard(from: card))
            try? ctx.save()
        }
    }

    /// Обновляет одну карточку (после updateCard).
    func updateCard(_ card: CardAPI) async {
        await MainActor.run {
            let ctx = container.mainContext
            let id = card.id
            let desc = FetchDescriptor<SDCard>(predicate: #Predicate { $0.id == id })
            if let existing = try? ctx.fetch(desc).first {
                existing.front = card.front
                existing.back = card.back
                existing.imageUrl = card.imageUrl
                existing.status = card.status
                existing.nextReview = card.nextReview
                try? ctx.save()
            }
        }
    }

    /// Возвращает одну карточку по её ID (для write-through статуса после ответа в учебной сессии).
    func loadCard(cardId: String) async -> CardAPI? {
        await MainActor.run {
            let ctx = container.mainContext
            let desc = FetchDescriptor<SDCard>(predicate: #Predicate { $0.id == cardId })
            return try? ctx.fetch(desc).first?.toCardAPI()
        }
    }

    /// Удаляет одну карточку (после deleteCard).
    func deleteCard(cardId: String) async {
        await MainActor.run {
            let ctx = container.mainContext
            let desc = FetchDescriptor<SDCard>(predicate: #Predicate { $0.id == cardId })
            if let existing = try? ctx.fetch(desc).first {
                ctx.delete(existing)
                try? ctx.save()
            }
        }
    }

    // MARK: - Clear on sign-out

    func clearAll() async {
        await MainActor.run {
            let ctx = container.mainContext
            try? ctx.delete(model: SDUserProfile.self)
            try? ctx.delete(model: SDCardSet.self)
            try? ctx.delete(model: SDCard.self)
            try? ctx.save()
        }
    }
}
