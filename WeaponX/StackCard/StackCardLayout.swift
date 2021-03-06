//
//  StackCardLayout.swift
//  Demo
//
//  Created by 马权 on 6/2/16.
//  Copyright © 2016 马权. All rights reserved.
//

import UIKit

public class StackCardLayout: UICollectionViewLayout {
    
    public var topStackSpace: CGFloat = 0
    
    public var bottomStackSpace: CGFloat = 0
    
    public var cardSize: CGSize = CGSizeZero
    
    public var stackCount: Int = 3
    
    public var needStackAll: Bool = false
    
    private var contentWidth: CGFloat {
        get {
            return CGRectGetWidth(collectionView!.bounds)
        }
    }
    
    private var contentHeight: CGFloat {
        get {
            let height = CGFloat(numberOfItems) * cardSize.height - CGFloat(numberOfItems - 1) * bottomStackSpace
            if needStackAll {
                let maxStackCount: Int = numberOfItems > stackCount ? stackCount : numberOfItems - 1
                return height +
                    (collectionView!.bounds.size.height - cardSize.height - topStackSpace * CGFloat(maxStackCount))
            }
            else {
                return height
            }
        }
    }
    
    private var numberOfItems: Int {
        get {
            return collectionView!.numberOfItemsInSection(0)
        }
    }
    
    public override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let minY: CGFloat = CGRectGetMinY(rect)
        let maxY: CGFloat = CGRectGetMaxY(rect)
        
        var minIndex: Int = Int((minY - (cardSize.height - bottomStackSpace) * CGFloat(stackCount) - topStackSpace * CGFloat(stackCount)) / (cardSize.height - bottomStackSpace))
        minIndex = minIndex < 0 ? 0 : minIndex
        
        var maxIndex: Int = Int(maxY / (cardSize.height - bottomStackSpace)) + 1
        maxIndex = maxIndex > numberOfItems - 1 ? numberOfItems - 1 : maxIndex
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for i in minIndex ... maxIndex {
            if let attribute = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0)) {
                layoutAttributes.append(attribute)
            }
        }
        return layoutAttributes
    }
    
    public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        let offSetY = collectionView!.contentOffset.y
        
        var y: CGFloat = 0
        
        let attribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        attribute.zIndex = attribute.indexPath.row
        
        let index = CGFloat(indexPath.item)
        
        if offSetY < 0 {
            y = index * (cardSize.height - bottomStackSpace)
        }
        else {
            let height: CGFloat = cardSize.height - bottomStackSpace
            
            let stackCount: CGFloat = CGFloat(self.stackCount)
            
            let maxStackCount: CGFloat = index > stackCount ? stackCount : index
            
            if offSetY <= index * height - maxStackCount * topStackSpace {
                y = height * index
            }
            else {
                var finish = false
                var dascend = stackCount
                while dascend >= 0 {
                    let ascend = stackCount + 1 - dascend
                    if offSetY <= (index + ascend) * height - (stackCount + 1) * topStackSpace && index >= dascend {
                        y = offSetY + (stackCount - (ascend - 1)) * topStackSpace
                        finish = true
                        break
                    }
                    else if offSetY <= (index + ascend) * height - stackCount * topStackSpace && index >= dascend {
                        y = (index + ascend) * height - ascend * topStackSpace
                        finish = true
                        break
                    }
                    dascend -= 1
                }
                if !finish {
                    if offSetY <= (index + stackCount + 1) * height - stackCount * topStackSpace && index >= 0 {
                        y = offSetY + (stackCount - stackCount) * topStackSpace
                    }
                }
            }
        }
        
        attribute.frame = CGRect(origin: CGPoint(x: 0, y: y), size: cardSize)
        return attribute
    }
    
    public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
