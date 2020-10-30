//
//  ViewController.swift
//  CombineTest
//
//  Created by Will Ellis on 10/27/20.
//

import UIKit
import Combine

class ViewController: UITableViewController {

    var apiClient = RedditAPIClient()

    typealias ViewModel = ViewControllerViewModel
    private var viewModelGenerator = ViewControllerViewModelGenerator()
    private var viewModel: ViewModel? = nil

    // Token for paging from the RedditAPIClient
    private var after: String? = nil

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let postsPublisher = apiClient.getPostsPublisher(after: nil)
            .multicast { PassthroughSubject<PostsAPIResponse, Error>() }

        postsPublisher
            .map { $0.after }
            .catch { _  in Just(nil) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.after, on: self)
            .store(in: &cancellables)

        postsPublisher
            .receive(on: DispatchQueue.main)
            .map { self.viewModelGenerator.make(with: $0) }
            .catch { Just(self.viewModelGenerator.make(with: $0)) }
            .sink { self.render($0) }
            .store(in: &cancellables)

        postsPublisher
            .connect()
            .store(in: &self.cancellables)
    }

    private func render(_ viewModel: ViewModel) {
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
