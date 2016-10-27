//
//  GalleryItem.swift
//  EvilNotes
//
//  Created by Sarahí López on 10/6/16.
//  Copyright © 2016 RoqueRueda. All rights reserved.
//

import Foundation

class GalleryItem {

    var itemImage: String
    
    init(dataDictionary:Dictionary<String,String>) {
        itemImage = dataDictionary["itemImage"]!
    }
    
    class func newGalleryItem(dataDictionary:Dictionary<String,String>) -> GalleryItem {
        return GalleryItem(dataDictionary: dataDictionary)
    }
    
}
