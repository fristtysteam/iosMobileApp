import Foundation
import GRDB

struct Quote: Codable, FetchableRecord, PersistableRecord {
    var quote: String
    var author: String
    var html: String

    enum Columns {
        static let quote = Column(CodingKeys.quote)
        static let author = Column(CodingKeys.author)
        static let html = Column(CodingKeys.html)
    }
}

struct Wrapper: Codable {
    var quotes: [Quote]
}
