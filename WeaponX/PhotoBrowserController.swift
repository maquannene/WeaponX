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

public enum PhotoBorwserAnimationModel {
    case Move
    case MoveAndBackgroundFadeOut                //  default
}

public class PhotoBrowserController: UIViewController {
    
    public var browserView: UICollectionView
    public weak var dataSource: PhotoBrowserControllerDataSource?
    public weak var delegate: PhotoBrowserControllerDelegate?
    public var animationModel: PhotoBorwserAnimationModel = .MoveAndBackgroundFadeOut
    public var photoGap: CGFloat = 0
    public var currentIndex: Int {
        var currentPhotoIndex = 0
        if let cell = browserView.visibleCells()[0] as? PhotoCell {
            currentPhotoIndex = browserView.indexPathForCell(cell)!.item
        }
        return currentPhotoIndex
    }
    
    private var flowLayout: UICollectionViewFlowLayout
    private var tmpImageView = UIImageView()
    private var blurEffect = UIBlurEffect(style: .ExtraLight)
    private var blurEffectView: UIVisualEffectView!
    private var statusBarHidden: Bool = false
    
    public required init?(coder aDecoder: NSCoder) {
        flowLayout = UICollectionViewFlowLayout()
        browserView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        flowLayout = UICollectionViewFlowLayout()
        browserView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        animationModel = .MoveAndBackgroundFadeOut
        blurEffectView = UIVisualEffectView(effect: blurEffect) //  毛玻璃效果
    }
    
    public convenience init(animationModel: PhotoBorwserAnimationModel) {
        self.init()
        self.animationModel = animationModel
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRectMake(0, 0, UIApplication.sharedApplication().windows[0].frame.width, UIApplication.sharedApplication().windows[0].frame.height)
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
        
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        flowLayout.minimumLineSpacing = photoGap
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        browserView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: photoGap)
        flowLayout.itemSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        browserView.frame = CGRectMake(0, 0, view.frame.size.width + photoGap, view.frame.size.height)
        browserView.backgroundColor = UIColor.clearColor()
        browserView.pagingEnabled = true
        browserView.alwaysBounceVertical = false
        browserView.delegate = self
        browserView.dataSource = self
        browserView.hidden = true
        view.addSubview(browserView)
        view.insertSubview(browserView, aboveSubview: blurEffectView)
        tmpImageView.clipsToBounds = true
        tmpImageView.layer.cornerRadius = 7.5
        tmpImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        blurEffectView.alpha = 0
        blurEffectView.frame = self.view.bounds
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
}

//  MARK: Public
public extension PhotoBrowserController {
    
