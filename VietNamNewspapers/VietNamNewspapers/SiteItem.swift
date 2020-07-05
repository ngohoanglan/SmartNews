//
//  SiteItem.swift
//  VietNamNewspapers
//
//  Created by admin on 2/22/16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation
import CoreData

@objc(SiteItem)
class SiteItem: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}
enum SiteItemAttributes : String {
    case
    encoding    = "encoding",
    isDefault      = "isDefault",
    isFavorite       = "isFavorite",
    isHide      = "isHide",
    isSync       = "isSync",
    loadTime    = "loadTime",
    position  = "position",
    siteItemID      = "siteItemID",
    siteItemName = "siteItemName",
    siteID="siteID",
    siteItemNameBackup="siteItemNameBackup",
    siteItemURL="siteItemURL",
    siteItemURLBackup="siteItemURLBackup"
    
    static let getAll = [
        encoding,
        isDefault,
        isHide,
        isFavorite,
        isSync,
        loadTime,
        position,
        siteItemID,
        siteItemName,
        siteID,
        siteItemNameBackup,
        siteItemURL,
        siteItemURLBackup
        
    ]
}
/*
@NSManaged var encoding: String?
@NSManaged var isDefault: NSNumber?
@NSManaged var isFavorite: NSNumber?
@NSManaged var isHide: NSNumber?
@NSManaged var isSync: NSNumber?
@NSManaged var loadTime: NSDate?
@NSManaged var position: NSNumber?
@NSManaged var siteItemID: String?
@NSManaged var siteItemName: String?
@NSManaged var siteID: String?
@NSManaged var siteItemNameBackup: String?
@NSManaged var siteItemURL: String?
@NSManaged var siteItemURLBackup: String?
*/