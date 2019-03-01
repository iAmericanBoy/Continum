//
//  Post.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

struct PostConstants {
    static let typeKey = "Post"
    static let captionKey = "caption"
    static let timestampKey = "timestamp"
    static let commentsKey = "comments"
    static let commentCountKey = "commentCount"
    static let photoKey = "photo"
}

class Post {
    var photoData: Data?
    let timeStamp: Date
    let caption: String
    var comments: [Comment]
    var commentCount: Int
    let recordID: CKRecord.ID
    
    var imageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirecotryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirecotryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch let error {
                print("Error writing to temp url \(error) \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    var photo: UIImage? {
        get{
            guard let photoData = photoData else {return nil}
            return UIImage(data: photoData)
        }
        set{
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    init(caption: String,photo: UIImage, comments: [Comment] = [], timeStamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.caption = caption
        self.comments = comments
        self.timeStamp = timeStamp
        self.recordID = recordID
        self.commentCount = comments.count
        self.photo = photo
    }
    
    init?(record: CKRecord) {
        guard let caption = record[PostConstants.captionKey] as? String,
            let timestamp = record[PostConstants.timestampKey] as? Date,
            let imageAsset = record[PostConstants.photoKey] as? CKAsset,
            let commentCount = record[PostConstants.commentCountKey] as? Int else {return nil}
        
        self.caption = caption
        self.comments = []
        self.recordID = record.recordID
        self.timeStamp = timestamp
        self.commentCount = commentCount
        
        do {
            try self.photoData = Data(contentsOf: imageAsset.fileURL)
        } catch {
            print("unable to unwrap photoData from the CKAsset. This is the error:  \(error), \(error.localizedDescription)")
        }
    }
}

extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        for comment in comments where comment.matches(searchTerm: searchTerm) {return true}
        return caption.lowercased().contains(searchTerm.lowercased())
    }
}

extension CKRecord {
    convenience init?(post: Post) {
        self.init(recordType: PostConstants.typeKey, recordID: post.recordID)

        self.setValue(post.caption, forKey: PostConstants.captionKey)
        self.setValue(post.timeStamp, forKey: PostConstants.timestampKey)
        self.setValue(post.imageAsset, forKey: PostConstants.photoKey)
        self.setValue(post.commentCount, forKey: PostConstants.commentCountKey)
    }
}
