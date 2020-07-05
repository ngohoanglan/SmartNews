//
//  Site.swift
//  VietNamNewspapers
//
//  Created by admin on 2/22/16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation
import CoreData

@objc(Site)
class Site: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

enum SiteAttributes : String {
    case
    countryCode    = "countryCode",
    iconArray    = "iconArray",
    isDefault      = "isDefault",
    isHide      = "isHide",
    isFavorite       = "isFavorite",
    modify       = "modify",
    position    = "position",
    siteIconPath  = "siteIconPath",
    siteID      = "siteID",
    siteName = "siteName",
    siteURL="siteURL"
    
    
    static let getAll = [
        countryCode,
        iconArray,
        isDefault,
        isHide,
        isFavorite,
        modify,
        position,
        siteIconPath,
        siteID,
        siteName,
        siteID,
        siteURL
    ]
}
/*
@NSManaged var iconArray: NSData?
@NSManaged var isDefault: NSNumber?
@NSManaged var isHide: NSNumber?
@NSManaged var isFavorite: NSNumber?
@NSManaged var modify: NSNumber?
@NSManaged var position: NSNumber?
@NSManaged var siteIconPath: String?
@NSManaged var siteID: String?
@NSManaged var siteName: String?
@NSManaged var siteURL: String?
*/

