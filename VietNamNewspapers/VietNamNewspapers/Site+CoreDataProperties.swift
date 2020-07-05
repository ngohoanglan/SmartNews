//
//  Site+CoreDataProperties.swift
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

extension Site {

    @NSManaged var countryCode: String?
    @NSManaged var iconArray: Data?
    @NSManaged var isDefault: NSNumber?
    @NSManaged var isHide: NSNumber?
    @NSManaged var isFavorite: NSNumber?
    @NSManaged var modify: NSNumber?
    @NSManaged var position: NSNumber?
    @NSManaged var siteIconPath: String?
    @NSManaged var siteID: String?
    @NSManaged var siteName: String?
    @NSManaged var siteURL: String?

}
