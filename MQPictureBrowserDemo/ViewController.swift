//
//  ViewController.swift
//  MQPictureBrowser
//
//  Created by 马权 on 10/7/15.
//  Copyright © 2015 马权. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    weak var pictureBrowserVc: MQPictureBrowserController?
    
    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configurePictureBrowserVc() -> MQPictureBrowserController {
        let vc = MQPictureBrowserController(animationModel: MQPictureBorwserAnimationModel.PictureMoveAndBackgroundFadeOut)
        vc.dataSource = self
        vc.collectionView.registerClass(MQPictureBrowserCell.self, forCellWithReuseIdentifier: "cell")
        return vc
    }
 
    @IBAction func showImage1(sender: AnyObject) {
        let vc = configurePictureBrowserVc()
        vc.presentFromViewController(self)
        pictureBrowserVc = vc
    }
    
    @IBAction func showImage2(sender: AnyObject) {
        let vc = configurePictureBrowserVc()
        vc.presentFromViewController(self, atIndexPicture: 1)
        pictureBrowserVc = vc
    }
}

extension ViewController: MQPictureBrowserControllerDataSource {
    
    func pictureBrowserController(controller: MQPictureBrowserController, animationInfoOfShowPictureAtIndex index: Int) -> ShowAnimationInfo? {
        if index == 0 {
            return (imageView1, self.view)
        }
        return (imageView2, self.view)
    }
    
    func pictureBrowserController(controller: MQPictureBrowserController, animationInfoOfHidePictureAtIndex index: Int) -> HideAnimationInfo? {
        if index == 0 {
            return (imageView1, self.view)
        }
        return (imageView2, self.view)
    }
    
    func numberOfItemsInPictureBrowserController(controller: MQPictureBrowserController) -> Int {
        return 2
    }
    
    func pictureBrowserController(controller: MQPictureBrowserController, cellForItemAtIndex index: Int) -> MQPictureBrowserCell {
        let picturebrowserCell = controller.collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! MQPictureBrowserCell
        picturebrowserCell.configure(UIImage(named: "\(index + 3).png")!)
        return picturebrowserCell
    }
    
}

