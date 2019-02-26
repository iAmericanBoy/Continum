//
//  Comment.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation

class Comment {
    let text: String
    let timeStamp: Date
    weak var post: Post?
    
    init(text: String, post: Post, timeStamp: Date = Date()) {
        self.timeStamp = timeStamp
        self.text = text
        self.post = post
    }
}
