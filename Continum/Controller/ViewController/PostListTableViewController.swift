//
//  PostListTableViewController.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    //MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Properties
    var isSearching = false
    
    var resultsArray: [Post] = []
    var dataSource: [Post] {
        return isSearching ? resultsArray : PostController.shared.posts
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        requestFullSync { (isSuccess) in
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsArray = PostController.shared.posts
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell
        
        cell?.post = dataSource[indexPath.row]

        return cell ?? UITableViewCell()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //IIDOO
        if segue.identifier == "toDetailVC" {
            guard let index = tableView.indexPathForSelectedRow else {return}
            if let destinationVC = segue.destination as? PostDetailTableViewController {
                destinationVC.post = PostController.shared.posts[index.row]
            }
        }
    }
    //MARK: - Private Functions
    func requestFullSync(completion: @escaping (Bool) -> Void) {
        PostController.shared.fetchPosts { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

//MARK: - SearchBarDelegate
extension PostListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resultsArray = PostController.shared.posts.filter{ $0.matches(searchTerm: searchText) }
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsArray = PostController.shared.posts
        tableView.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resultsArray = PostController.shared.posts.filter{ $0.matches(searchTerm: searchBar.text ?? "") }
        tableView.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
