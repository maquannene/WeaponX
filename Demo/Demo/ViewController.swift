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
        let vc = PhotoBrowserController(animationModel: PictureBorwserAnimationModel.MoveAndBackgroundFadeOut)
        vc.dataSource = self
        vc.collectionView.registerClass(PhotoBrowserCell.self, forCellWithReuseIdentifier: "cell")
        return vc
    }
 
    @IBAction func showImage1(sender: AnyObject) {
        let vc = configurePhotoBrowserVc()
        vc.presentFromViewController(self)
        photoBrowserVc = vc
    }
    
    @IBAction func showImage2(sender: AnyObject) {
        let vc = configurePhotoBrowserVc()
        vc.presentFromViewController(self, atIndexPicture: 1)
        photoBrowserVc = vc
    }
}

extension ViewController: PhotoBrowserControllerDataSource {
    
    func photoBrowserController(controller: PhotoBrowserController, animationInfoOfShowPictureAtIndex index: Int) -> ShowAnimationInfo? {
        if index == 0 {
            return (imageView1, self.view)
        }
        return (imageView2, self.view)
    }
    
    func photoBrowserController(controller: PhotoBrowserController, animationInfoOfHidePictureAtIndex index: Int) -> HideAnimationInfo? {
        if index == 0 {
            return (imageView1, self.view)
        }
        return (imageView2, self.view)
    }
    
    func numberOfItemsInPhotoBrowserController(controller: PhotoBrowserController) -> Int {
        return 2
    }
    
    func photoBrowserController(controller: PhotoBrowserController, pictureCellForItemAtIndex index: Int) -> PhotoBrowserCell {
        let picturebrowserCell = controller.collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! PhotoBrowserCell
        picturebrowserCell.configure(UIImage(named: "\(index + 3).png")!)
        return picturebrowserCell
    }
    
}

