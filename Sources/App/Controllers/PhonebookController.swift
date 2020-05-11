import Vapor
import FluentMySQL

final class PhonebookController {
    
    func friends(_ req: Request) throws -> Future<FriendsResponse> {
        // fetch auth'd user
        let user = try req.requireAuthenticated(User.self)
        let userId = try user.requireID()
        
        return UserFriend.query(on: req).filter(\.userID == userId).all().flatMap { friends in
            friends.map { friendEntry in
                return friendEntry.friend.get(on: req).map { friend -> UserEntry in
                    let id = try friend.requireID()
                    return UserEntry(id: id,
                                     phone: friend.phone,
                                     name: friend.name)
                }
            }.flatten(on: req).map { entries in
                return FriendsResponse(friends: entries)
            }
        }
    }

    func phonebook(_ req: Request) throws -> Future<HTTPStatus> {
        // fetch auth'd user
        let user = try req.requireAuthenticated(User.self)

        // decode request content
        return try req.content.decode(PhonebookPostRequest.self).flatMap { phonebookRequest in
            let userId = try user.requireID()
            return phonebookRequest.phones.map { phone in
                return User.query(on: req).filter(\.phone == phone).all().map { friendUsers in
                    return try friendUsers.map { friendUser in
                        return try UserFriend(userID: userId, friendID: friendUser.requireID()).save(on: req)
                    }
                }
            }.flatten(on: req).transform(to: .ok)
        }
    }
}

extension PhonebookController: RouteCollection {
    func boot(router: Router) throws {
        router.get(Constants.Endpoints.Phonebook.getFriends, use: friends)
        router.post(Constants.Endpoints.Phonebook.postPhonebook, use: phonebook)
    }
}

// MARK: Content

struct PhonebookPostRequest: Content {
    var phones: [String]
}

struct FriendsResponse: Content {
    var friends: [UserEntry]
}

struct UserEntry: Codable {
    var id: Int
    var phone: String
    var name: String
}
