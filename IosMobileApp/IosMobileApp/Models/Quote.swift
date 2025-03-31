import Foundation

struct Quote: Codable {
    var quote: String 
    var author: String
    var html: String

    enum CodingKeys: String, CodingKey {
        case quote = "q"
        case author = "a"
        case html = "h"
    }
}

struct Wrapper: Codable {
    var quotes: [Quote]
}
