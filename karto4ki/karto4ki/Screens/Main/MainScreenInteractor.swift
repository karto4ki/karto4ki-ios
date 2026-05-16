import UIKit

final class MainScreenInteractor: MainScreenBusinessLogic {

    private let presenter: MainScreenPresentationLogic
    private let cardService: CardServiceProtocol

    init(presenter: MainScreenPresentationLogic, cardService: CardServiceProtocol) {
        self.presenter = presenter
        self.cardService = cardService
    }

    func loadData() {
        let friends: [MainScreenModels.Friend] = [
            .init(name: "kurunon", initials: "KU", color: Colors.lilicBAB6FD),
            .init(name: "lzkgmr",  initials: "LZ", color: Colors.lilicA59FFF),
            .init(name: "blunk",   initials: "BL", color: UIColor(red: 0.45, green: 0.72, blue: 0.45, alpha: 1))
        ]

        let streakDays: [MainScreenModels.StreakDay] = [
            .init(dayName: "пн", date: "16.02", isActive: true,  isCurrent: false),
            .init(dayName: "вт", date: "17.02", isActive: true,  isCurrent: false),
            .init(dayName: "ср", date: "18.02", isActive: true,  isCurrent: false),
            .init(dayName: "чт", date: "19.02", isActive: true,  isCurrent: false),
            .init(dayName: "пт", date: "20.02", isActive: true,  isCurrent: true),
            .init(dayName: "сб", date: "21.02", isActive: false, isCurrent: false),
            .init(dayName: "вс", date: "22.02", isActive: false, isCurrent: false)
        ]

        Task {
            let carousel = await buildCarousel()
            await MainActor.run {
                presenter.presentData(friends: friends, streakDays: streakDays, deckCarousel: carousel)
            }
        }
    }

    // MARK: - Private

    private func buildCarousel() async -> [MainScreenModels.DeckCarouselItem] {
        let apiSets = await LocalDataStore.shared.loadCardSets() ?? []
        guard !apiSets.isEmpty else { return [] }

        let decks = apiSets.map { LibraryModels.DeckSet(from: $0) }
        let sorted = DeckAccessStore.sorted(decks)

        var items: [MainScreenModels.DeckCarouselItem] = []
        for deck in sorted {
            var author: String
            if deck.authorName == nil {
                let profile = await LocalDataStore.shared.loadProfile()
                author = profile?.name ?? ""
            } else {
                author = deck.authorName ?? ""
            }
            let setId = deck.id.uuidString.lowercased()
            if let stats = try? await cardService.getSetStats(setId: setId) {
                items.append(MainScreenModels.DeckCarouselItem(
                    deck: .init(
                        title: deck.title,
                        author: author,
                        cardCount: stats.totalCards
                    ),
                    progress: .init(
                        percent: Int(stats.masteryPercentage),
                        learned: stats.learnedCards,
                        notLearned: stats.newCards,
                        withErrors: stats.learningCards
                    )
                ))
            } else {
                let pct = deck.total > 0 ? Int(round(Double(deck.learned) / Double(deck.total) * 100)) : 0
                items.append(MainScreenModels.DeckCarouselItem(
                    deck: .init(title: deck.title, author: author, cardCount: deck.total),
                    progress: .init(percent: pct, learned: deck.learned, notLearned: deck.total - deck.learned, withErrors: 0)
                ))
            }
        }
        return items
    }
}
