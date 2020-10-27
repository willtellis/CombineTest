//
//  PostsAPIResponse.swift
//  CombineTest
//
//  Created by Will Ellis on 10/27/20.
//

import Foundation

struct PostsAPIResponse: Decodable {
    let data: Data?
    let after: String?

    struct Data: Decodable {
        let children: [Child]?

        struct Child: Decodable {
            let data: Data?

            struct Data: Decodable {
                let title: String?
            }
        }
    }
}

