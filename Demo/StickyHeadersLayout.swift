//
//  StickyHeadersLayout.swift
//  Camera Roll
//
//  Created by   on 18/03/2015.
//  Copyright (c) 2015   All rights reserved.
//

import UIKit

class StickyHeadersLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElementsInRect(rect) as [UICollectionViewLayoutAttributes]!
        
        let headersNeedingLayout = NSMutableIndexSet()
        
        //  暴力找出当前所有能看到的cell的section值的集合，去重复
        for attributes in layoutAttributes {
            if attributes.representedElementCategory == .Cell {
                headersNeedingLayout.addIndex(attributes.indexPath.section)
            }
        }
        //  从集合中移除已经显示出的，因为能显示出的都已经加在了layoutAttributes中
        for attributes in layoutAttributes {
            if let elementKind = attributes.representedElementKind {
                if elementKind == UICollectionElementKindSectionHeader {
                    headersNeedingLayout.removeIndex(attributes.indexPath.section)
                }
            }
        }
        //  将集合中剩下的，即没有显示的 但是 需要显示的加入layoutAttributes中
        headersNeedingLayout.enumerateIndexesUsingBlock { (index, stop) -> Void in
            let indexPath = NSIndexPath(forItem: 0, inSection: index)
            let attributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath)
            layoutAttributes.append(attributes!)
        }
        
        for attributes in layoutAttributes {
            if let elementKind = attributes.representedElementKind {
                if elementKind == UICollectionElementKindSectionHeader {
                    let section = attributes.indexPath.section
                    let attributesForFirstItemInSection = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: section))
                    let attributesForLastItemInSection = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: collectionView!.numberOfItemsInSection(section) - 1, inSection: section))
                    var frame = attributes.frame
                    let offset = collectionView!.contentOffset.y
                
                    let minY = CGRectGetMinY(attributesForFirstItemInSection!.frame) - frame.height
                    
                    let maxY = CGRectGetMaxY(attributesForLastItemInSection!.frame) - frame.height

                    let y = min(max(offset, minY), maxY)
                    
                    frame.origin.y = y
                    attributes.frame = frame
                    attributes.zIndex = 99
                }
            }
        }
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
}
