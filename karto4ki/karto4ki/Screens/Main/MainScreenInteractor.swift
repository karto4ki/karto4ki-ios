import UIKit

final class MainScreenInteractor: MainScreenBusinessLogic {

    private let presenter: MainScreenPresentationLogic

    init(presenter: MainScreenPresentationLogic) {
        self.presenter = presenter
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
            .init(dayName: "чт", date: "19.02", isActive: true,  isCurrent: true),
            .init(dayName: "пт", date: "20.02", isActive: false, isCurrent: false),
            .init(dayName: "сб", date: "21.02", isActive: false, isCurrent: false),
            .init(dayName: "вс", date: "22.02", isActive: false, isCurrent: false)
        ]

        let deck = MainScreenModels.DeckCard(title: "Коллоквиум по ios", author: "lzkgmr", cardCount: 32)
        let progress = MainScreenModels.ProgressData(percent: 26, learned: 8, notLearned: 19, withErrors: 10)

        presenter.presentData(friends: friends, streakDays: streakDays, recentDeck: deck, progress: progress)
    }
}
