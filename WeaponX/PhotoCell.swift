//
//  PhotoCell.swift
//  PhotoBrowser
//
//  Created by 马权 on 10/7/15.
//  Copyright © 2015 马权. All rights reserved.
//

import UIKit
import AVFoundation

protocol PhotoCellDelegate: class {
    func photoCellTap(photoCell: PhotoCell)
}

enum PhotoCellType {
    case WidthStyle
    case HeightStyle
}

public class PhotoCell: UICollectionViewCell {
    
    internal weak var delegate: PhotoCellDelegate?
    internal var imageSize: CGSize = CGSizeZero
    private var scrollView = UIScrollView()
    private var imageView = UIImageView()
    private var doubleTapGesture: UITapGestureRecognizer
    private var tapGesture: UITapGestureRecognizer
    private var type: PhotoCellType = .WidthStyle
    
    public required init?(coder aDecoder: NSCoder) {
        tapGesture = UITapGestureRecognizer()
        doubleTapGesture = UITapGestureRecognizer()
        super.init(coder: aDecoder)
        baseConfigure()
    }
    
    private override init(frame: CGRect) {
        tapGesture = UITapGestureRecognizer()
        doubleTapGesture = UITapGestureRecognizer()
        super.init(frame: frame)
        baseConfigure()
    }
    
    public func baseConfigure() {
        scrollView.frame = bounds
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.directionalLockEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.clipsToBounds = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.addTarget(self, action: #selector(PhotoCell.dobleTapAction(_:)))
        addGestureRecognizer(doubleTapGesture)
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(PhotoCell.tapAction(_:)))
        addGestureRecognizer(tapGesture)
        tapGesture.requireGestureRecognizerToFail(doubleTapGesture)
    }
    
    public override func prepareForReuse() {
        scrollView.setZoomScale(1, animated: false)
    }
    
    @objc private func tapAction(gesture: UITapGestureRecognizer) {
        delegate?.photoCellTap(self)
    }
    
    @objc private func dobleTapAction(gesture: UITapGestureRecognizer) {
        
        guard scrollView.maximumZoomScale != 1 else { return }
        
        guard imageView.image != nil else { return }
        
        let cellSize = self.frame.size
        let maxScale = scrollView.maximumZoomScale   //  沾满全屏的缩放比
        
        //  如果当前缩放比偏小，就放大至最大
        if maxScale - scrollView.zoomScale > (maxScale - 1) / 2 {
            let touchPoint = gesture.locationInView(self)
            let w = cellSize.width / maxScale
            let h = cellSize.height / maxScale
            let x = touchPoint.x - (w / 2.0)
            let y = touchPoint.y - (h / 2.0)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.scrollView.zoomToRect(CGRect(x: x, y: y, width: w, height: h), animated: false)
                }, completion: nil)
        }
        else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.scrollView.setZoomScale(1, animated: false)
                }, completion: nil)
        }
    }
}

//  MARK: Public
public extension PhotoCell {
    
    public func configure(image: UIImage) {
        imageView.image = image
        self.imageSize = image.size
        defaultConfigure()
    }

    public func defaultConfigure() {
        let imageActualSize = calculateImageActualRectInCell(self.imageSize).size
        imageView.frame = CGRect(origin: CGPointZero, size: imageActualSize)
        scrollView.contentSize = imageActualSize
        //  宽图
        if imageSize.width / imageSize.height > scrollView.frame.size.width / scrollView.frame.size.height {
            //  计算出自大缩放比
            scrollView.maximumZoomScale = frame.height / imageActualSize.height
            scrollView.contentInset = UIEdgeInsets(top: (scrollView.frame.size.height - imageActualSize.height) / 2,
                                                   left: 0,
                                                   bottom: (scrollView.frame.size.height - imageActualSize.height) / 2,
                                                   right: 0)
            type = .WidthStyle
        }
        else {
            //  计算出自大缩放比
            scrollView.maximumZoomScale = frame.width / imageActualSize.width
            scrollView.contentInset = UIEdgeInsets(top: 0,
                                                   left: (scrollView.frame.size.width - imageActualSize.width) / 2,
                                                   bottom: 0,
                                                   right: (scrollView.frame.size.width - imageActualSize.width) / 2)
            type = .HeightStyle
        }
    }
}

//  MARK: Private
extension PhotoCell {
    
    //  当图片等比放大到宽度等于屏幕宽度时，图片在cell中的rect
    func calculateImageActualRectInCell(imageSize: CGSize) -> CGRect {
        //  宽图
        if imageSize.width / imageSize.height > self.frame.size.width / self.frame.size.height {
            //  获取所占区域大小
            let boundingRect = CGRect(x: 0, y: 0, width: frame.size.width, height: CGFloat(MAXFLOAT))
            let imageActualSize = AVMakeRectWithAspectRatioInsideRect(CGSize(width: imageSize.width, height:imageSize.height), boundingRect).size
            return CGRect(origin: CGPoint(x: 0, y: (frame.size.height - imageActualSize.height) / 2), size: imageActualSize)
        }
        else {
            //  获取所占区域大小
            let boundingRect = CGRect(x: 0, y: 0, width: CGFloat(MAXFLOAT), height: frame.size.height)
            let imageActualSize = AVMakeRectWithAspectRatioInsideRect(CGSize(width: imageSize.width, height:imageSize.height), boundingRect).size
            return CGRect(origin: CGPoint(x: (frame.size.width - imageActualSize.width) / 2, y: 0), size: imageActualSize)
        }
    }
}

extension PhotoCell: UIScrollViewDelegate {
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        //  缩放的时候要调整contentInset 很关键
        //  超长图片因为maximumZoomScale = 1所以进不了这个方法。
        if case .WidthStyle = type {
            scrollView.contentInset = UIEdgeInsets(top: (scrollView.frame.size.height - imageView.frame.height) / 2,
                                                   left: 0,
                                                   bottom: (scrollView.frame.size.height - imageView.frame.height) / 2,
                                                   right: 0)
        }
        else {
            scrollView.contentInset = UIEdgeInsets(top: 0,
                                                   left: (scrollView.frame.size.width - imageView.frame.width) / 2,
                                                   bottom: 0,
                                                   right: (scrollView.frame.size.width - imageView.frame.width) / 2)
        }
    }
}
