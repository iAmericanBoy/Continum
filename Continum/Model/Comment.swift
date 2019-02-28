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
}

class Comment {
    let text: String
    let timeStamp: Date
    let recordID: CKRecord.ID
    weak var post: Post?
    
    init(text: String, post: Post, timeStamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.timeStamp = timeStamp
        self.text = text
        self.post = post
        self.recordID = recordID
    }
    
    init?(record: CKRecord) {
        guard let text = record[CommentConstants.textKey] as? String,
            let timeStamp = record[CommentConstants.timestampKey] as? Date else {return nil}
        self.text = text
        self.timeStamp = timeStamp
        self.recordID = record.recordID
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
    }
}
