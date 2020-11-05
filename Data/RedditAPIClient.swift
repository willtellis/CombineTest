//
//  RedditAPIClient.swift
//  CombineTest
//
//  Created by Will Ellis on 10/27/20.
//

import Foundation
import Combine

enum APIError: Error {
    case badURL
    case noData
}

struct RedditAPIClient {

    private var baseURLComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.reddit.com"
        return components
    }

    func getPostsPublisher(after: String?) -> AnyPublisher<PostsAPIResponse, Error> {
        var components = baseURLComponents
        components.path = "/.json"
        let queryItem = URLQueryItem(name: "after", value: after)
        components.queryItems = [queryItem]

        guard let url = components.url else {
            return Fail<PostsAPIResponse, Error>(error: APIError.badURL)
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { $0 as Error }
            .map { $0.data }
            .decode(type: PostsAPIResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
