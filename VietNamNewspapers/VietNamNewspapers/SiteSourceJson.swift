//
//  SiteSourceJson.swift
//  VietNamNewspapers
//
//  Created by admin on 4/1/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import ObjectMapper

class SitesSource:Mappable{
    var siteSource: [SiteSource]?
    var version: Int?
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        version    <- map["version"]
        siteSource    <- map["sites"]
    }
}
class SiteSource:Mappable
{
    var url:String?
    
    var isCheck:Bool=true
    var iconArray:Data?
    var siteItemSource: [SiteItemSource]?
    var name:String?
    var direct:Int?
    var leaf:Int?
    var icon:String?
    var hide:String?
    var m:Int?
    var countrycode:String?
    var mobilizer:String?
    var magazinecode:Int?
    var encoding:String?
    var deleted:Int?
    var _default:Int?
    
    required init?(map: Map) {
        // super.init(map)
        
    }
    
    func mapping(map: Map) {
         url    <- map["url"]
        siteItemSource   <- map["feeds"]
        name    <- map["name"]
        direct    <- map["direct"]
        leaf    <- map["leaf"]
        icon    <- map["icon"]
        hide    <- map["hide"]
        m    <- map["m"]
        countrycode    <- map["countrycode"]
        mobilizer    <- map["mobilizer"]
        magazinecode    <- map["magazinecode"]
        encoding    <- map["encoding"]
        deleted    <- map["deleted"]
        _default    <- map["default"]
        
    }
    
}
class SiteItemSource:SiteSource
{
    
}
