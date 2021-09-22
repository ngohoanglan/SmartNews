//
//  FeedData.swift
//  VietNamNewspapers
//
//  Created by admin on 2/22/16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation
import CoreData
import RealmSwift

class FeedData: Object {
    @Persisted var feedDescription: String?
    @Persisted var feedID: String?
    @Persisted var imageArray: Data?
    @Persisted var isFavorite: Int?
    @Persisted var isRead: Int?
    @Persisted var link: String?
    @Persisted var linkImage: String?
    @Persisted var loadTime: Date?
    @Persisted var pubDateString: String?
    @Persisted var siteID: String?
    @Persisted var siteItemID: String?
    @Persisted var title: String?
    @Persisted var timeStamp: Int?
    @objc dynamic var isExpand = false
    override static func ignoredProperties() -> [String] {
        ["isExpand"]
    }
}
