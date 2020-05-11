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
                    _ = User.find(userId, on: req).map { foundUser in
                        return foundUser?.challanges.attach(chall, on: req)
                    }
                }
                _ = user.challanges.attach(chall, on: req)
                return chall
            }
        }
    }
    
    func increase(_ req: Request) throws -> Future<HTTPStatus> {
        // fetch auth'd user
        let user = try req.requireAuthenticated(User.self)
        
        // decode request content
        return try req.content.decode(IncreaseCounter.self).flatMap { increaseRequest -> Future<UserRaisedToChallenge> in
            
            return Challenge.find(increaseRequest.challengeId, on: req).unwrap(or: Abort(.notFound)).flatMap { challenge -> Future<UserRaisedToChallenge> in
                challenge.numberCompleted += increaseRequest.value
                let challengeId = challenge.id
                return challenge.update(on: req).flatMap { challenge in
                    let userRaisedToChallenge = UserRaisedToChallenge(raisedValue: increaseRequest.value,
                                                                      userID: try user.requireID(),
                                                                      challengeID: challengeId!)
                    return userRaisedToChallenge.save(on: req)
                }
            }
        }.transform(to: .ok)
    }
}

extension ChallengeController: RouteCollection {
    func boot(router: Router) throws {
        router.get(Constants.Endpoints.Challenges.getChallenges, use: index)
        router.put(Constants.Endpoints.Challenges.putChallenge, use: create)
        router.post(Constants.Endpoints.Challenges.postIncreaseCounter, use: increase)
    }
}

// MARK: Content

struct IncreaseCounter: Content {
    var challengeId: Int
    var value: Int
    
    private enum CodingKeys: String, CodingKey {
        case challengeId = "challenge_id"
        case value
    }
}

struct CreateChallengeRequest: Content {
    var goalTitle: String
    var numberToAchieve: Int
    var finishDate: Date
    var startDate: Date
    var usersIds: [Int]
    
    private enum CodingKeys: String, CodingKey {
        case goalTitle = "goal_title"
        case numberToAchieve = "number_to_achieve"
        case finishDate = "finish_date"
        case startDate = "start_date"
        case usersIds = "users_ids"
    }
}
