//
//  PhotoBrowserController
//  PhotoBrowser
//
//  Created by 马权 on 10/7/15.
//  Copyright © 2015 马权. All rights reserved.
//

import UIKit

public typealias ShowAnimationInfo = (imageView: UIImageView, fromView: UIView)
public typealias HideAnimationInfo = (imageView: UIImageView, toView: UIView)

public protocol PhotoBrowserControllerDelegate: class {
    func photoBrowserController(controller: PhotoBrowserController, willDisplayCell photoCell: PhotoCell, forItemAtIndex index: Int)
    func photoBrowserController(controller: PhotoBrowserController, didEndDisplayingCell photoCell: PhotoCell, forItemAtIndex index: Int)
    func photoBrowserController(controller: PhotoBrowserController, tapCell photoCell: PhotoCell, forItemAtIndex index: Int)
}
public protocol PhotoBrowserControllerDataSource: class {
    func photoBrowserController(controller: PhotoBrowserController, animationInfoOfShowPhotoAtIndex index: Int) -> ShowAnimationInfo?
    func photoBrowserController(controller: PhotoBrowserController, animationInfoOfHidePhotoAtIndex index: Int) -> HideAnimationInfo?
    func numberOfItemsInPhotoBrowserController(controller: PhotoBrowserController) -> Int
    func photoBrowserController(controller: PhotoBrowserController, photoCellForItemAtIndex index: Int) -> PhotoCell
}

public class PhotoBrowserController: UIViewController {

    public weak var dataSource: PhotoBrowserControllerDataSource?
    public weak var delegate: PhotoBrowserControllerDelegate?
    public var photoGap: CGFloat = 20
    public var currentIndex: Int {
        var currentPhotoIndex = 0
        if let cell = _browserView.visibleCells()[0] as? PhotoCell {
            currentPhotoIndex = _browserView.indexPathForCell(cell)!.item
        }
        return currentPhotoIndex
    }
    
    private var _browserView: UICollectionView
    private var _flowLayout: UICollectionViewFlowLayout
    private var _animationImageView = UIImageView()
    private var _statusBarHidden: Bool = false
    
    public required init?(coder aDecoder: NSCoder) {
        _flowLayout = UICollectionViewFlowLayout()
        _browserView = UICollectionView(frame: CGRectZero, collectionViewLayout: _flowLayout)
        super.init(coder: aDecoder)
        modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        _flowLayout = UICollectionViewFlowLayout()
        _browserView = UICollectionView(frame: CGRectZero, collectionViewLayout: _flowLayout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRectMake(0, 0, UIApplication.sharedApplication().windows[0].frame.width, UIApplication.sharedApplication().windows[0].frame.height)
        
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        _flowLayout.minimumLineSpacing = photoGap
        _flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        _browserView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: photoGap)
        _flowLayout.itemSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        _browserView.frame = CGRectMake(0, 0, view.frame.size.width + photoGap, view.frame.size.height)
        _browserView.backgroundColor = UIColor.clearColor()
        _browserView.pagingEnabled = true
        _browserView.showsHorizontalScrollIndicator = false
        _browserView.showsVerticalScrollIndicator = false
        _browserView.delegate = self
        _browserView.dataSource = self
        _browserView.hidden = true
        view.addSubview(_browserView)
        
        _animationImageView.clipsToBounds = true
        _animationImageView.layer.cornerRadius = 7.5
        _animationImageView.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return _statusBarHidden
    }
    
    public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
}

//  MARK: Public
public extension PhotoBrowserController {
    
    public func registerClass(cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        _browserView.registerClass(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func registerNib(nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        _browserView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCellWithReuseIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> PhotoCell {
        return _browserView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! PhotoCell
    }
    
    public func presentFromViewController(viewController: UIViewController!, atIndexPhoto index: Int = 0) {

        _statusBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
        
        viewController.presentViewController(self, animated: false) {
            
            self._browserView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            
            if let showAnimationInfo = self.dataSource!.photoBrowserController(self, animationInfoOfShowPhotoAtIndex: index) as ShowAnimationInfo? {
                
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)            //  初始化背景为白色
                self.view.addSubview(self._animationImageView)                                             //  先将动画图片加在self.view上
                self._animationImageView.image = showAnimationInfo.imageView.image                         //  设置动画图片内容
                let beginRect = self.view.convertRect(showAnimationInfo.imageView.frame, fromView: showAnimationInfo.imageView.superview)
                self._animationImageView.frame = beginRect                                                 //  设置动画其实坐标
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)        //  初始化背景为黑色
                    let caculateEndRect: (cell: PhotoCell) -> CGRect = { cell in
                        let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                        return self.view.convertRect(imageActualRect, fromView: cell)
                    }
                    let cell = self.dataSource!.photoBrowserController(self, photoCellForItemAtIndex: index)
                    var endRect = CGRectZero
                    if cell.superview == nil {
                        self._browserView.addSubview(cell)
                        endRect = caculateEndRect(cell: cell)
                        cell.removeFromSuperview()
                    }
                    else {
                        endRect = caculateEndRect(cell: cell)
                    }
                    self._animationImageView.frame = endRect
                    }, completion: { (success) -> Void in
                        self._browserView.hidden = false
                        self._animationImageView.removeFromSuperview()
                })
            }
            else {
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                self.view.addSubview(self._browserView)
            }
        }
    }
    
    public func dismiss() {
        
        if let hideAnimationInfo = self.dataSource!.photoBrowserController(self, animationInfoOfHidePhotoAtIndex: currentIndex) as HideAnimationInfo? {
            
            self.view.addSubview(self._animationImageView)
            self._animationImageView.image = hideAnimationInfo.imageView.image
            _browserView.hidden = true
            
            let caculateEndRect: (cell: PhotoCell) -> CGRect = { cell in
                let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                return self.view.convertRect(imageActualRect, fromView: cell)
            }
            
            let cell = self.dataSource!.photoBrowserController(self, photoCellForItemAtIndex: currentIndex)
            var beginRect = CGRectZero
            if cell.superview == nil {
                _browserView.addSubview(cell)
                beginRect = caculateEndRect(cell: cell)
                cell.removeFromSuperview()
            }
            else {
                beginRect = caculateEndRect(cell: cell)
            }
            self._animationImageView.frame = beginRect
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                let endRect = self.view.convertRect(hideAnimationInfo.imageView.frame, fromView: hideAnimationInfo.imageView.superview)
                self._animationImageView.frame = endRect
                }, completion: { (success) -> Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
            })
        }
        else {
            dismissViewControllerAnimated(false, completion: nil)
        }
    }
}

extension PhotoBrowserController: PhotoCellDelegate {
    
    func photoCellTap(photoCell: PhotoCell) {
        delegate?.photoBrowserController(self, tapCell: photoCell, forItemAtIndex: currentIndex)
    }
}

extension PhotoBrowserController: UICollectionViewDelegate {
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let photoCell = cell as? PhotoCell else { return }
        delegate?.photoBrowserController(self, willDisplayCell: photoCell, forItemAtIndex: indexPath.item)
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let photoCell = cell as? PhotoCell else { return }
        delegate?.photoBrowserController(self, didEndDisplayingCell: photoCell, forItemAtIndex: indexPath.item)
    }
}

extension PhotoBrowserController: UICollectionViewDataSource {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource!.numberOfItemsInPhotoBrowserController(self)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = dataSource!.photoBrowserController(self, photoCellForItemAtIndex: indexPath.item)
        cell.delegate = self
        return cell
    }
}