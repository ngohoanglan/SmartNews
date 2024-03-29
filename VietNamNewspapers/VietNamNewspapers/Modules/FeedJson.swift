//
//  FeedJson.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 12/27/16.
//  Copyright © 2016 admin. All rights reserved.
//
import ObjectMapper
import Foundation
class Feeds:Mappable
{
    var feedsJson: [FeedJson]?
    var version:Int?
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        feedsJson    <- map["feeds"]
    }
    
}

class FeedJson:Mappable
{
    
    var Title:String?
    var Link:String?
    var ImgLink:String?
    var Description:String?
    var PubDate:String?
    
    required init?(map: Map) {
        // super.init(map)
        
    }
    
    func mapping(map: Map) {
       
        Title    <- map["Title"]
        Link    <- map["Link"]
        ImgLink    <- map["ImgLink"]
        Description    <- map["Description"]
        PubDate    <- map["PubDate"]
        
    }
    
}
