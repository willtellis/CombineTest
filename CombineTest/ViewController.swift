//
//  ViewController.swift
//  CombineTest
//
//  Created by Will Ellis on 10/27/20.
//

import UIKit

class ViewController: UITableViewController {

    struct ViewModel {
        let posts: [Post]

        struct Post {
            let title: String?
        }
    }

    var apiClient = RedditAPIClient()

    private var viewModel: ViewModel? = nil
    private var after: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        apiClient.getPosts(after: nil) { result in
            DispatchQueue.main.async { [weak self] in
                guard
                    let posts = try? result.get(),
                    let viewModel = ViewModel(model: posts)
                else {
                    // TODO: error screen
                    return
                }
                self?.after = posts.after
                self?.configure(with: viewModel)
            }
        }

    }

    private func configure(with viewModel: ViewModel) {
        self.viewModel = viewModel
        guard isViewLoaded else {
            return
        }
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.posts.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = viewModel?.posts[indexPath.row].title
        return cell
    }
}

extension ViewController.ViewModel {
    init?(model: PostsAPIResponse?) {
        guard let model = model else {
            return nil
        }
        let posts = model.data?.children?.compactMap({ Post(model: $0) }) ?? []
        self.init(posts: posts)
    }
}

extension ViewController.ViewModel.Post {
    init?(model: PostsAPIResponse.Data.Child?) {
        self.init(title: model?.data?.title)
    }
}
