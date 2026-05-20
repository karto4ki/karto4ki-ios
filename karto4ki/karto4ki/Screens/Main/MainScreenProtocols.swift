import UIKit

/// Общие отступы контента внутри полупрозрачных карточек на главном (стрик, сообщение, колода/статистика).
enum MainScreenCardLayout {
    static let horizontalContentInset: CGFloat = 10
}

enum MainScreenModels {

    struct Friend {
        let name: String
        let initials: String
        let color: UIColor
    }

    struct StreakDay {
        let dayName: String
        let date: String
        let isActive: Bool
        let isCurrent: Bool
    }

    struct DeckCard {
        let title: String
        let author: String
        let cardCount: Int
    }

    struct ProgressData {
        let percent: Int
        let learned: Int
        let notLearned: Int
        let withErrors: Int
    }

    /// Одна «страница» карусели: колода + её статистика
    struct DeckCarouselItem {
        let deck: DeckCard
        let progress: ProgressData
    }

    struct ViewModel {
        let friends: [Friend]
        let streakDays: [StreakDay]
        /// Подряд идущих активных дней до текущего (включительно) по календарю стрика.
        let currentStreakDayCount: Int
        let deckCarousel: [DeckCarouselItem]
    }

    /// Сколько дней подряд активен стрик, заканчивая днём с `isCurrent == true`.
    static func currentStreakLength(days: [StreakDay]) -> Int {
        guard let i = days.firstIndex(where: { $0.isCurrent }) else { return 0 }
        var n = 0
        var j = i
        while j >= 0 && days[j].isActive {
            n += 1
            j -= 1
        }
        return n
    }
}

protocol MainScreenBusinessLogic {
    func loadData()
}

protocol MainScreenPresentationLogic: AnyObject {
    func presentData(
        friends: [MainScreenModels.Friend],
        streakDays: [MainScreenModels.StreakDay],
        currentStreak: Int,
        deckCarousel: [MainScreenModels.DeckCarouselItem]
    )
}

protocol MainScreenDisplayLogic: AnyObject {
    func displayData(_ viewModel: MainScreenModels.ViewModel)
}
