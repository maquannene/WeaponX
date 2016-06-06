//
//  StackCardViewcontroller.swift
//  Demo
//
//  Created by 马权 on 6/2/16.
//  Copyright © 2016 马权. All rights reserved.
//

import UIKit

class StackCardViewcontroller: BaseViewController {

    let collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: StackCardLayout())
    let photos: [UIImage] = Helper.allPhotos()
    let titles: [String] = Helper.allTitle()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.frame = view.bounds
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView.dataSource = self
        collectionView.registerClass(StackCard.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
        view.sendSubviewToBack(collectionView)
        
        if let layout = collectionView.collectionViewLayout as? StackCardLayout {
            layout.cardSize = CGSize(width: self.view.frame.width, height: 250)
            layout.topStackSpace = 50
            layout.bottomStackSpace = 50
            layout.stackCount = 3
            layout.needStackAll = true
        }
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension StackCardViewcontroller: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! StackCard
        cell.photo = photos[indexPath.item]
        return cell
    }
}