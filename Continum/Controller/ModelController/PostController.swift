//
//  PostController.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    //MARK: -Singleton
    static let shared = PostController()
    
    //MARK: - SourceOfTruth
    var posts: [Post] = []
    
    //MARK: - Properties
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: -CRUD
    func createPostWith(image: UIImage, caption: String, completion:@escaping(Post?) -> Void) {
        let newPost = Post(caption: caption, photo: image)
        guard let record = CKRecord(post: newPost) else {completion(nil); return}
        
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("An error saving post record has occurd: \(error), \(error.localizedDescription)")
                completion(nil)
            }
            guard let record = record, let newPostFormCK = Post(record: record) else {completion(nil); return}

            self.posts.append(newPostFormCK)
            completion(newPostFormCK)
        }
    }
    
    func addCommentTo(post: Post, withText text: String, completion: @escaping(Comment?) -> Void) {
        let newComment = Comment(text: text, post: post)
        guard let record = CKRecord(comment: newComment) else {completion(nil); return}
        
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("An error saving comment record has occurd: \(error), \(error.localizedDescription)")
                completion(nil)
            }
            guard let record = record, let newCommentFormCK = Comment(ckRecord: record, post: post) else {completion(nil); return}
            post.comments.append(newCommentFormCK)
            completion(newCommentFormCK)
        }

    }
}
