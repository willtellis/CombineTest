//
//  ViewController.swift
//  CombineTest
//
//  Created by Will Ellis on 10/27/20.
//

import UIKit
import Combine

class ViewController: UITableViewController, UITableViewDataSourcePrefetching {

    var apiClient = RedditAPIClient()

    typealias ViewModel = ViewControllerViewModel
    private var viewModelGenerator = ViewControllerViewModelGenerator()
    private var viewModel: ViewModel? = nil

    // Token for paging from the RedditAPIClient
    private var after: String? = nil

    private var cancellables = Set<AnyCancellable>()

    private let afterSubject = PassthroughSubject<String?, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self

        let postsPublisher = afterSubject
            .removeDuplicates()
            .flatMap { after in self.apiClient.getPostsPublisher(after: after) }
            .multicast { PassthroughSubject<PostsAPIResponse, Error>() }

        postsPublisher
            .map { $0.data?.after }
            .catch { _ in Just(nil) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.after, on: self)
            .store(in: &cancellables)

        postsPublisher
            .receive(on: DispatchQueue.main)
            .map { self.viewModelGenerator.make(appending: $0) }
            .catch { Just(self.viewModelGenerator.make(with: $0)) }
            .sink { (viewModel, indexPaths) in
                self.render(viewModel, indexPathsToReload: indexPaths)
            }
            .store(in: &cancellables)

        postsPublisher
            .connect()
            .store(in: &self.cancellables)
    }

    private func render(_ viewModel: ViewModel, indexPathsToReload: [IndexPath]?) {
        self.viewModel = viewModel
        guard isViewLoaded else {
            return
        }
        guard let indexPathsToReload = indexPathsToReload else {
            tableView.reloadData()
            return
        }
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: How do I actually grow this size if I'm prefetching???
//        let loadedPostCount = viewModel?.posts.count ?? 0
//        let loadingPostCount = 25
//        return loadedPostCount + loadingPostCount
        return 1000
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        if isLoadingCell(for: indexPath) {
            cell.textLabel?.text = "LOADING"
        } else {
            cell.textLabel?.text = viewModel?.posts[indexPath.row].title
        }
        return cell
    }

    // MARK: - UITableViewDataSourcePrefetching

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { isLoadingCell(for: $0) }) {
            print("HERE")
            afterSubject.send(after)
        }
    }

    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        guard let count = viewModel?.posts.count else {
            return true
        }
        return indexPath.row >= count
    }

    private func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
      let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
      let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
      return Array(indexPathsIntersection)
    }
}