    public func presentFromViewController(viewController: UIViewController!, atIndexPhoto index: Int = 0) {

        self.statusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        viewController.presentViewController(self, animated: false) {
            
            self.browserView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            
            if let showAnimationInfo = self.dataSource!.photoBrowserController(self, animationInfoOfShowPhotoAtIndex: index) as ShowAnimationInfo? {
                
                if self.animationModel == .Move {
                    self.blurEffectView.alpha = 0
                    self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                    self.view.addSubview(self.tmpImageView)                                         //  先将动画图片加在self.view上
                    self.tmpImageView.image = showAnimationInfo.imageView.image                     //  设置动画图片内容
                    let beginRect = self.view.convertRect(showAnimationInfo.imageView.frame, fromView: showAnimationInfo.imageView.superview)
                    self.tmpImageView.frame = beginRect                                             //  设置动画其实坐标
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        let caculateEndRect: (cell: PhotoCell) -> CGRect = { cell in
                            let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                            return self.view.convertRect(imageActualRect, fromView: cell)
                        }
                        let cell = self.dataSource!.photoBrowserController(self, photoCellForItemAtIndex: index)
                        var endRect = CGRectZero
                        if cell.superview == nil {
                            self.browserView.addSubview(cell)
                            endRect = caculateEndRect(cell: cell)
                            cell.removeFromSuperview()
                        }
                        else {
                            endRect = caculateEndRect(cell: cell)
                        }
                        self.tmpImageView.frame = endRect
                        }, completion: { (success) -> Void in
                            self.browserView.hidden = false
                            self.tmpImageView.removeFromSuperview()
                    })
                }
                
                if self.animationModel == .MoveAndBackgroundFadeOut {
                    self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)            //  初始化背景为白色
                    self.view.addSubview(self.tmpImageView)                                             //  先将动画图片加在self.view上
                    self.tmpImageView.image = showAnimationInfo.imageView.image                         //  设置动画图片内容
                    let beginRect = self.view.convertRect(showAnimationInfo.imageView.frame, fromView: showAnimationInfo.imageView.superview)
                    self.tmpImageView.frame = beginRect                                                 //  设置动画其实坐标
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)        //  初始化背景为黑色
                        let caculateEndRect: (cell: PhotoCell) -> CGRect = { cell in
                            let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                            return self.view.convertRect(imageActualRect, fromView: cell)
                        }
                        let cell = self.dataSource!.photoBrowserController(self, photoCellForItemAtIndex: index)
                        var endRect = CGRectZero
                        if cell.superview == nil {
                            self.browserView.addSubview(cell)
                            endRect = caculateEndRect(cell: cell)
                            cell.removeFromSuperview()
                        }
                        else {
                            endRect = caculateEndRect(cell: cell)
                        }
                        self.tmpImageView.frame = endRect
                        }, completion: { (success) -> Void in
                            self.browserView.hidden = false
                            self.tmpImageView.removeFromSuperview()
                    })
                }
            }
            else {
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                self.view.addSubview(self.browserView)
            }
        }
    }
    
    public func dismiss() {
        
        if let hideAnimationInfo = self.dataSource!.photoBrowserController(self, animationInfoOfHidePhotoAtIndex: currentIndex) as HideAnimationInfo? {
            
            if animationModel == .Move {
                hideAnimationInfo.toView.addSubview(self.tmpImageView)                          //  先将临时动画视图加载toView上
                self.tmpImageView.image = hideAnimationInfo.imageView.image                     //  设置动画图片内容
                
                let caculateEndRect: (cell: PhotoCell) -> CGRect = { cell in
                    let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                    return hideAnimationInfo.toView.convertRect(imageActualRect, fromView: cell)
                }
                let cell = self.dataSource!.photoBrowserController(self, photoCellForItemAtIndex: currentIndex)
                var beginRect = CGRectZero
                if cell.superview == nil {
                    browserView.addSubview(cell)
                    beginRect = caculateEndRect(cell: cell)
                    cell.removeFromSuperview()
                }
                else {
                    beginRect = caculateEndRect(cell: cell)
                }
                self.tmpImageView.frame = beginRect
                
                dismissViewControllerAnimated(false) {
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        let endRect = hideAnimationInfo.toView.convertRect(hideAnimationInfo.imageView.frame, fromView: hideAnimationInfo.imageView.superview)
                        self.tmpImageView.frame = endRect                                           //  设置最终位置
                        }, completion: { (success) -> Void in
                            self.tmpImageView.removeFromSuperview()
                    })
                }
            }
            
            if animationModel == .MoveAndBackgroundFadeOut {
                self.view.addSubview(self.tmpImageView)
                self.tmpImageView.image = hideAnimationInfo.imageView.image
                browserView.hidden = true
                
                let caculateEndRect: (cell: PhotoCell) -> CGRect = { cell in
                    let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                    return self.view.convertRect(imageActualRect, fromView: cell)
                }
                
                let cell = self.dataSource!.photoBrowserController(self, photoCellForItemAtIndex: currentIndex)
                var beginRect = CGRectZero
                if cell.superview == nil {
                    browserView.addSubview(cell)
                    beginRect = caculateEndRect(cell: cell)
                    cell.removeFromSuperview()
                }
                else {
                    beginRect = caculateEndRect(cell: cell)
                }
                self.tmpImageView.frame = beginRect
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                    let endRect = self.view.convertRect(hideAnimationInfo.imageView.frame, fromView: hideAnimationInfo.imageView.superview)
                    self.tmpImageView.frame = endRect
                    }, completion: { (success) -> Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                })
            }
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