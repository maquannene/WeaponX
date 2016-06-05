//
//  StackCardViewcontroller.swift
//  Demo
//
//  Created by 马权 on 6/2/16.
//  Copyright © 2016 马权. All rights reserved.
//

import UIKit

class StackCardViewcontroller: UIViewController {

    let collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: StackCardLayout())
    let photos: [UIImage] = Helper.allPhotos()
    let titles: [String] = Helper.allTitle()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.frame = self.view.bounds
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.dataSource = self
        collectionView.registerClass(CardView.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
        view.sendSubviewToBack(collectionView)
        
        if let layout = collectionView.collectionViewLayout as? StackCardLayout {
            layout.cardSize = CGSize(width: self.view.frame.width, height: 250)
            layout.topStackSpace = 50
            layout.bottomStackSpace = 50
            layout.stackCount = 5
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CardView
        cell.photo = photos[indexPath.item]
        cell.text = titles[indexPath.item]
        return cell
    }
}