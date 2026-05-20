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

        Task {
            async let carouselTask = buildCarousel()
            async let statsTask   = fetchStreakData()

            let carousel                    = await carouselTask
            let (streakDays, currentStreak) = await statsTask

            await MainActor.run {
                presenter.presentData(
                    friends: friends,
                    streakDays: streakDays,
                    currentStreak: currentStreak,
                    deckCarousel: carousel
                )
            }
        }
    }

    // MARK: - Streak

    private static let cachedStreakKey = "main_cached_current_streak"

    private func fetchStreakData() async -> ([MainScreenModels.StreakDay], Int) {
        do {
            let stats = try await cardService.getUserStats()
            let streak = stats.currentStreak
            UserDefaults.standard.set(streak, forKey: Self.cachedStreakKey)
            let studiedDates = Set(stats.studyHistory.map { $0.date })
            return (buildWeekDays(studiedDates: studiedDates, streakFallback: streak), streak)
        } catch {
            let cached = UserDefaults.standard.integer(forKey: Self.cachedStreakKey)
            return (buildWeekDays(studiedDates: [], streakFallback: cached), cached)
        }
    }

    /// Строит 7 дней текущей недели (пн–вс).
    /// Приоритет активных дней:
    ///  1. Даты из `study_history` бэкенда
    ///  2. Если история пустая — синтезируем последние `streakFallback` дней до сегодня
    private func buildWeekDays(studiedDates: Set<String>, streakFallback: Int) -> [MainScreenModels.StreakDay] {
        let calendar = Calendar.current
        let today    = Date()

        let isoFmt = DateFormatter()
        isoFmt.locale    = Locale(identifier: "en_US_POSIX")
        isoFmt.dateFormat = "yyyy-MM-dd"

        let displayFmt    = DateFormatter()
        displayFmt.dateFormat = "dd.MM"

        let todayISO = isoFmt.string(from: today)

        // Если бэкенд вернул даты — используем их; иначе строим из числа стрика
        let activeDates: Set<String>
        if !studiedDates.isEmpty {
            activeDates = studiedDates
        } else if streakFallback > 0 {
            activeDates = Set((0..<streakFallback).compactMap { offset in
                calendar.date(byAdding: .day, value: -offset, to: today).map { isoFmt.string(from: $0) }
            })
        } else {
            activeDates = []
        }

        // weekday: 1=вс, 2=пн … 7=сб (григорианский)
        let weekday       = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7   // 0=пн … 6=вс
        let dayNames      = ["пн", "вт", "ср", "чт", "пт", "сб", "вс"]

        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: i - daysFromMonday, to: today)!
            let iso  = isoFmt.string(from: date)
            return MainScreenModels.StreakDay(
                dayName:   dayNames[i],
                date:      displayFmt.string(from: date),
                isActive:  activeDates.contains(iso),
                isCurrent: iso == todayISO
            )
        }
    }

    // MARK: - Carousel

    private func buildCarousel() async -> [MainScreenModels.DeckCarouselItem] {
        let apiSets = await LocalDataStore.shared.loadCardSets() ?? []
        guard !apiSets.isEmpty else { return [] }

        let decks  = apiSets.map { LibraryModels.DeckSet(from: $0) }
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
                    deck: .init(title: deck.title, author: author, cardCount: stats.totalCards),
                    progress: .init(
                        percent:    Int(stats.masteryPercentage),
                        learned:    stats.learnedCards,
                        notLearned: stats.newCards,
                        withErrors: stats.learningCards
                    )
                ))
            } else {
                let pct = deck.total > 0
                    ? Int(round(Double(deck.learned) / Double(deck.total) * 100))
                    : 0
                items.append(MainScreenModels.DeckCarouselItem(
                    deck: .init(title: deck.title, author: author, cardCount: deck.total),
                    progress: .init(percent: pct, learned: deck.learned, notLearned: deck.total - deck.learned, withErrors: 0)
                ))
            }
        }
        return items
    }
}
