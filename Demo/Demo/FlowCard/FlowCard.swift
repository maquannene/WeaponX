//
//  FlowCard.swift
//  Demo
//
//  Created by 马权 on 6/5/16.
//  Copyright © 2016 马权. All rights reserved.
//

import UIKit

class FlowCard: UICollectionViewCell {

    private var _imageView: UIImageView
    private var _label: UILabel
    
    override init(frame: CGRect) {
        _imageView = UIImageView()
        _label = UILabel()
        super.init(frame: frame)
        baseConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        _imageView = UIImageView()
        _label = UILabel()
        super.init(coder: aDecoder)
        baseConfig()
    }
    
    func baseConfig() {
        clipsToBounds = true
        _imageView.frame = self.bounds
        _imageView.contentMode = .Center
        _imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(_imageView)
        
        _label.frame = bounds
        _label.textColor = UIColor.whiteColor()
        _label.font = UIFont.systemFontOfSize(26)
        _label.textAlignment = .Center
        _label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(_label)
    }
    
    var photo: UIImage? {
        didSet {
            if let photo = photo {
                _imageView.image = photo
            }
        }
    }
    
    var text: NSString? {
        didSet {
            if let text = text {
                _label.text = text as String
            }
        }
    }
}
