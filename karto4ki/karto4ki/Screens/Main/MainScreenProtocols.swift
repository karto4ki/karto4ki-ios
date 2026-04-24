import UIKit

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
        let deckCarousel: [DeckCarouselItem]
    }
}

protocol MainScreenBusinessLogic {
    func loadData()
}

protocol MainScreenPresentationLogic: AnyObject {
    func presentData(
        friends: [MainScreenModels.Friend],
        streakDays: [MainScreenModels.StreakDay],
        deckCarousel: [MainScreenModels.DeckCarouselItem]
    )
}

protocol MainScreenDisplayLogic: AnyObject {
    func displayData(_ viewModel: MainScreenModels.ViewModel)
}
