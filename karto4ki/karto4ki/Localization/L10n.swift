import Foundation

// MARK: - Bundle loader

private var _l10nBundle: Bundle?

var l10nBundle: Bundle {
    if let b = _l10nBundle { return b }
    let saved = UserDefaults.standard.string(forKey: "AppLanguage")
    let sysLang = Locale.current.language.languageCode?.identifier ?? "ru"
    let lang = saved ?? (sysLang == "ru" ? "ru" : "en")
    let resolved = (lang == "en") ? "en" : "ru"
    if let path = Bundle.main.path(forResource: resolved, ofType: "lproj"),
       let bundle = Bundle(path: path) {
        _l10nBundle = bundle
        return bundle
    }
    _l10nBundle = .main
    return .main
}

/// Saves the chosen language code ("ru" or "en") and resets the bundle cache.
func setAppLanguage(_ lang: String) {
    UserDefaults.standard.set(lang, forKey: "AppLanguage")
    _l10nBundle = nil
}

var currentAppLanguage: String {
    UserDefaults.standard.string(forKey: "AppLanguage")
        ?? (Locale.current.language.languageCode?.identifier == "ru" ? "ru" : "en")
}

func L(_ key: String) -> String {
    NSLocalizedString(key, bundle: l10nBundle, comment: "")
}

func Lf(_ key: String, _ args: CVarArg...) -> String {
    String(format: L(key), arguments: args)
}

private func ruPlural(_ n: Int, one: String, few: String, many: String) -> String {
    let m100 = n % 100, m10 = n % 10
    if m100 >= 11 && m100 <= 19 { return many }
    switch m10 {
    case 1: return one
    case 2, 3, 4: return few
    default: return many
    }
}

private var isRussian: Bool {
    let saved = UserDefaults.standard.string(forKey: "AppLanguage")
    let sys = Locale.current.language.languageCode?.identifier ?? "ru"
    return (saved ?? (sys == "ru" ? "ru" : "en")) == "ru"
}

// MARK: - L10n

enum L10n {

    enum Common {
        static var ok:     String { L("common.ok") }
        static var cancel: String { L("common.cancel") }
        static var save:   String { L("common.save") }
        static var delete: String { L("common.delete") }
        static var create: String { L("common.create") }
        static var error:  String { L("common.error") }
        static var done:   String { L("common.done") }
        static var add:    String { L("common.add") }
        static var or:     String { L("common.or") }
        static var question: String { L("common.question") }
        static var answer:   String { L("common.answer") }
        static var change:   String { L("common.change") }
        static var chooseSource: String { L("common.choose_source") }
        static var files:        String { L("common.files") }
        static func author(_ name: String) -> String { Lf("common.author", name) }
        static func created(_ date: String) -> String { Lf("common.created", date) }
        static var createdToday:     String { L("common.created_today") }
        static var createdYesterday: String { L("common.created_yesterday") }
        static func createdDate(_ d: String) -> String { Lf("common.created_date", d) }
    }

    enum SignIn {
        static var title:          String { L("signin.title") }
        static var emailLabel:     String { L("signin.email_label") }
        static var emailPlaceholder: String { L("signin.email_placeholder") }
        static var continueApple:  String { L("signin.continue_apple") }
        static var continueGoogle: String { L("signin.continue_google") }
        static var getCode:        String { L("signin.get_code") }
    }

    enum Registration {
        static var nameWord:       String { L("registration.name_word") }
        static var usernameWord:   String { L("registration.username_word") }
        static var nameLabel:      String { L("registration.name_label") }
        static var usernameLabel:  String { L("registration.username_label") }
        static func nameValue(_ v: String) -> String { Lf("registration.name_value", v) }
        static func usernameValue(_ v: String) -> String { Lf("registration.username_value", v) }
        static var confirm:        String { L("registration.confirm") }
        static var enterPrompt:    String { L("registration.enter_prompt") }
    }

    enum Code {
        static var title:        String { L("code.title") }
        static var subtitle:     String { L("code.subtitle") }
        static var resendPrefix: String { L("code.resend_prefix") }
        static var resend:       String { L("code.resend") }
    }

