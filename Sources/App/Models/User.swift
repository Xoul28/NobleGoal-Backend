import Authentication
import FluentMySQL
import Vapor

final class User: MySQLModel {
    /// Can be `nil` if the user has not been saved yet.
    var id: Int?
    
    var name: String
    
    var phone: String
    
    init(id: Int? = nil, name: String, phone: String) {
        self.id = id
        self.name = name
        self.phone = phone
    }
}

extension User {
    var challanges: Siblings<User, Challenge, ChallengeToUser> {
        return siblings()
    }
}


/// Allows users to be verified by bearer / token auth middleware.
extension User: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = UserToken
}

/// Allows `User` to be used as a Fluent migration.
extension User: Migration {
    /// See `Migration`.
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(User.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.phone)
            builder.unique(on: \.phone)
        }
    }
}

/// Allows `User` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }
