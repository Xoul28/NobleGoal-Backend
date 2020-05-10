import Vapor
import FluentMySQL

final class ChallengeController {
    
    func index(_ req: Request) throws -> Future<[Challenge]> {
        // fetch auth'd user
        let user = try req.requireAuthenticated(User.self)
        
        return try user.challanges.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> Future<Challenge> {
        // fetch auth'd user
        let user = try req.requireAuthenticated(User.self)
        
        // decode request content
        return try req.content.decode(CreateChallengeRequest.self).flatMap { challengeRequest in
            // save new challenge
            let challengeDO = Challenge(goalTitle: challengeRequest.goalTitle,
                                        numberToAchieve: challengeRequest.numberToAchieve,
                                        finishDate: challengeRequest.finishDate,
                                        startDate: challengeRequest.startDate)
            return challengeDO.create(on: req).map { chall in
                for userId in challengeRequest.usersIds {
                    User.find(userId, on: req).map { foundUser in
                        return foundUser?.challanges.attach(chall, on: req)
                    }
                }
                user.challanges.attach(chall, on: req)
                return chall
            }
        }
    }
//
//    /// Deletes an existing todo for the auth'd user.
//    func delete(_ req: Request) throws -> Future<HTTPStatus> {
//        // fetch auth'd user
//        let user = try req.requireAuthenticated(User.self)
//        
//        // decode request parameter (todos/:id)
//        return try req.parameters.next(Todo.self).flatMap { todo -> Future<Void> in
//            // ensure the todo being deleted belongs to this user
//            guard try todo.userID == user.requireID() else {
//                throw Abort(.forbidden)
//            }
//            
//            // delete model
//            return todo.delete(on: req)
//        }.transform(to: .ok)
//    }
}

extension ChallengeController: RouteCollection {
    func boot(router: Router) throws {
        router.get("challenges", use: index)
        router.post("challenge", use: create)
//        router.delete("challenge", Challenge.parameter, use: delete)
    }
}

// MARK: Content

struct CreateChallengeRequest: Content {
    var goalTitle: String
    var numberToAchieve: Int
    var finishDate: Date
    var startDate: Date
    var usersIds: [Int]
    
    private enum CodingKeys : String, CodingKey {
        case goalTitle = "goal_title"
        case numberToAchieve = "number_to_achieve"
        case finishDate = "finish_date"
        case startDate = "start_date"
        case usersIds = "users_ids"
    }
}
