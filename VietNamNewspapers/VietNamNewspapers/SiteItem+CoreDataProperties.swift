//
//  SiteItem+CoreDataProperties.swift
//  VietNamNewspapers
//
//  Created by admin on 2/22/16.
//  Copyright © 2016 admin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SiteItem {

    @NSManaged var encoding: String?
    @NSManaged var isDefault: NSNumber?
    @NSManaged var isFavorite: NSNumber?
    @NSManaged var isHide: NSNumber?
    @NSManaged var isSync: NSNumber?
    @NSManaged var loadTime: Date?
    @NSManaged var position: NSNumber?
    @NSManaged var siteItemID: String?
    @NSManaged var siteItemName: String?
    @NSManaged var siteID: String?
    @NSManaged var siteItemNameBackup: String?
    @NSManaged var siteItemURL: String?
    @NSManaged var siteItemURLBackup: String?

}
