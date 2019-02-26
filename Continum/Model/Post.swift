//
//  Post.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import UIKit

class Post {
    var photoData: Data?
    let timeStamp: Date
    let caption: String
    var comments: [Comment]
    
    var photo: UIImage? {
        get{
            guard let photoData = photoData else {return nil}
            return UIImage(data: photoData)
        }
        set{
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    init(caption: String,photo: UIImage, comments: [Comment] = [], timeStamp: Date = Date()) {
        self.caption = caption
        self.comments = comments
        self.timeStamp = timeStamp
        self.photo = photo
    }
}
