//
//  Album.swift
//  RWDevCon
//
//  Created by Mic Pringle on 09/03/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class Photos {
    
    var title: String
    var photos: [UIImage]
    
    init(title: String, photos: [UIImage]) {
        self.title = title
        self.photos = photos
    }
    
    class func allPhotos() -> [UIImage] {
        
        var photos = [UIImage]()
        for i in 1...10 {
            let photoName = String(format: "Tutorial-%02d", i)
            if let photo = UIImage(named: photoName) {
                photos.append(photo)
            }
        }
        return photos
    }
    
}
