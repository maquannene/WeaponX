//
//  PhotoBrowserController
//  PhotoBrowser
//
//  Created by 马权 on 10/7/15.
//  Copyright © 2015 马权. All rights reserved.
//

import UIKit

typealias ShowAnimationInfo = (imageView: UIImageView, fromView: UIView)
typealias HideAnimationInfo = (imageView: UIImageView, toView: UIView)

@objc protocol PhotoBrowserControllerDelegate: NSObjectProtocol {
    optional func photoBrowserController(controller: PhotoBrowserController, willDisplayCell pictureCell: PhotoBrowserCell, forItemAtIndex index: Int)
    //    optional func photoBrowserController(controller: PhotoBrowserController, didDisplayCell pictureCell: PhotoBrowserCell, forItemAtIndex index: Int)
}

protocol PhotoBrowserControllerDataSource: NSObjectProtocol {
    func photoBrowserController(controller: PhotoBrowserController, animationInfoOfShowPictureAtIndex index: Int) -> ShowAnimationInfo?
    func photoBrowserController(controller: PhotoBrowserController, animationInfoOfHidePictureAtIndex index: Int) -> HideAnimationInfo?
    func numberOfItemsInPhotoBrowserController(controller: PhotoBrowserController) -> Int
    func photoBrowserController(controller: PhotoBrowserController, pictureCellForItemAtIndex index: Int) -> PhotoBrowserCell
}

public enum PictureBorwserAnimationModel {
    case Move
    case MoveAndBackgroundFadeOut                //  default
}


class PhotoBrowserController: UIViewController {
    
    var collectionView: UICollectionView!
    weak var dataSource: PhotoBrowserControllerDataSource?
    weak var delegate: PhotoBrowserControllerDelegate?
    var animationModel: PictureBorwserAnimationModel = .MoveAndBackgroundFadeOut
    var cellGap: CGFloat = 0
    var currentIndex: Int = 0
    
    private var collectionViewFlowLayout: UICollectionViewFlowLayout!
    private lazy var tmpImageView = UIImageView()
    private lazy var blurEffect = UIBlurEffect(style: .ExtraLight)
    private var blurEffectView: UIVisualEffectView!
    private var statusBarHidden: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.collectionViewFlowLayout)
        animationModel = .MoveAndBackgroundFadeOut
        
        blurEffectView = UIVisualEffectView(effect: blurEffect) //  毛玻璃效果
    }
    
    convenience init(animationModel: PictureBorwserAnimationModel) {
        self.init()
        self.animationModel = animationModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRectMake(0, 0, UIApplication.sharedApplication().windows[0].frame.width, UIApplication.sharedApplication().windows[0].frame.height)
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
        
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        collectionViewFlowLayout.minimumLineSpacing = cellGap
        collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: cellGap / 2, left: cellGap / 2, bottom: cellGap / 2, right: cellGap / 2)
        collectionViewFlowLayout.itemSize = CGSize(width: self.view.frame.size.width - cellGap, height: self.view.frame.size.height - cellGap)
        
        collectionView.frame = self.view.bounds
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.pagingEnabled = true
        collectionView.alwaysBounceVertical = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.hidden = true
        view.addSubview(collectionView)
        view.insertSubview(collectionView, aboveSubview: blurEffectView)
        
        tmpImageView.clipsToBounds = true
        tmpImageView.layer.cornerRadius = 7.5
        tmpImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        blurEffectView.alpha = 0
        blurEffectView.frame = self.view.bounds
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
    
    deinit {
        print("\(self.dynamicType) deinit\n", terminator: "")
    }
    
}

//  MARK: Public
extension PhotoBrowserController {
    