    enum Onboarding {
        static var page1Title:    String { L("onboarding.page1.title") }
        static var page1Subtitle: String { L("onboarding.page1.subtitle") }
        static var page2Title:    String { L("onboarding.page2.title") }
        static var page2Subtitle: String { L("onboarding.page2.subtitle") }
        static var page3Title:    String { L("onboarding.page3.title") }
        static var page3Subtitle: String { L("onboarding.page3.subtitle") }
        static var page4Title:    String { L("onboarding.page4.title") }
        static var page4Subtitle: String { L("onboarding.page4.subtitle") }
        static var continueButton: String { L("onboarding.continue") }
    }

    enum Main {
        static var searchPlaceholder: String { L("main.search_placeholder") }
        static var statsPlaceholder:  String { L("main.stats_placeholder") }
        static var streakEmpty:       String { L("main.streak_empty") }

        static func streakActive(_ count: Int) -> String {
            let fmt = L("main.streak_active_format")
            let word: String
            if isRussian {
                word = ruPlural(count,
                    one: L("main.day.one"), few: L("main.day.few"), many: L("main.day.many"))
            } else {
                word = count == 1 ? L("main.day.one") : L("main.day.many")
            }
            return String(format: fmt, count, word)
        }
    }

    enum Carousel {
        static func author(_ name: String) -> String { Lf("carousel.author", name) }
        static func cardCount(_ n: Int) -> String {
            let fmt = L("carousel.card_count_format")
            let word: String
            if isRussian {
                word = ruPlural(n,
                    one: L("carousel.card.one"), few: L("carousel.card.few"), many: L("carousel.card.many"))
            } else {
                word = n == 1 ? L("carousel.card.one") : L("carousel.card.many")
            }
            return String(format: fmt, n, word)
        }
        static func learned(_ n: Int) -> String    { Lf("carousel.learned", n) }
        static func notLearned(_ n: Int) -> String { Lf("carousel.not_learned", n) }
        static func withErrors(_ n: Int) -> String { Lf("carousel.with_errors", n) }
    }

    enum Library {
        static var title:                 String { L("library.title") }
        static var newFolderTitle:        String { L("library.new_folder_title") }
        static var newFolderMessage:      String { L("library.new_folder_message") }
        static var newFolderPlaceholder:  String { L("library.new_folder_placeholder") }
        static var studyAllFull:          String { L("library.study_all_full") }
        static var studyAllShort:     String { L("library.study_all_short") }
        static var studyAllComingSoon: String { L("library.study_all_coming_soon") }
        static var empty:             String { L("library.empty") }
        static var deleteDeck:        String { L("library.delete_deck") }
        static var deleteFolder:      String { L("library.delete_folder") }
        static func searchEmpty(_ q: String) -> String  { Lf("library.search_empty", q) }
        static func searchResults(_ q: String) -> String { Lf("library.search_results", q) }
        static var deckFromYou:       String { L("library.deck_from_you") }
        static var deckFromOther:     String { L("library.deck_from_other") }
        static var addToLibraryTitle: String { L("library.add_to_library_title") }
        static func addToLibraryMessage(_ title: String) -> String { Lf("library.add_to_library_message", title) }
        static var addToLibraryButton: String { L("library.add_to_library_button") }
        static var searchError:       String { L("library.search_error") }
        static func cloneError(_ msg: String) -> String { Lf("library.clone_error", msg) }
        static func progress(_ learned: Int, _ total: Int) -> String { Lf("library.progress", learned, total) }
    }

    enum DeckDetail {
        static var cardFrontPlaceholder: String { L("deckdetail.card_front_placeholder") }
        static var cardBackPlaceholder:  String { L("deckdetail.card_back_placeholder") }
        static var studyRemember:        String { L("deckdetail.study_remember") }
        static var studyTypeAnswer:      String { L("deckdetail.study_type_answer") }
        static var statLearned:          String { L("deckdetail.stat_learned") }
        static var statUnlearned:        String { L("deckdetail.stat_unlearned") }
        static var statTotal:            String { L("deckdetail.stat_total") }
        static var statPct:              String { L("deckdetail.stat_pct") }
        static var addToLibrary:         String { L("deckdetail.add_to_library") }
        static var cards:                String { L("deckdetail.cards") }
        static var typeAnswerComingSoon:  String { L("deckdetail.type_answer_coming_soon") }
        static var addedTitle:           String { L("deckdetail.added_title") }
        static var addedMessage:         String { L("deckdetail.added_message") }
        static var newCard:              String { L("deckdetail.new_card") }
        static var editCard:             String { L("deckdetail.edit_card") }
        static var deleteCard:           String { L("deckdetail.delete_card") }
        static var authorCommunity:      String { L("deckdetail.author_community") }
        static var authorYou:            String { L("deckdetail.author_you") }
        static var fillBothFields:       String { L("deckdetail.fill_both_fields") }
    }

