//
//  Helper.swift
//  Demo
//
//  Created by 马权 on 6/2/16.
//  Copyright © 2016 马权. All rights reserved.
//

import UIKit

class Helper {
    
    class func allPhotos() -> [UIImage] {
        
        var photos = [UIImage]()
        for i in 1...10 {
            let photoName = String(format: "Tutorial-%02d", i)
            if let photo = UIImage(named: photoName)
            {
                photos.append(photo)
            }
        }
        return photos
    }
    
    class func allLayout() -> [AnyClass] {
        var layouts = [AnyClass]()
        layouts.append(StackCardLayout)
        return layouts
    }
    
}