    func presentFromViewController(viewController: UIViewController!, atIndexPicture index: Int = 0) {
        
        self.statusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        viewController.presentViewController(self, animated: false) {
            
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            
            if let showAnimationInfo = self.dataSource!.photoBrowserController(self, animationInfoOfShowPictureAtIndex: index) as ShowAnimationInfo? {
                
                if self.animationModel == .Move{
                    self.blurEffectView.alpha = 0
                    self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                    self.view.addSubview(self.tmpImageView)                                         //  先将动画图片加在self.view上
                    self.tmpImageView.image = showAnimationInfo.imageView.image                     //  设置动画图片内容
                    let beginRect = self.view.convertRect(showAnimationInfo.imageView.frame, fromView: showAnimationInfo.imageView.superview)
                    self.tmpImageView.frame = beginRect                                             //  设置动画其实坐标
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        let caculateEndRect: (cell: PhotoBrowserCell) -> CGRect = { cell in
                            let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                            return self.view.convertRect(imageActualRect, fromView: cell)
                        }
                        let cell = self.dataSource!.photoBrowserController(self, pictureCellForItemAtIndex: index)
                        var endRect = CGRectZero
                        if cell.superview == nil {
                            self.collectionView.addSubview(cell)
                            endRect = caculateEndRect(cell: cell)
                            cell.removeFromSuperview()
                        }
                        else {
                            endRect = caculateEndRect(cell: cell)
                        }
                        self.tmpImageView.frame = endRect
                        }, completion: { (success) -> Void in
                            self.collectionView.hidden = false
                            self.tmpImageView.removeFromSuperview()
                    })
                }
                
                if self.animationModel == .MoveAndBackgroundFadeOut {
                    self.view.addSubview(self.tmpImageView)                                             //  先将动画图片加在self.view上
                    self.tmpImageView.image = showAnimationInfo.imageView.image                         //  设置动画图片内容
                    let beginRect = self.view.convertRect(showAnimationInfo.imageView.frame, fromView: showAnimationInfo.imageView.superview)
                    self.tmpImageView.frame = beginRect                                                 //  设置动画其实坐标
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.blurEffectView.alpha = 0.9
                        let caculateEndRect: (cell: PhotoBrowserCell) -> CGRect = { cell in
                            let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                            return self.view.convertRect(imageActualRect, fromView: cell)
                        }
                        let cell = self.dataSource!.photoBrowserController(self, pictureCellForItemAtIndex: index)
                        var endRect = CGRectZero
                        if cell.superview == nil {
                            self.collectionView.addSubview(cell)
                            endRect = caculateEndRect(cell: cell)
                            cell.removeFromSuperview()
                        }
                        else {
                            endRect = caculateEndRect(cell: cell)
                        }
                        self.tmpImageView.frame = endRect
                        }, completion: { (success) -> Void in
                            self.collectionView.hidden = false
                            self.tmpImageView.removeFromSuperview()
                    })
                }
            }
            else {
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                self.view.addSubview(self.collectionView)
            }
        }
    }
    
    func dismiss() {
        
        var currentPictureIndex = 0
        if let cell = self.collectionView.visibleCells()[0] as? PhotoBrowserCell {
            currentPictureIndex = self.collectionView.indexPathForCell(cell)!.item
        }
        
        if let hideAnimationInfo = self.dataSource!.photoBrowserController(self, animationInfoOfHidePictureAtIndex: currentPictureIndex) as HideAnimationInfo? {
            
            if animationModel == .Move {
                hideAnimationInfo.toView.addSubview(self.tmpImageView)                          //  先将临时动画视图加载toView上
                self.tmpImageView.image = hideAnimationInfo.imageView.image                     //  设置动画图片内容
                
                let caculateEndRect: (cell: PhotoBrowserCell) -> CGRect = { cell in
                    let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                    return hideAnimationInfo.toView.convertRect(imageActualRect, fromView: cell)
                }
                let cell = self.dataSource!.photoBrowserController(self, pictureCellForItemAtIndex: currentPictureIndex)
                var beginRect = CGRectZero
                if cell.superview == nil {
                    self.collectionView.addSubview(cell)
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
                self.collectionView.hidden = true
                
                let caculateEndRect: (cell: PhotoBrowserCell) -> CGRect = { cell in
                    let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                    return self.view.convertRect(imageActualRect, fromView: cell)
                }
                
                let cell = self.dataSource!.photoBrowserController(self, pictureCellForItemAtIndex: currentPictureIndex)
                var beginRect = CGRectZero
                if cell.superview == nil {
                    self.collectionView.addSubview(cell)
                    beginRect = caculateEndRect(cell: cell)
                    cell.removeFromSuperview()
                }
                else {
                    beginRect = caculateEndRect(cell: cell)
                }
                self.tmpImageView.frame = beginRect
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.blurEffectView.alpha = 0
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

extension PhotoBrowserController: PhotoBrowserCellDelegate {
    
    func photoBrowserCellTap(photoBrowserCell: PhotoBrowserCell) {
        dismiss()
    }
    
}

extension PhotoBrowserController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let imageTextCell = cell as? PhotoBrowserCell else { return }
        currentIndex = indexPath.item
        delegate?.photoBrowserController?(self, willDisplayCell: imageTextCell, forItemAtIndex: indexPath.item)
    }
    
}

extension PhotoBrowserController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource!.numberOfItemsInPhotoBrowserController(self)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = dataSource!.photoBrowserController(self, pictureCellForItemAtIndex: indexPath.item)
        cell.delegate = self
        return cell
    }
    
}