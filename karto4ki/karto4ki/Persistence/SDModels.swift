import Foundation
import SwiftData

@Model
final class SDUserProfile {
    @Attribute(.unique) var id: String
    var name: String
    var username: String
    var email: String?
    var photo: String?
    var createdAt: String?
    var notificationEnabled: Bool

    init(
        id: String,
        name: String,
        username: String,
        email: String?,
        photo: String?,
        createdAt: String?,
        notificationEnabled: Bool
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.photo = photo
        self.createdAt = createdAt
        self.notificationEnabled = notificationEnabled
    }

    func toPrivateUserProfile() -> PrivateUserProfile {
        PrivateUserProfile(
            id: id,
            name: name,
            username: username,
            email: email,
            photo: photo,
            createdAt: createdAt,
            notificationEnabled: notificationEnabled
        )
    }
}

@Model
final class SDCardSet {
    @Attribute(.unique) var id: String
    var name: String
    var setDescription: String?
    var cardCount: Int
    var learnedCount: Int
    var isPublic: Bool
    var createdAt: String
    var authorId: String
    var authorUsername: String
    var authorName: String
    var authorPhoto: String?

    init(from api: CardSetAPI) {
        id = api.id
        name = api.name
        setDescription = api.description
        cardCount = api.cardCount
        learnedCount = api.learnedCount
        isPublic = api.isPublic
        createdAt = api.createdAt
        authorId = api.author?.id ?? ""
        authorUsername = api.author?.username ?? ""
        authorName = api.author?.name ?? ""
        authorPhoto = api.author?.photo
    }

    func toCardSetAPI() -> CardSetAPI {
        CardSetAPI(
            id: id,
            name: name,
            description: setDescription,
            cardCount: cardCount,
            learnedCount: learnedCount,
            isPublic: isPublic,
            createdAt: createdAt,
            author: authorId.isEmpty ? nil : AuthorInfoAPI(
                id: authorId,
                username: authorUsername.isEmpty ? nil : authorUsername,
                name: authorName,
                photo: authorPhoto
            )
        )
    }
}

@Model
final class SDCard {
    @Attribute(.unique) var id: String
    var setId: String
    var front: String
    var back: String
    var imageUrl: String?
    var audioUrl: String?
    var status: String
    var nextReview: String?
    var createdAt: String

    init(from api: CardAPI) {
        id = api.id
        setId = api.setId
        front = api.front
        back = api.back
        imageUrl = api.imageUrl
        audioUrl = api.audioUrl
        status = api.status
        nextReview = api.nextReview
        createdAt = api.createdAt
    }

    func toCardAPI() -> CardAPI {
        CardAPI(
            id: id,
            setId: setId,
            front: front,
            back: back,
            imageUrl: imageUrl,
            audioUrl: audioUrl,
            status: status,
            nextReview: nextReview,
            createdAt: createdAt
        )
    }
}
