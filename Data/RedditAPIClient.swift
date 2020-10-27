//
//  RedditAPIClient.swift
//  CombineTest
//
//  Created by Will Ellis on 10/27/20.
//

import Foundation

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

    func getPosts(after: String?, completion: @escaping (Result<PostsAPIResponse, Error>) -> Void) {
        var components = baseURLComponents
        components.path = "/.json"
        let queryItem = URLQueryItem(name: "after", value: after)
        components.queryItems = [queryItem]
        guard let url = components.url else {
            completion(.failure(APIError.badURL))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            let decoder = JSONDecoder()
            do {
                let postsResponse = try decoder.decode(PostsAPIResponse.self, from: data)
                completion(.success(postsResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
