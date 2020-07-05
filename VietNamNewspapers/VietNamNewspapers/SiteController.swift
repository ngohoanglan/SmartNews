//
//  SiteController.swift
//  VietNamNewspapers
//
//  Created by admin on 2/22/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class SiteController {
    
    fileprivate let persistenceManager: PersistenceManager!
    fileprivate var mainContextInstance:NSManagedObjectContext!
    
    class var shareInstance:SiteController{
        struct Singleton {
            static let instance=SiteController()
        }
        return Singleton.instance
    }
    
    init(){
        self.persistenceManager=PersistenceManager.sharedInstance
        self.mainContextInstance=persistenceManager.getMainContextInstance()
    }
    func saveSite(_ siteDetails: Dictionary<String, AnyObject>) {
        
        //Minion Context worker with Private Concurrency type.
        let minionManagedObjectContextWorker:NSManagedObjectContext =
        NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        //Create new Object of Event entity
        let site = NSEntityDescription.insertNewObject(forEntityName: Site.description(),
            into: minionManagedObjectContextWorker) as NSManagedObject
        
        //Assign field values
        for (key, value) in siteDetails {
            for attribute in SiteAttributes.getAll {
                if (key == attribute.rawValue) {
                    site.setValue(value, forKey: key)
                }
            }
        }
        
        
        
        
        //Save current work on Minion workers
        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
        
        //Save and merge changes from Minion workers with Main context
        self.persistenceManager.mergeWithMainContext()
        
        //Post notification to update datasource of a given Viewcontroller/UITableView
        self.postUpdateNotification()
    }

    func getAllSites(_ sortedByDate:Bool = true, sortAscending:Bool = true) -> Array<Site> {
        var fetchedResults:Array<Site> = Array<Site>()
        
        // Create request on Event entity
        let fetchRequest = NSFetchRequest<Site>(entityName: Site.description())
        
        //Create sort descriptor to sort retrieved Events by Date, ascending
        if sortedByDate {
            let sortDescriptor = NSSortDescriptor(key: SiteAttributes.position.rawValue,
                ascending: sortAscending)
            let sortDescriptors = [sortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        //Execute Fetch request
        do {
            fetchedResults = try  self.mainContextInstance.fetch(fetchRequest) 
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<Site>()
        }
        
        return fetchedResults
    }
    func getAllSitesByCountry(_ countryCode:String) -> Array<Site> {
        var fetchedResults:Array<Site> = Array<Site>()
        
        // Create request on Event entity
        let fetchRequest = NSFetchRequest<Site>(entityName: Site.description())
        //Add a predicate to filter by eventId
        let findByIdPredicate =
            NSPredicate(format: "\(SiteAttributes.countryCode) = %@", countryCode)
        fetchRequest.predicate = findByIdPredicate
        

        
        
        //Execute Fetch request
        do {
            fetchedResults = try  self.mainContextInstance.fetch(fetchRequest) 
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<Site>()
        }
        
        return fetchedResults
    }

    func getSiteMaxPosition() -> Int
    {
        var max:Int=0
        let allSite=getAllSites()
        for site in allSite
        {
            if site.position?.intValue > max
            {
                max=(site.position?.intValue)!
            }
        }
        return max
    }
    func IsSiteExist(_ url:String, name:String) ->Bool
    {
        var isExist:Bool=false
        let allSite=getAllSites()
        for site in allSite
        {
            if (site.siteURL == url || site.siteName == name)
            {
                isExist=true
                break
            }
        }
        return isExist
    
    }
    func getSiteById(_ siteId: NSString) -> Site {
        var fetchedResults:Array<Site> = Array<Site>()
        
        // Create request on Event entity
        let fetchRequest = NSFetchRequest<Site>(entityName: Site.description())
        
        //Add a predicate to filter by eventId
        let findByIdPredicate =
        NSPredicate(format: "\(SiteAttributes.siteID) = %@", siteId)
        fetchRequest.predicate = findByIdPredicate
        
        //Execute Fetch request
        do {
            fetchedResults = try self.mainContextInstance.fetch(fetchRequest) 
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<Site>()
        }
        
        return fetchedResults.first!
    }
    
    func getSiteByURL(_ siteURL: String) -> Site {
        var fetchedResults:Array<Site> = Array<Site>()
        
        // Create request on Event entity
        let fetchRequest = NSFetchRequest<Site>(entityName: Site.description())
        
        //Add a predicate to filter by eventId
        let findByIdPredicate =
            NSPredicate(format: "\(SiteAttributes.siteURL) = %@", siteURL)
        fetchRequest.predicate = findByIdPredicate
        
        //Execute Fetch request
        do {
            fetchedResults = try self.mainContextInstance.fetch(fetchRequest) 
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<Site>()
        }
        
        return fetchedResults.first!
    }
    func updateSiteAfterUpdate(countryCode:String)
    {
        var countryCodeValue:String = ""
        let minionManagedObjectContextWorker: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        // Create Fetch Request
        
        let entityDescription = NSEntityDescription.entity(forEntityName: Site.description(), in: minionManagedObjectContextWorker)
        
        // Initialize Batch Update Request
        let batchUpdateRequest = NSBatchUpdateRequest(entity: entityDescription!)
        
        batchUpdateRequest.propertiesToUpdate = [SiteAttributes.countryCode.rawValue: countryCode]
        
        
        //Add a predicate to filter by eventId
        let findByIdPredicate =
            NSPredicate(format: "\(SiteAttributes.countryCode) = nil")
        batchUpdateRequest.predicate = findByIdPredicate
        
        do {
            // Execute Batch Request
            try minionManagedObjectContextWorker.execute(batchUpdateRequest) as! NSBatchUpdateResult
            
            
        } catch {
            let updateError = error as NSError
            print("\(updateError), \(updateError.userInfo)")
        }
    }

    func updateSite(_ siteToUpdate: Site, newSiteDetails: Dictionary<String, AnyObject>){
        
        let minionManagedObjectContextWorker:NSManagedObjectContext =
        NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        //Assign field values
        for (key, value) in newSiteDetails {
            for attribute in SiteAttributes.getAll {
                if (key == attribute.rawValue) {
                    siteToUpdate.setValue(value, forKey: key)
                }
            }
        }
        
        //Persist new Event to datastore (via Managed Object Context Layer).
        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
        self.persistenceManager.mergeWithMainContext()
        
        self.postUpdateNotification()
    }
    func deleteSiteByURL(_ siteURL: String) {
        //Delete event item from persistance layer
        let minionManagedObjectContextWorker: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        //Add a predicate to filter by eventId
        let findByIdPredicate =
            NSPredicate(format: "\(SiteAttributes.siteURL) = %@ ", siteURL)
        
        
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<Site>(entityName: Site.description())
        fetchRequest.predicate = findByIdPredicate
        // Create Batch Delete Request
        if #available(iOS 9.0, *) {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            do {
                try minionManagedObjectContextWorker.execute(batchDeleteRequest)
                
            } catch let fetchError as NSError  {
                
                print("retrieveById error: \(fetchError.localizedDescription)")
            }
        } else {
            // Fallback on earlier versions
            do{
                var siteList=try minionManagedObjectContextWorker.fetch(fetchRequest) as NSArray
                var obj:NSManagedObject
                for obj in siteList{
                    minionManagedObjectContextWorker.delete(obj as! NSManagedObject)
                    
                }
                try minionManagedObjectContextWorker.save()
            }catch let fetchError as NSError  {
                
                print("retrieveById error: \(fetchError.localizedDescription)")
            }
        }
        
        
        
        self.postUpdateNotification()
    }
    func deleteSite(_ site: Site) {
        //Delete event item from persistance layer
        let minionManagedObjectContextWorker: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        //Add a predicate to filter by eventId
        let findByIdPredicate =
            NSPredicate(format: "\(SiteAttributes.siteID) = %@ ", site.siteID!)
        
        
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<Site>(entityName: Site.description())
        fetchRequest.predicate = findByIdPredicate
        // Create Batch Delete Request
        if #available(iOS 9.0, *) {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            do {
                try minionManagedObjectContextWorker.execute(batchDeleteRequest)
                
            } catch let fetchError as NSError  {
                
                print("retrieveById error: \(fetchError.localizedDescription)")
            }
        } else {
            // Fallback on earlier versions
            do{
                var siteList=try minionManagedObjectContextWorker.fetch(fetchRequest) as NSArray
                var obj:NSManagedObject
                for obj in siteList{
                    minionManagedObjectContextWorker.delete(obj as! NSManagedObject)
                    
                }
                try minionManagedObjectContextWorker.save()
            }catch let fetchError as NSError  {
                
                print("retrieveById error: \(fetchError.localizedDescription)")
            }
        }
        
       
        
        self.postUpdateNotification()
    }
    func deleteAllSite() {
        //Delete event item from persistance layer
        let minionManagedObjectContextWorker: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        
        
        
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<Site>(entityName: Site.description())
     
        // Create Batch Delete Request
        if #available(iOS 9.0, *) {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            do {
                try minionManagedObjectContextWorker.execute(batchDeleteRequest)
                
            } catch let fetchError as NSError  {
                
                print("retrieveById error: \(fetchError.localizedDescription)")
            }
        } else {
            // Fallback on earlier versions
            do{
                var siteList=try minionManagedObjectContextWorker.fetch(fetchRequest) as NSArray
                var obj:NSManagedObject
                for obj in siteList{
                    minionManagedObjectContextWorker.delete(obj as! NSManagedObject)
                    
                }
                try minionManagedObjectContextWorker.save()
            }catch let fetchError as NSError  {
                
                print("retrieveById error: \(fetchError.localizedDescription)")
            }
        }
        
        
        
        self.postUpdateNotification()
    }
    fileprivate func postUpdateNotification(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSiteTableData"), object: nil)
    }
}
