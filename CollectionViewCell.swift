//
//  CollectionViewCell.swift
//  EvilNotes
//
//  Created by Sarahí López on 10/6/16.
//  Copyright © 2016 RoqueRueda. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var itemImageView: UIImageView!
    
    func setGalleryItem(item:GalleryItem, width: CGFloat) {
        itemImageView.image = UIImage(named: item.itemImage)
        itemImageView.contentMode = UIViewContentMode.scaleAspectFit
        itemImageView.frame = CGRect.init(origin: CGPoint(x:0,y:0), size: CGSize(width: 70, height: 70))
    }
    
    func setGalleryPickerImage(image: UIImage) {
        itemImageView.image = image;
        itemImageView.frame = CGRect.init(origin: CGPoint(x:0,y:0), size: CGSize(width: 70, height: 70))
        itemImageView.contentMode = UIViewContentMode.scaleAspectFit
    }
    
}
