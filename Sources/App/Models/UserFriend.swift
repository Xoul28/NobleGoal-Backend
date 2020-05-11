import FluentMySQL
import Vapor

final class UserFriend: MySQLModel {
    var id: Int?
    var userID: User.ID
    var friendID: User.ID
    init(id: Int? = nil,
         userID: User.ID,
         friendID: User.ID) {
        self.id = id
        self.userID = userID
        self.friendID = friendID
    }
}

extension UserFriend {
    var friend: Parent<UserFriend, User> {
        return parent(\.friendID)
    }

    var user: Parent<UserFriend, User> {
        return parent(\.userID)
    }
}

/// Allows `Todo` to be used as a Fluent migration.
extension UserFriend: Migration {
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(UserFriend.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.userID)
            builder.field(for: \.friendID)
            builder.reference(from: \.friendID, to: \User.id)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
