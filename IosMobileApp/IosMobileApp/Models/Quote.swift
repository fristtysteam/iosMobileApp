import Foundation
import GRDB

struct Quote: Codable, FetchableRecord, PersistableRecord {
    var quote: String
    var author: String
    var html: String

    enum Columns {
        static let quote = Column("quote")
        static let author = Column("author")
        static let html = Column("html")
    }
}

struct Wrapper: Codable {
    var quotes: [Quote]
}
