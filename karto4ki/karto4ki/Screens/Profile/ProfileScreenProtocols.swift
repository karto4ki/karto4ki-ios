import Foundation

protocol ProfileScreenBusinessLogic: AnyObject {
    func loadProfile()
    func signOut()
    func updateDisplayNameAndUsername(name: String, username: String)
    func setNotificationEnabled(_ enabled: Bool)
}

protocol ProfileScreenPresentationLogic: AnyObject {
    func presentProfile(_ profile: PrivateUserProfile)
    func presentLoading(_ isLoading: Bool)
}

protocol ProfileScreenDisplayLogic: AnyObject {
    func displayProfile(_ viewModel: ProfileScreenModels.ViewModel)
    func displayLoading(_ isLoading: Bool)
}

enum ProfileScreenModels {

    struct ViewModel {
        let name: String
        let username: String
        let emailDisplay: String
        let memberSinceDisplay: String
        let photoURL: URL?
        let initials: String
        let notificationEnabled: Bool
    }
}
