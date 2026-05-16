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
            return try? ctx.fetch(desc).first?.toPrivateUserProfile()
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
