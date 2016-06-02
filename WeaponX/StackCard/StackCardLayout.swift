//
//  StickyHeadersLayout.swift
//  Camera Roll
//
//  Created by Mic Pringle on 18/03/2015.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

public class StackCardLayout: UICollectionViewLayout {
    
    public var topGap: CGFloat = 0
    
    public var bottomGap: CGFloat = 0
    
    public var cardSize: CGSize = CGSizeZero
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var stackCount: Int = 3
    
    var contentWidth: CGFloat {
        get {
            return CGRectGetWidth(collectionView!.bounds)
        }
    }
    
    var contentHeight: CGFloat {
        get {
            let maxStackCount: Int = numberOfItems > stackCount ? stackCount : numberOfItems - 1
            return CGFloat(numberOfItems) * cardSize.height - CGFloat(numberOfItems - 1) * bottomGap + (collectionView!.bounds.size.height - cardSize.height - topGap * CGFloat(maxStackCount))
        }
    }

    var numberOfItems: Int {
        get {
            return collectionView!.numberOfItemsInSection(0)
        }
    }
    
    public override func prepareLayout() {
        cache.removeAll()
        for item in 0 ..< numberOfItems {
            let indexPath = NSIndexPath(forItem: item, inSection: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.zIndex = item
            attributes.frame = CGRect(origin: CGPoint(x: 0, y: CGFloat(item) * (cardSize.height - bottomGap)), size: cardSize)
            cache.append(attributes)
        }
    }
    
    public override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let offSetY = collectionView!.contentOffset.y
        guard offSetY >= 0 else { return cache }
        let newRect = CGRect(x: rect.origin.x,
                             y: rect.origin.y - ((cardSize.height - bottomGap) * CGFloat(stackCount) - topGap * CGFloat(stackCount)),
                             width: rect.size.width,
                             height: rect.size.height + (cardSize.height - bottomGap) * CGFloat(stackCount) - topGap * CGFloat(stackCount))
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, newRect) {
                layoutAttributes.append(attributes)
            }
        }
        
        layoutAttributes.forEach { attribute in
            var y: CGFloat = 0
            let index = CGFloat(attribute.indexPath.row)
            let height: CGFloat = attribute.frame.size.height - bottomGap
            let stackCount: CGFloat = CGFloat(self.stackCount)
            
            if offSetY <= index * height - 3 * topGap && index >= 3 {
                y = index * height
            }
            else if offSetY <= index * height - 2 * topGap && index == 2 {
                y = height * index
            }
            else if offSetY <= index * height - topGap && index == 1 {
                y = height * index
            }
            else if offSetY <= (index + 1) * height - (stackCount + 1) * topGap && index >= 3 {
                y = offSetY + stackCount * topGap
            }
            else if offSetY <= (index + 1) * height - stackCount * topGap && index >= 3 {
                y = (index + 1) * height -  topGap
            }
            else if offSetY <= (index + 2) * height - (stackCount + 1) * topGap && index >= 2 {
                y = offSetY + (stackCount - 1) * topGap
            }
            else if offSetY <= (index + 2) * height - stackCount * topGap && index >= 2 {
                y = (index + 2) * height - 2 * topGap
            }
            else if offSetY <= (index + 3) * height - (stackCount + 1) * topGap && index >= 1 {
                y = offSetY + (stackCount - 2) * topGap
            }
            else if offSetY <= (index + 3) * height - stackCount * topGap && index >= 1 {
                y = (index + 3) * height - 3 * topGap
            }
            else if offSetY <= (index + 4) * height - stackCount * topGap && index >= 0 {
                y = offSetY + (stackCount - 3) * topGap
            }
            
            var frame = attribute.frame
            frame.origin = CGPoint(x: frame.origin.x, y: y)
            attribute.frame = frame
            attribute.zIndex = attribute.indexPath.row
        }
        return layoutAttributes
    }
    
    public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
}
