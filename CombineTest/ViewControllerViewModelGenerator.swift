//
//  ViewControllerViewModelGenerator.swift
//  CombineTest
//
//  Created by Will Ellis on 10/27/20.
//

import Foundation

struct ViewControllerViewModelGenerator {

    func make(with model: PostsAPIResponse) -> ViewControllerViewModel {
        let posts = model.data?.children?.compactMap({ makePost(with: $0) }) ?? []
        return ViewControllerViewModel(posts: posts)
    }

    func make(with error: Error) -> ViewControllerViewModel {
        return ViewControllerViewModel(posts: [])
    }

    private func makePost(with model: PostsAPIResponse.Data.Child) -> ViewControllerViewModel.Post? {
        return ViewControllerViewModel.Post(title: model.data?.title)
    }
}
