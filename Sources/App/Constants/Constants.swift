struct Constants {
    
    struct SideHosts {
        static let botEndpoint = ""
    }
    
    struct Endpoints {
        struct Phonebook {
            static let getFriends = "\(v1)/friends"
            static let postPhonebook = "\(v1)/phonebook"
        }
        
        struct BotApi {
            static let getAuth = "/auth/"
        }
        
        struct User {
            static let postTelegramRegister = "\(v1)/register/telegram"
            static let postMockRegister = "\(v1)/register/mock"
        }
        
        struct Challenges {
            static let getChallenges = "\(v1)/challenges"
            static let putChallenge = "\(v1)/challenge"
            static let postIncreaseCounter = "\(v1)/challenge/increase"
        }
    }
    
    private static let v1 = "/v1"
    private static let v2 = "/v2"
    private static let v3 = "/v3"
    
}
