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
                return
            }
            guard let record = record, let newPostFormCK = Post(record: record) else {completion(nil); return}

            self.posts.append(newPostFormCK)
            completion(newPostFormCK)
        }
    }
    
    func addCommentTo(post: Post, withText text: String, completion: @escaping(Comment?) -> Void) {
        
        let newComment = Comment(text: text, post: post)
        guard let commentRecord = CKRecord(comment: newComment) else {completion(nil); return}
        
        post.commentCount += 1
        guard let postRecord = CKRecord(post: post) else {completion(nil); return}
        
        let operation = CKModifyRecordsOperation(recordsToSave: [postRecord,commentRecord], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        
        operation.modifyRecordsCompletionBlock = { (savedRecords,_,error) in
            if let error = error {
                print("An error saving comment record has occurd: \(error), \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let savedRecords = savedRecords else {completion(nil); return}
            
            if let postFromCK = Post(record: savedRecords[0]) {
                guard let newCommentFormCK = Comment(ckRecord: savedRecords[1], post: postFromCK) else {completion(nil); return}
                post.comments.append(newCommentFormCK)
                completion(newCommentFormCK)
            } else if let postFromCK = Post(record: savedRecords[1]) {
                guard let newCommentFormCK = Comment(ckRecord: savedRecords[0], post: postFromCK) else {completion(nil); return}
                post.comments.append(newCommentFormCK)
                completion(newCommentFormCK)
            }
        }
        
        publicDB.add(operation)
    }
    
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PostConstants.typeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("An error fetching posts has occurd: \(error), \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let records = records else {completion([]); return}
            let posts = records.compactMap({ Post(record: $0) })

            self.posts = posts
            completion(posts)
        }
    }
    
    func fetchComments(fromPost post: Post, completion: @escaping ([Comment]) -> Void) {
        
        let postRefence = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, postRefence)
        let commentIDs = post.comments.compactMap({$0.recordID})
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        let query = CKQuery(recordType: CommentConstants.typeKey, predicate: compoundPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("An error fetching Comments for Post with \(post.caption) has occurd: \(error), \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let records = records else {completion([]); return}
            let comments = records.compactMap({ Comment(ckRecord: $0, post: post) })
            
            post.comments += comments
            completion(comments)
        }
    }
}
