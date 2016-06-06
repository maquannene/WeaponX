//
//  FlowCardViewController.swift
//  Demo
//
//  Created by 马权 on 6/5/16.
//  Copyright © 2016 马权. All rights reserved.
//

import UIKit

class FlowCardViewController: BaseViewController {
    
    let collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: FlowCardLayout())
    let photos: [UIImage] = Helper.allPhotos()
    let titles: [String] = Helper.allTitle()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.frame = view.bounds
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.dataSource = self
        collectionView.registerClass(FlowCard.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
        view.sendSubviewToBack(collectionView)
        
        if let layout = collectionView.collectionViewLayout as? FlowCardLayout {
            layout.cardSize = CGSize(width: self.view.frame.width, height: 250)
            layout.topStackSpace = 50
            layout.stackCount = 3
            layout.needStackAll = false
        }
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FlowCardViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! FlowCard
        cell.photo = photos[indexPath.item]
        cell.text = titles[indexPath.item]
        return cell
    }
}