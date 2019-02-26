//
//  PostController.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class PostController {
    //MARK: -Singleton
    static let shared = PostController()
    
    //MARK: - SourceOfTruth
    var posts: [Post] = []
    
    //MARK: -CRUD
    func createPostWith(image: UIImage, caption: String, completion:@escaping(Post?) -> Void) {
        let newPost = Post(caption: caption, photo: image)
        posts.append(newPost)
        completion(newPost)
    }
    
    func addCommentTo(post: Post, withText text: String, completion: @escaping(Comment) -> Void) {
        let newComment = Comment(text: text, post: post)
        post.comments.append(newComment)
    }
}
