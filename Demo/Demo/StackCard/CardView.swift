//
//  CardView.swift
//  Demo
//
//  Created by 马权 on 6/2/16.
//  Copyright © 2016 马权. All rights reserved.
//

import UIKit

class CardView: UICollectionViewCell {

    private var _imageView: UIImageView

    override init(frame: CGRect) {
        _imageView = UIImageView()
        super.init(frame: frame)
        layer.cornerRadius = 20
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 2
        clipsToBounds = true
        _imageView.frame = self.bounds
        _imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(_imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        _imageView = UIImageView()
        super.init(coder: aDecoder)
        layer.cornerRadius = 20
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 2
        clipsToBounds = true
        _imageView.frame = self.bounds
        _imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(_imageView)
    }
    
    var photo: UIImage? {
        didSet {
            if let photo = photo {
                _imageView.image = photo
            }
        }
    }
}
