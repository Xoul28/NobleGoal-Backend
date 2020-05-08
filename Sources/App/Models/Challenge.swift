import FluentMySQL
import Vapor

final class Challenge: MySQLModel {
    var id: Int?
    var goalTitle: String
    var numberToAchieve: Int
    var numberCompleted: Int
    var finishDate: Date
    var startDate: Date
    init(id: Int? = nil,
         goalTitle: String,
         numberToAchieve: Int,
         finishDate: Date,
         startDate: Date) {
        self.id = id
        self.goalTitle = goalTitle
        self.numberToAchieve = numberToAchieve
        self.finishDate = finishDate
        self.startDate = startDate
        numberCompleted = 0
    }
}

extension Challenge {
    var users: Siblings<Challenge, User, ChallengeToUser> {
        return siblings()
    }

}

extension Challenge: Migration {
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(Challenge.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.goalTitle)
            builder.field(for: \.numberToAchieve)
            builder.field(for: \.numberCompleted)
            builder.field(for: \.finishDate)
            builder.field(for: \.startDate)
        }
    }
}

extension Challenge: Content { }

extension Challenge: Parameter { }
