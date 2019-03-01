//
//  Comment.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CloudKit

struct CommentConstants {
    static let typeKey = "Comment"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postReferenceKey = "postReference"
    static let subscriptionKey = "subscribeToNewComments"
}

class Comment {
    let text: String
    let timeStamp: Date
    let recordID: CKRecord.ID
    weak var post: Post?
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }
    
    init(text: String, post: Post, timeStamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.timeStamp = timeStamp
        self.text = text
        self.post = post
        self.recordID = recordID
    }
    
    convenience init?(ckRecord: CKRecord, post: Post){
        guard let text = ckRecord[CommentConstants.textKey] as? String,
            let timeStamp = ckRecord[CommentConstants.timestampKey] as? Date else { return nil }
        self.init(text: text, post: post, timeStamp: timeStamp, recordID: ckRecord.recordID)
    }
}

extension Comment: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        return text.lowercased().contains(searchTerm.lowercased())
    }
}

extension CKRecord {
    convenience init?(comment: Comment) {
        self.init(recordType: CommentConstants.typeKey, recordID: comment.recordID)
        
        self.setValue(comment.text, forKey: CommentConstants.textKey)
        self.setValue(comment.timeStamp, forKey: CommentConstants.timestampKey)
        self.setValue(comment.postReference, forKey: CommentConstants.postReferenceKey)
    }
}
