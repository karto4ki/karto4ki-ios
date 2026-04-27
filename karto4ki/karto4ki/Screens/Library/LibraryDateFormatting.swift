import Foundation

enum LibraryDateFormatting {

    static func createdLabel(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            return "создано сегодня"
        }
        if cal.isDateInYesterday(date) {
            return "создано вчера"
        }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ru_RU")
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return "создано \(fmt.string(from: date))"
    }
}
