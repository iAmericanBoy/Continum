//
//  PostDetailTableViewController.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import NotificationCenter

class PostDetailTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    //MARK: - Properties
    var post: Post? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        getNewCommentAlert()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        sharePost()
    }
    
    @IBAction func followPosttapped(_ sender: UIButton) {
        followPost()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        cell.textLabel?.text = post?.comments[indexPath.row].text
        cell.detailTextLabel?.text = post?.comments[indexPath.row].timeStamp.description(with: Locale.current)
        
        return cell
    }
    
    //MARK: - Private Functions
    func updateViews() {
        guard let post = post else {return}
        PostController.shared.fetchComments(fromPost: post) { (_) in
            PostController.shared.checkForCommentSubscribtion(forPost: post, completion: { (subscribed, _) in
                DispatchQueue.main.async {
                    
                    switch subscribed {
                    case true:
                        self.followButton.setTitle("Unfollow Post", for: .normal)
                    case false:
                        self.followButton.setTitle("Follow Post", for: .normal)
                    }
                    
                    self.tableView.reloadData()
                    self.postImageView.image = post.photo
                    self.captionLabel.text = post.caption
                }
            })
        }
    }
    
    func getNewCommentAlert() {
        var commentTextField: UITextField?
        
        let commentAlert = UIAlertController(title: "New Comment", message: "Enter a new Comment", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Post Coment", style: .default) { [weak self] action in
            guard let post = self?.post else {return}
            if let comment = commentTextField?.text {
                PostController.shared.addCommentTo(post: post, withText: comment, completion: { comment in
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                })
            }
        }
        commentAlert.addTextField { textField in
            textField.placeholder = "Add Comment..."
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let name = textField.text, !name.isEmpty {
                    confirmAction.isEnabled = true
                    commentTextField = textField
                } else {
                    confirmAction.isEnabled = false
                }
            }
        }
        
        commentAlert.addAction(cancelAction)
        commentAlert.addAction(confirmAction)
        self.present(commentAlert, animated: true, completion: nil)
    }
    
    func sharePost() {
        guard let caption = post?.caption, let photo = post?.photo else {return}
        let shareSheet = UIActivityViewController(activityItems: [caption,photo], applicationActivities: nil)
        self.present(shareSheet,animated: true)
    }
    
    func followPost() {
        guard  let post = post else {return}
        PostController.shared.toggleSubscriptionTo(commentsForPost: post) { (subscribtionIsSet, _) in
            DispatchQueue.main.async {
                switch subscribtionIsSet {
                case false:
                    self.followButton.setTitle("Unfollow Post", for: .normal)
                case true:
                    self.followButton.setTitle("Follow Post", for: .normal)
                }
            }
        }
    }
}
