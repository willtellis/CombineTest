//
//  ViewController.swift
//  CombineTest
//
//  Created by Will Ellis on 10/27/20.
//

import UIKit

class ViewController: UITableViewController {

    var apiClient = RedditAPIClient()

    typealias ViewModel = ViewControllerViewModel
    private var viewModelGenerator = ViewControllerViewModelGenerator()
    private var viewModel: ViewModel? = nil
    private var after: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        apiClient.getPosts(after: nil) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                guard
                    let posts = try? result.get(),
                    let viewModel = self.viewModelGenerator.make(with: posts)
                else {
                    // TODO: error screen
                    return
                }
                self.after = posts.after
                self.render(viewModel)
            }
        }

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
