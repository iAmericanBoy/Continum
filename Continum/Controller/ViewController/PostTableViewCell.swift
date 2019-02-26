//
//  PostTableViewCell.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
   
    //MARK: - Outlets
    @IBOutlet weak var poatImageView: UIImageView!
    @IBOutlet weak var postCaptionLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!

    //MARK: - Properties
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Private Functions
    func updateViews() {
        guard let post = post else {return}
        self.poatImageView.image = post.photo
        self.postCaptionLabel.text = post.caption
        self.commentsLabel.text = "Comments: \(post.comments.count)"
    }
}
