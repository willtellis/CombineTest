//
//  ViewControllerViewModel.swift
//  CombineTest
//
//  Created by Will Ellis on 10/27/20.
//

import Foundation

struct ViewControllerViewModel {
    let posts: [Post]

    struct Post {
        let title: String?
    }
}
