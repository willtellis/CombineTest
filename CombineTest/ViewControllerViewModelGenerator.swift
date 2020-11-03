//
//  ViewControllerViewModelGenerator.swift
//  CombineTest
//
//  Created by Will Ellis on 10/27/20.
//

import Foundation
import UIKit

struct ViewControllerViewModelGenerator {

    private var viewModel: ViewControllerViewModel?

    mutating func make(appending model: PostsAPIResponse) -> (ViewControllerViewModel, [IndexPath]) {
        let previousPosts = viewModel?.posts ?? []
        let posts = model.data?.children?.compactMap({ makePost(with: $0) }) ?? []
        let viewModel = ViewControllerViewModel(posts: previousPosts + posts)
        self.viewModel = viewModel
        let indexPathsToReload = (previousPosts.count..<viewModel.posts.count).map({ IndexPath(row: $0, section: 0) })
        return (viewModel, indexPathsToReload)
    }

    func make(with error: Error) -> (ViewControllerViewModel, [IndexPath]) {
        return (ViewControllerViewModel(posts: []), [])
    }

    private func makePost(with model: PostsAPIResponse.Data.Child) -> ViewControllerViewModel.Post? {
        return ViewControllerViewModel.Post(title: model.data?.title)
    }
}
