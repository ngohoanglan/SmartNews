//
//  FeedData.swift
//  VietNamNewspapers
//
//  Created by admin on 2/22/16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedData)
class FeedData: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
     var isExpand:Bool=false

}
enum FeedDataAttributes : String {
    case
    feedDescription    = "feedDescription",
    feedID      = "feedID",
    imageArray       = "imageArray",
    isFavorite      = "isFavorite",
    isRead       = "isRead",
    link    = "link",
    linkImage  = "linkImage",
    loadTime      = "loadTime",
    pubDateString = "pubDateString",
    siteID="siteID",
    siteItemID="siteItemID",
    title="title",
    timeStamp="timeStamp"
    
    static let getAll = [
        feedDescription,
        feedID,
        imageArray,
        isFavorite,
        isRead,
        link,
        linkImage,
        loadTime,
        pubDateString,
        siteID,
        siteItemID,
        title,
        timeStamp
        
    ]
}
/*
@NSManaged var feedDescription: String?
@NSManaged var feedID: String?
@NSManaged var imageArray: NSData?
@NSManaged var isFavorite: NSNumber?
@NSManaged var isRead: NSNumber?
@NSManaged var link: String?
@NSManaged var linkImage: String?
@NSManaged var loadTime: NSDate?
@NSManaged var pubDateString: String?
@NSManaged var siteID: String?
@NSManaged var siteItemID: String?
@NSManaged var title: String?
*/