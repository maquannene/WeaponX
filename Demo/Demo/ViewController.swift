//
//  ViewController.swift
//  PhotoBrowser
//
//  Created by 马权 on 10/7/15.
//  Copyright © 2015 马权. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    weak var photoBrowserVc: PhotoBrowserController?
    
    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configurePhotoBrowserVc() -> PhotoBrowserController {
        let vc = PhotoBrowserController()
        vc.dataSource = self
        vc.delegate = self
        vc.registerClass(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        return vc
    }
 
    @IBAction func showImage1(sender: AnyObject) {
        let vc = configurePhotoBrowserVc()
        vc.presentFromViewController(self)
        photoBrowserVc = vc
    }
    
    @IBAction func showImage2(sender: AnyObject) {
        let vc = configurePhotoBrowserVc()
        vc.presentFromViewController(self, atIndexPhoto: 1)
        photoBrowserVc = vc
    }
}

extension ViewController: PhotoBrowserControllerDelegate {
    func photoBrowserController(controller: PhotoBrowserController, willDisplayCell photoCell: PhotoCell, forItemAtIndex index: Int) {
    
    }
    func photoBrowserController(controller: PhotoBrowserController, didEndDisplayingCell photoCell: PhotoCell, forItemAtIndex index: Int) {
    
    }
    func photoBrowserController(controller: PhotoBrowserController, tapCell photoCell: PhotoCell, forItemAtIndex index: Int) {
        controller.dismiss()
    }
}

extension ViewController: PhotoBrowserControllerDataSource {
    
    func photoBrowserController(controller: PhotoBrowserController, animationInfoOfShowPhotoAtIndex index: Int) -> ShowAnimationInfo? {
        if index == 0 {
            return (imageView1, self.view)
        }
        return (imageView2, self.view)
    }
    
    func photoBrowserController(controller: PhotoBrowserController, animationInfoOfHidePhotoAtIndex index: Int) -> HideAnimationInfo? {
        if index == 0 {
            return (imageView1, self.view)
        }
        return (imageView2, self.view)
    }
    
    func numberOfItemsInPhotoBrowserController(controller: PhotoBrowserController) -> Int {
        return 6
    }
    
    func photoBrowserController(controller: PhotoBrowserController, photoCellForItemAtIndex index: Int) -> PhotoCell {
        let photobrowserCell = controller.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: NSIndexPath(forItem: index, inSection: 0))
        photobrowserCell.configure(UIImage(named: "\(index + 3).png")!)
        return photobrowserCell
    }
    
}

