import Foundation

func performQuotesApiCall() async throws -> Quote {
    guard let url = URL(string: "https://zenquotes.io/api/today") else {
        throw URLError(.badURL)
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    // Decode the array of quotes
    let quotes = try JSONDecoder().decode([Quote].self, from: data)
    
    guard let firstQuote = quotes.first else {
        throw URLError(.cannotParseResponse)
    }
    
    return firstQuote
}
