import FluentMySQL
import Vapor

final class UserRaisedToChallenge: MySQLModel {
    var id: Int?
    var raisedValue: Int
    var insertedAt: Date
    var userID: User.ID
    var challengeID: Challenge.ID
    init(id: Int? = nil,
         raisedValue: Int,
         userID: User.ID,
         challengeID: Challenge.ID) {
        self.id = id
        self.raisedValue = raisedValue
        self.insertedAt = Date()
        self.userID = userID
        self.challengeID = challengeID
    }
}

extension UserRaisedToChallenge {
    
    var challenge: Parent<UserRaisedToChallenge, Challenge> {
        return parent(\.challengeID)
    }

    var user: Parent<UserRaisedToChallenge, User> {
        return parent(\.userID)
    }
}

/// Allows `Todo` to be used as a Fluent migration.
extension UserRaisedToChallenge: Migration {
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(UserRaisedToChallenge.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.raisedValue)
            builder.field(for: \.insertedAt)
            builder.field(for: \.userID)
            builder.field(for: \.challengeID)
            builder.reference(from: \.challengeID, to: \Challenge.id)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension UserRaisedToChallenge: Content { }

extension UserRaisedToChallenge: Parameter { }
