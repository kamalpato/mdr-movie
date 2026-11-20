import Foundation

protocol HTTPSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPSession {}

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

struct Endpoint: Equatable {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]

    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = []
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIError: LocalizedError, Equatable {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case decodingFailed
    case emptyData
    case server(statusCode: Int)
    case underlying(message: String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing TMDB API key. Add API_KEY to your .env file."
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid response from server."
        case .decodingFailed:
            return "Failed to decode response."
        case .emptyData:
            return "No data returned from server."
        case .server(let statusCode):
            return "Server error (\(statusCode))."
        case .underlying(let message):
            return message
        }
    }
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()

    private let session: HTTPSession
    private let baseURL: URL
    private let apiKeyProvider: () -> String
    private let decoder: JSONDecoder

    init(
        session: HTTPSession = URLSession.shared,
        baseURL: URL = AppConfig.tmdbBaseURL,
        apiKeyProvider: @escaping () -> String = { AppConfig.tmdbAPIKey },
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.baseURL = baseURL
        self.apiKeyProvider = apiKeyProvider
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let apiKey = apiKeyProvider().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty else {
            throw APIError.missingAPIKey
        }

        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }

        var queryItems = endpoint.queryItems
        queryItems.append(URLQueryItem(name: "api_key", value: apiKey))
        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.server(statusCode: httpResponse.statusCode)
            }

            guard !data.isEmpty else {
                throw APIError.emptyData
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingFailed
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.underlying(message: error.localizedDescription)
        }
    }
}

enum TMDBEndpoint {
    static func genreList() -> Endpoint {
        Endpoint(
            path: "genre/movie/list",
            queryItems: [URLQueryItem(name: "language", value: "en-US")]
        )
    }

    static func discoverMovies(
        genreID: Int? = nil,
        page: Int = 1,
        sortedBy: String = "popularity.desc"
    ) -> Endpoint {
        var items = [
            URLQueryItem(name: "sort_by", value: sortedBy),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: String(page))
        ]
        if let genreID {
            items.append(URLQueryItem(name: "with_genres", value: String(genreID)))
        }
        return Endpoint(path: "discover/movie", queryItems: items)
    }

    static func movieDetail(id: Int) -> Endpoint {
        Endpoint(
            path: "movie/\(id)",
            queryItems: [URLQueryItem(name: "language", value: "en-US")]
        )
    }

    static func movieReviews(id: Int, page: Int) -> Endpoint {
        Endpoint(
            path: "movie/\(id)/reviews",
            queryItems: [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: String(page))
            ]
        )
    }

    static func movieVideos(id: Int) -> Endpoint {
        Endpoint(
            path: "movie/\(id)/videos",
            queryItems: [URLQueryItem(name: "language", value: "en-US")]
        )
    }

    static func movieCredits(id: Int) -> Endpoint {
        Endpoint(path: "movie/\(id)/credits")
    }
}
