import Foundation

func performQuotesApiCall() async throws -> Quote {
    let url = URL(string: "https://zenquotes.io/api/today")
    let (data, _) = try await URLSession.shared.data(from: url!)
    
    // Decode the array of quotes
    let quotes = try JSONDecoder().decode([Quote].self, from: data)
    
    return quotes[0] // Assuming the response contains at least one quote
}
