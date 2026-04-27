import Foundation

enum DeckSetDetailModels {

    struct FlashcardRow: Equatable, Identifiable {
        let id: UUID
        var question: String
        var answer: String
    }
}
