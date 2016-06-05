//
//  CardView.swift
//  Demo
//
//  Created by 马权 on 6/2/16.
//  Copyright © 2016 马权. All rights reserved.
//

import UIKit

class StackCard: UICollectionViewCell {

    private var _imageView: UIImageView
    
    override init(frame: CGRect) {
        _imageView = UIImageView()
        super.init(frame: frame)
        baseConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        _imageView = UIImageView()
        super.init(coder: aDecoder)
        baseConfig()
    }
    
    func baseConfig() {
        layer.borderWidth = 2
        layer.cornerRadius = 20
        layer.borderColor = UIColor.whiteColor().CGColor
        
        clipsToBounds = true
        _imageView.frame = self.bounds
        _imageView.contentMode = .Top
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
