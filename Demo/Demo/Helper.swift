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
            let photoName = String(format: "Inspiration-%02d", i)
            if let photo = UIImage(named: photoName)
            {
                photos.append(photo)
            }
        }
        return photos
    }
    
    class func allTitle() -> [String] {
        var titles = [String]()
        if let URL = NSBundle.mainBundle().URLForResource("Inspirations", withExtension: "plist") {
            if let tutorialsFromPlist = NSArray(contentsOfURL: URL) {
                for dictionary in tutorialsFromPlist {
                    titles.append(dictionary["Title"] as! String)
                }
            }
        }
        return titles
    }
    
    class func allController() -> [UIViewController.Type] {
        var controllers = [UIViewController.Type]()
        controllers.append(FlowCardViewController.self)
        controllers.append(StackCardViewcontroller.self)
        return controllers
    }
    
    class func allLayout() -> [AnyClass] {
        var layouts = [AnyClass]()
        layouts.append(FlowCardLayout)
        layouts.append(StackCardLayout)
        return layouts
    }
}
