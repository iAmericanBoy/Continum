//
//  PostController.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

class PostController {
    //MARK: -Singleton
    static let shared = PostController()
    
    //MARK: - SourceOfTruth
    var posts: [Post] = []
    
    //MARK: - Properties
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: - init
    init() {
        subscribeToNewPosts { (_, _) in
        }
    }
    
    //MARK: - CRUD
    //C
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
    //U
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
    //R
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
    
    //R
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
    
    //MARK: - Subscribtions
    func subscribeToNewPosts(completion: @escaping (Bool,Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        let subsciption = CKQuerySubscription(recordType: PostConstants.typeKey, predicate: predicate, subscriptionID: PostConstants.subscriptionKey, options: .firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Hey"
        notificationInfo.alertBody = "There was a new Post posted to Continum"
        
        subsciption.notificationInfo = notificationInfo
        
        publicDB.save(subsciption) { (subscription, error) in
            if let error = error {
                print("There was an error saving the post subscription: \(error.localizedDescription)")
                completion(false,error)
                return
            }
            completion(true,error)
        }
    }
    
    func toggleSubscriptionTo(commentsForPost post: Post, completion: @escaping (Bool,Error?) -> Void) {
        checkForCommentSubscribtion(forPost: post) { (subscribtionExists, error) in
            switch subscribtionExists {
            case true:
                completion(true,error)
            case false:
                self.subscribeToNewPosts(completion: { (subscribtionWasSet, error) in
                    completion(subscribtionWasSet,error)
                })
            }
        }
    }
    
    func subscribeToComments(forPost post: Post, completion: @escaping (Bool,Error?) -> Void) {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [CommentConstants.postReferenceKey,post.recordID])
        let subsciption = CKQuerySubscription(recordType: post.recordID.recordName, predicate: predicate, subscriptionID: CommentConstants.subscriptionKey, options: .firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Hey"
        notificationInfo.alertBody = "There was a new Comment posted."
        
        subsciption.notificationInfo = notificationInfo
        
        publicDB.save(subsciption) { (subscription, error) in
            if let error = error {
                print("There was an error saving the comment subscription: \(error.localizedDescription)")
                completion(false,error)
                return
            }
            completion(true,error)
        }
    }
    
    func removeCommentSubscribtion(forPost post: Post, completion: @escaping (Bool,Error?) -> Void) {
        publicDB.delete(withSubscriptionID: post.recordID.recordName) { (_, error) in
            if let error = error {
                print("There was an error deleting the comment subscription: \(error.localizedDescription)")
                completion(false,error)
                return
            }
            completion(true,error)
        }
    }
    
    func checkForCommentSubscribtion(forPost post: Post, completion: @escaping (Bool,Error?) -> Void) {
        publicDB.fetch(withSubscriptionID: post.recordID.recordName) { (subscribtion, error) in
            if let error = error {
                print("There was an error checking for the comment subscription: \(error.localizedDescription)")
                completion(false,error)
                return
            }
            completion(true,error)
        }
    }
}
