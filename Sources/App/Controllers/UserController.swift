import Crypto
import Vapor
import FluentMySQL

/// Creates new users and logs them in.
final class UserController {
    
    func registerWithTelegram(_ req: Request)  throws -> Future<UserToken> {
        return try req.content.decode(RegisterUserWithTokenRequest.self).flatMap { tokenRequest in
            //fetching user data from bot server
            return HTTPClient.connect(hostname: Constants.SideHosts.botEndpoint, port: 8081, on: req).flatMap { client in
                let httpReq = HTTPRequest(method: .GET, url: Constants.Endpoints.BotApi.getAuth, headers: HTTPHeaders([("token", tokenRequest.token)]))
                return client.send(httpReq).flatMap { httpRes in
                    guard let userData = try? JSONDecoder().decode(UserFromBotResponse.self, from: httpRes.body.description) else {
                        throw Abort(.badRequest, reason: "Cannot decode user from bot response")
                    }
                    return User(name: userData.name, phone: userData.phone).save(on: req).flatMap { user in
                        let token = try UserToken.create(userID: user.requireID())
                        return token.save(on: req)
                    }
                }
            }
        }
    }
    
    //TODO: Delete after release
    func mockRegister(_ req: Request)  throws -> Future<UserToken> {
        return try req.content.decode(UserFromBotResponse.self).flatMap { userData in
            //fetching user data from bot server
            return User(name: userData.name, phone: userData.phone).save(on: req).flatMap { user in
                let token = try UserToken.create(userID: user.requireID())
                return token.save(on: req)
            }
            
        }
    }
}

extension UserController: RouteCollection {
    func boot(router: Router) throws {
        router.post(Constants.Endpoints.User.postTelegramRegister, use: registerWithTelegram)
        router.post(Constants.Endpoints.User.postMockRegister, use: mockRegister)
    }
}

// MARK: Content
struct RegisterUserWithTokenRequest: Content {
    var token: String
}
/// Public representation of user data.
struct UserFromBotResponse: Content {
    var id: String
    var name: String
    var phone: String
}
