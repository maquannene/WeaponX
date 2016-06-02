//
//  W1Viewcontroller.swift
//  Demo
//
//  Created by 马权 on 6/2/16.
//  Copyright © 2016 马权. All rights reserved.
//

import UIKit

class W1Viewcontroller: UIViewController {

    let collectionView: UICollectionView = UICollectionView()
    let layout: StackCardLayout = StackCardLayout()
    let photos: [UIImage] = Photos.allPhotos()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension W1Viewcontroller: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = photos[indexPath.item]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCell
        return cell
    }
}