import Foundation

// MARK: - API Response Models

struct CardSetAPI: Decodable {
    let id: String
    let name: String
    let description: String?
    let cardCount: Int
    let learnedCount: Int
    let isPublic: Bool
    let createdAt: String
    let author: AuthorInfoAPI?

    enum CodingKeys: String, CodingKey {
        case id, name, description, author
        case cardCount    = "card_count"
        case learnedCount = "learned_count"
        case isPublic     = "is_public"
        case createdAt    = "created_at"
    }
}

struct CardSetDetailAPI: Decodable {
    let id: String
    let name: String
    let description: String?
    let cardCount: Int
    let learnedCount: Int
    let isPublic: Bool
    let createdAt: String
    let author: AuthorInfoAPI?
    let cards: [CardPreviewAPI]

    enum CodingKeys: String, CodingKey {
        case id, name, description, cards, author
        case cardCount    = "card_count"
        case learnedCount = "learned_count"
        case isPublic     = "is_public"
        case createdAt    = "created_at"
    }
}

struct CardAPI: Decodable {
    let id: String
    let setId: String
    let front: String
    let back: String
    let imageUrl: String?
    let audioUrl: String?
    let status: String
    let nextReview: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, front, back, status
        case setId      = "set_id"
        case imageUrl   = "image_url"
        case audioUrl   = "audio_url"
        case nextReview = "next_review"
        case createdAt  = "created_at"
    }
}

struct CardPreviewAPI: Decodable {
    let id: String
    let front: String
    let status: String
}

struct AuthorInfoAPI: Decodable {
    let id: String
    let username: String?
    let name: String
    let photo: String?
}

struct CardSetsResponseAPI: Decodable {
    let sets: [CardSetAPI]
    let offset: Int
    let count: Int

    private enum CodingKeys: String, CodingKey { case sets, offset, count }

    // Go маршалит nil-срез как JSON null; `decodeIfPresent` корректно даёт [] в обоих случаях.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        sets   = try c.decodeIfPresent([CardSetAPI].self, forKey: .sets)  ?? []
        offset = try c.decodeIfPresent(Int.self,          forKey: .offset) ?? 0
        count  = try c.decodeIfPresent(Int.self,          forKey: .count)  ?? 0
    }

    /// Прямой инициализатор для создания из кэша (кастомный init(from:) подавляет memberwise).
    init(sets: [CardSetAPI], offset: Int, count: Int) {
        self.sets   = sets
        self.offset = offset
        self.count  = count
    }
}

struct CardsResponseAPI: Decodable {
    let cards: [CardAPI]
    let offset: Int
    let count: Int

    private enum CodingKeys: String, CodingKey { case cards, offset, count }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        cards  = try c.decodeIfPresent([CardAPI].self, forKey: .cards)  ?? []
        offset = try c.decodeIfPresent(Int.self,       forKey: .offset) ?? 0
        count  = try c.decodeIfPresent(Int.self,       forKey: .count)  ?? 0
    }

    /// Прямой инициализатор для создания из кэша (кастомный init(from:) подавляет memberwise).
    init(cards: [CardAPI], offset: Int, count: Int) {
        self.cards  = cards
        self.offset = offset
        self.count  = count
    }
}

struct StudySessionAPI: Decodable {
    let id: String
    let setId: String
    let cards: [CardAPI]
    let sessionType: String

    enum CodingKeys: String, CodingKey {
        case id, cards
        case setId       = "set_id"
        case sessionType = "session_type"
    }
}

struct AnswerResultAPI: Decodable {
    let cardId: String
    let newStatus: String
    let nextReview: String
    let streak: Int
    let errorCount: Int
    let lastRating: Int

    enum CodingKeys: String, CodingKey {
        case streak
        case cardId     = "card_id"
        case newStatus  = "new_status"
        case nextReview = "next_review"
        case errorCount = "error_count"
        case lastRating = "last_rating"
    }
}

struct SetStatisticsAPI: Decodable {
    let setId: String
    let totalCards: Int
    let learnedCards: Int
    let learningCards: Int
    let newCards: Int
    let masteryPercentage: Float
    let studyHistory: [StudyDayAPI]

    enum CodingKeys: String, CodingKey {
        case studyHistory      = "study_history"
        case setId             = "set_id"
        case totalCards        = "total_cards"
        case learnedCards      = "learned_cards"
        case learningCards     = "learning_cards"
        case newCards          = "new_cards"
        case masteryPercentage = "mastery_percentage"
    }
}

struct UserStatisticsAPI: Decodable {
    let totalSets: Int
    let totalCards: Int
    let learnedCards: Int
    let currentStreak: Int
    let longestStreak: Int
    let lastStudyDate: String?
    let totalStudyTimeMinutes: Int
    let studyHistory: [StudyDayAPI]

    enum CodingKeys: String, CodingKey {
        case studyHistory          = "study_history"
        case totalSets             = "total_sets"
        case totalCards            = "total_cards"
        case learnedCards          = "learned_cards"
        case currentStreak         = "current_streak"
        case longestStreak         = "longest_streak"
        case lastStudyDate         = "last_study_date"
        case totalStudyTimeMinutes = "total_study_time_minutes"
    }
}

struct StudyDayAPI: Decodable {
    let date: String
    let cardsStudied: Int
    let timeSpentMinutes: Int

    enum CodingKeys: String, CodingKey {
        case date
        case cardsStudied      = "cards_studied"
        case timeSpentMinutes  = "time_spent_minutes"
    }
}

struct SearchSetsResponseAPI: Decodable {
    let sets: [CardSetAPI]
    let offset: Int
    let count: Int
}

// MARK: - Request Models

struct CreateCardSetRequestAPI: Encodable {
    let name: String
    let description: String?
    let isPublic: Bool

    enum CodingKeys: String, CodingKey {
        case name, description
        case isPublic = "is_public"
    }
}

struct UpdateCardSetRequestAPI: Encodable {
    let name: String?
    let description: String?
    let isPublic: Bool?

    enum CodingKeys: String, CodingKey {
        case name, description
        case isPublic = "is_public"
    }
}

struct CreateCardRequestAPI: Encodable {
    let front: String
    let back: String
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case front, back
        case imageUrl = "image_url"
    }
}

struct UpdateCardRequestAPI: Encodable {
    let front: String?
    let back: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case front, back
        case imageUrl = "image_url"
    }
}

struct StartStudyRequestAPI: Encodable {
    let sessionType: String
    let limit: Int

    enum CodingKeys: String, CodingKey {
        case sessionType = "session_type"
        case limit
    }
}

struct SubmitAnswerRequestAPI: Encodable {
    let cardId: String
    /// 0 — забыл, 1 — помню (CardRating на бэкенде)
    let rating: Int
    let timeSpentMs: Int?

    enum CodingKeys: String, CodingKey {
        case cardId      = "card_id"
        case rating
        case timeSpentMs = "time_spent_ms"
    }
}
