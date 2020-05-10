import FluentMySQL
import Vapor

final class ChallengeToUser: MySQLPivot {
    
    typealias Left = Challenge
    typealias Right = User
    
    static var leftIDKey: LeftIDKey = \.challengeID
    static var rightIDKey: RightIDKey = \.userID
    
    var id: Int?
    var challengeID: Challenge.ID
    var userID: User.ID

    init(challengeID: Challenge.ID, userID: User.ID) {
        self.challengeID = challengeID
        self.userID = userID
    }
    
}


extension ChallengeToUser: Migration {
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(ChallengeToUser.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.challengeID)
            builder.field(for: \.userID)
            builder.reference(from: \.challengeID, to: \Challenge.id)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension ChallengeToUser: ModifiablePivot {
    convenience init(_ left: Challenge, _ right: User) throws {
        self.init(challengeID: try left.requireID(), userID: try right.requireID())
    }
}