    enum Study {
        static var listen:           String { L("study.listen") }
        static var dontRemember:     String { L("study.dont_remember") }
        static var remember:         String { L("study.remember") }
        static var settingsComingSoon: String { L("study.settings_coming_soon") }
        static func ttsComingSoon(_ title: String) -> String { Lf("study.tts_coming_soon", title) }
        static var deckEmpty:         String { L("study.deck_empty") }
        static var sessionFinished:   String { L("study.session_finished") }
    }

    enum AddDeck {
        static var title:              String { L("adddeck.title") }
        static var nameTitle:          String { L("adddeck.name_title") }
        static var namePlaceholder:    String { L("adddeck.name_placeholder") }
        static var aiTitle:            String { L("adddeck.ai_title") }
        static var aiSubtitle:         String { L("adddeck.ai_subtitle") }
        static var uploadTitle:        String { L("adddeck.upload_title") }
        static var uploadHint:         String { L("adddeck.upload_hint") }
        static var orManual:           String { L("adddeck.or_manual") }
        static var manualTitle:        String { L("adddeck.manual_title") }
        static var addCard:            String { L("adddeck.add_card") }
        static var createSet:          String { L("adddeck.create_set") }
        static var generating:         String { L("adddeck.generating") }
        static func generatedMessage(_ f: String) -> String { Lf("adddeck.generated_message", f) }
        static var nameRequired:       String { L("adddeck.name_required") }
        static var cardsRequired:      String { L("adddeck.cards_required") }
        static var serviceUnavailable: String { L("adddeck.service_unavailable") }
        static func createdMessage(_ n: String) -> String { Lf("adddeck.created_message", n) }
        static var questionPlaceholder: String { L("adddeck.question_placeholder") }
        static var answerPlaceholder:  String { L("adddeck.answer_placeholder") }
    }

    enum AIGeneration {
        static var title:      String { L("aigeneration.title") }
        static var subtitle:   String { L("aigeneration.subtitle") }
        static var errorTitle: String { L("aigeneration.error_title") }
    }

    enum Profile {
        static var title:                  String { L("profile.title") }
        static var email:                  String { L("profile.email") }
        static var notificationsTitle:     String { L("profile.notifications_title") }
        static var notificationsSubtitle:  String { L("profile.notifications_subtitle") }
        static var languageTitle:          String { L("profile.language_title") }
        static var languageRu:             String { L("profile.language_ru") }
        static var languageEn:             String { L("profile.language_en") }
        static var languageChangedTitle:   String { L("profile.language_changed_title") }
        static var languageChangedMessage: String { L("profile.language_changed_message") }
        static var testModeTitle:          String { L("profile.testmode_title") }
        static var testModeSubtitle:       String { L("profile.testmode_subtitle") }
        static var testModeBadge:          String { L("profile.testmode_badge") }
        static var logoutTitle:            String { L("profile.logout_title") }
        static var logoutSubtitle:         String { L("profile.logout_subtitle") }
        static var avatarPreview:          String { L("profile.avatar_preview") }
        static var avatarCamera:           String { L("profile.avatar_camera") }
        static var avatarLibrary:          String { L("profile.avatar_library") }
        static var cameraUnavailable:      String { L("profile.camera_unavailable") }
        static var editData:               String { L("profile.edit_data") }
        static var namePlaceholder:        String { L("profile.name_placeholder") }
        static var usernamePlaceholder:    String { L("profile.username_placeholder") }
        static var deleteAccountAction:    String { L("profile.delete_account_action") }
        static var deleteAccountTitle:     String { L("profile.delete_account_title") }
        static var deleteAccountMessage:   String { L("profile.delete_account_message") }
        static var signOutTitle:           String { L("profile.signout_title") }
        static var signOutAction:          String { L("profile.signout_action") }
        static var emailUnspecified:       String { L("profile.email_unspecified") }
        static func memberSince(_ date: String) -> String { Lf("profile.member_since", date) }
    }
}
