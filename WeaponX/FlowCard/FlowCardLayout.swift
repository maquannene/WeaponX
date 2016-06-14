//
//  FlowCardLayout.swift
//  Demo
//
//  Created by 马权 on 6/5/16.
//  Copyright © 2016 马权. All rights reserved.
//

import UIKit

public class FlowCardLayout: UICollectionViewLayout {
    
    public var topStackSpace: CGFloat = 0
    
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
            let height = CGFloat(numberOfItems) * cardSize.height
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
        
        var minIndex: Int = Int((minY - cardSize.height * CGFloat(stackCount) - topStackSpace * CGFloat(stackCount)) / cardSize.height)
        minIndex = minIndex < 0 ? 0 : minIndex
        
        var maxIndex: Int = Int(maxY / cardSize.height) + 1
        maxIndex = maxIndex > numberOfItems - 1 ? numberOfItems - 1 : maxIndex
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for i in minIndex ... maxIndex {
            if let attribute = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0)) {
                if let lastAttribute = layoutAttributes.last {
                    var rect = lastAttribute.frame
                    rect.size.height = attribute.frame.minY - lastAttribute.frame.minY
                    lastAttribute.frame = rect
                }
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
            y = index * cardSize.height
        }
        else {
            let height: CGFloat = cardSize.height
            
            let stackCount: CGFloat = CGFloat(self.stackCount)
            
            let maxStackCount: CGFloat = index > stackCount ? stackCount : index
            
            let offsetRatio: CGFloat = 1 - (topStackSpace) / cardSize.height
            
            if offSetY <= height * index - topStackSpace * maxStackCount {
                y = height * index
            }
            else if offSetY <= height * stackCount - topStackSpace * stackCount {
                y = offSetY + index * topStackSpace
            }
            else {
                let offSetYOver: CGFloat = offSetY - (height * index - topStackSpace * stackCount)
                y = height * index + offSetYOver * offsetRatio
            }
        }
        
        attribute.frame = CGRect(origin: CGPoint(x: 0, y: y), size: cardSize)
        
        return attribute
    }
    
    public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
