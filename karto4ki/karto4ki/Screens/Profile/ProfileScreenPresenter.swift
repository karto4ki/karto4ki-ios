import Foundation

final class ProfileScreenPresenter: ProfileScreenPresentationLogic {

    weak var view: ProfileScreenDisplayLogic?

    func presentProfile(_ profile: PrivateUserProfile) {
        let vm = ProfileScreenModels.ViewModel(
            name: profile.name,
            username: profile.username,
            emailDisplay: profile.email?.isEmpty == false ? profile.email! : "не указан",
            memberSinceDisplay: Self.formatMemberSince(profile.createdAt),
            photoURL: profile.photo.flatMap { URL(string: $0) },
            initials: Self.initials(from: profile.name),
            notificationEnabled: profile.notificationEnabled
        )
        Task { @MainActor in
            view?.displayLoading(false)
            view?.displayProfile(vm)
        }
    }

    func presentLoading(_ isLoading: Bool) {
        Task { @MainActor in
            view?.displayLoading(isLoading)
        }
    }
}

// MARK: - Formatting

private extension ProfileScreenPresenter {

    static func initials(from name: String) -> String {
        let parts = name.split(separator: " ").map(String.init)
        if parts.count >= 2 {
            let a = parts[0].prefix(1)
            let b = parts[1].prefix(1)
            return (a + b).uppercased()
        }
        if let first = parts.first, first.count >= 2 {
            return String(first.prefix(2)).uppercased()
        }
        return parts.first?.uppercased() ?? "?"
    }

    static func formatMemberSince(_ raw: String?) -> String {
        guard let raw, !raw.isEmpty else { return "—" }
        let inFormatter = DateFormatter()
        inFormatter.locale = Locale(identifier: "en_US_POSIX")
        inFormatter.dateFormat = "yyyy-MM-dd"
        let prefix = String(raw.prefix(10))
        guard let date = inFormatter.date(from: prefix) else {
            return raw
        }
        let outFormatter = DateFormatter()
        outFormatter.locale = Locale(identifier: "ru_RU")
        outFormatter.dateStyle = .long
        outFormatter.timeStyle = .none
        return "с \(outFormatter.string(from: date))"
    }
}
