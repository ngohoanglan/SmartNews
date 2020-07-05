//
//  ImportDataController.swift
//  VietNamNewspapers
//
//  Created by admin on 2/22/16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation
@objc protocol DownloadDelegate{
    func processingWasFinished()
}
class ImportDataController {
    var delegate: DownloadDelegate?
    fileprivate var siteController: SiteController!
    fileprivate var httpClient:HTTPClient!
     var countryList:Array<Country>=Array<Country>()
    //Utilize Singleton pattern by instanciating Replicator only once.
    class var sharedInstance: ImportDataController {
        struct Singleton {
            static let instance = ImportDataController()
        }
        
        return Singleton.instance
    }
    
    init() {
        self.siteController = SiteController.shareInstance
        self.httpClient = HTTPClient()
    }
    
    
    
    /**
     Pull event data from a given Remote resource, posts a notification to update
     datasource of a given/listening ViewController/UITableView.
     
     - Returns: Void
     */
    func fetchCountryData() {
        
        //Remote resource
        let request:URLRequest = URLRequest(url: URL(string: "http://thealllatestnews.com/Resources/CountryList/list.txt")!)
        
        httpClient.doGet(request) { (data, error, httpStatusCode) -> Void in
            if httpStatusCode!.rawValue != HTTPStatusCode.ok.rawValue {
                print("\(httpStatusCode!.rawValue) \(httpStatusCode)")
                if data == nil {
                    print("data is nil")
                }
            }
            
            else {
                //Read JSON response in seperate thread
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: {
                    // read JSON file, parse JSON data
                 self.processData(data! as AnyObject?)
                   
                    
                    
                    // Post notification to update datasource of a given ViewController/UITableView
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateEventTableData"), object: nil)
                    }
                })
                
            }
        }
        // print(countryList.count)
      //  return countryList
    }
    
    /**
     Process data from a given resource Event objects and assigning
     (additional) property values and calling the Event API to persist Events
     to the datastore.
     
     - Parameter jsonResult: The JSON content to be parsed and stored to Datastore.
     - Returns: Void
     */
    func processData(_ jsonResponse:AnyObject?){
        
        let jsonData:Data = jsonResponse as! Data
        
       let result=NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
     
      
        let countriesArray=result.components(separatedBy: ";")
        for item in countriesArray
        {
            var country:Country!
            var countryDetail=item.components(separatedBy: "-")
            if  countryDetail.count==2
            {
                country=Country()
                country.countryCode=countryDetail[0]
                country.countryName=countryDetail[1]
                country.countryIconPath="http://thealllatestnews.com/Resources/CountryList/"+countryDetail[0]+"/"+countryDetail[0]+".png"
                countryList.append(country)
            }
            
        }
       delegate?.processingWasFinished()                
               
             //  var mySite=site
                /*
                //Create additional event item properties:
                
                //Prefix title with remote(ly) retrieved label
                eventItem[EventAttributes.title.rawValue] = "[REMOTE] \(eventItem[EventAttributes.title.rawValue]!)"
                
                //Generate event UUID
                eventItem[EventAttributes.eventId.rawValue] = NSUUID().UUIDString
                
                //Generate semi random generated attendeeslist
                eventItem[EventAttributes.attendees.rawValue] = AttendeesGenerator.getSemiRandomGeneratedAttendeesList()
                
                retrievedEvents.append(eventItem)
                */
        
        
        //Call Event API to persist Event list to Datastore
     //   eventAPI.saveEventsList(retrievedEvents)
    }
}
