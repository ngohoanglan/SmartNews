//
//  SiteItemController.swift
//  VietNamNewspapers
//
//  Created by admin on 2/22/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import CoreData
class SiteItemController {
    
    fileprivate let persistenceManager: PersistenceManager!
    fileprivate var mainContextInstance: NSManagedObjectContext!
    
    class var shareInstance:SiteItemController{
        struct Singleton {
            static let instance=SiteItemController()
        }
        return Singleton.instance
    }
    
    init(){
        self.persistenceManager=PersistenceManager.sharedInstance
        self.mainContextInstance=persistenceManager.getMainContextInstance()
    }
    func saveSiteItem(_ siteItemDetails: Dictionary<String, AnyObject>) {
        
        //Minion Context worker with Private Concurrency type.
        let minionManagedObjectContextWorker:NSManagedObjectContext =
        NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        //Create new Object of Event entity
        let site = NSEntityDescription.insertNewObject(forEntityName: SiteItem.description(),
            into: minionManagedObjectContextWorker) as NSManagedObject
        
        //Assign field values
        for (key, value) in siteItemDetails {
            for attribute in SiteItemAttributes.getAll {
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
    
    func getAllSiteItem(_ sortedByDate:Bool = true, sortAscending:Bool = true) -> Array<SiteItem> {
        var fetchedResults:Array<SiteItem> = Array<SiteItem>()
        
        // Create request on Event entity
       
        let fetchRequest = NSFetchRequest<SiteItem>(entityName: SiteItem.description())
      /*
        let fetchRequest:NSFetchRequest<SiteItem>
        if #available(iOS 10.0, *) {
             fetchRequest = SiteItem.fetchRequest() as! NSFetchRequest<SiteItem>
        } else {
            fetchRequest = NSFetchRequest<SiteItem>(entityName: SiteItem.description())
        }
        */
        
        
        
        //Create sort descriptor to sort retrieved Events by Date, ascending
        if sortedByDate {
            let sortDescriptor = NSSortDescriptor(key: SiteItemAttributes.position.rawValue,
                ascending: sortAscending)
            let sortDescriptors = [sortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        //Execute Fetch request
        do {
           // fetchedResults = try  self.mainContextInstance.fetch(fetchRequest)
             fetchedResults = try  self.mainContextInstance.fetch(fetchRequest)
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<SiteItem>()
        }
        
        return fetchedResults
    }
    func getSiteItemById(_ siteItemId: NSString) -> Array<SiteItem> {
        var fetchedResults:Array<SiteItem> = Array<SiteItem>()
        
        // Create request on Event entity
       let fetchRequest = NSFetchRequest<SiteItem>(entityName: SiteItem.description())
        
        //Add a predicate to filter by eventId
        let findByIdPredicate =
        NSPredicate(format: "\(SiteItemAttributes.siteItemID) = %@", siteItemId)
        fetchRequest.predicate = findByIdPredicate
        
        //Execute Fetch request
        do {
            fetchedResults = try self.mainContextInstance.fetch(fetchRequest) 
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<SiteItem>()
        }
        
        return fetchedResults
    }
    func getSiteItemBySiteId(_ siteId: NSString) -> Array<SiteItem> {
        var fetchedResults:Array<SiteItem> = Array<SiteItem>()
        
        // Create request on Event entity
        let fetchRequest = NSFetchRequest<SiteItem>(entityName: SiteItem.description())
        let sortDescriptor = NSSortDescriptor(key: SiteItemAttributes.position.rawValue,
                                              ascending: true)
        
        //Add a predicate to filter by eventId
        let findByIdPredicate =
        NSPredicate(format: "\(SiteItemAttributes.siteID) = %@", siteId)
        fetchRequest.predicate = findByIdPredicate
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        //Execute Fetch request
        do {
            fetchedResults = try self.mainContextInstance.fetch(fetchRequest) 
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<SiteItem>()
        }
        
        return fetchedResults
    }

    
    func updateSiteItem(_ siteItemToUpdate: SiteItem, newSiteItemDetails: Dictionary<String, AnyObject>){
        
        let minionManagedObjectContextWorker: NSManagedObjectContext =
        NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        //Assign field values
        for (key, value) in newSiteItemDetails {
            for attribute in SiteItemAttributes.getAll {
                if (key == attribute.rawValue) {
                    siteItemToUpdate.setValue(value, forKey: key)
                }
            }
        }
        
        //Persist new Event to datastore (via Managed Object Context Layer).
        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
        self.persistenceManager.mergeWithMainContext()
        
        self.postUpdateNotification()
    }
    func updateResetAllLoadTime()
    {
        
        let minionManagedObjectContextWorker: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        // Create Fetch Request
     
        let entityDescription = NSEntityDescription.entity(forEntityName: SiteItem.description(), in: minionManagedObjectContextWorker)
        
        // Initialize Batch Update Request
        let batchUpdateRequest = NSBatchUpdateRequest(entity: entityDescription!)
        let calendar = Calendar.current
       // let calendar=Calendar(NSGregorianCalendar)
        let loadTime : Date? = (calendar as NSCalendar).date(era: 1, year: 1, month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)
        batchUpdateRequest.propertiesToUpdate = [SiteItemAttributes.loadTime.rawValue: loadTime!]
        
        do {
            // Execute Batch Request
             try minionManagedObjectContextWorker.execute(batchUpdateRequest) as! NSBatchUpdateResult
            
            
            } catch {
                let updateError = error as NSError
                print("\(updateError), \(updateError.userInfo)")
            }
    }
    func deleteSiteItemsBySiteID(_ siteID:NSString)
    {
        let minionManagedObjectContextWorker: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        //Add a predicate to filter by eventId
        let findByIdPredicate =
            NSPredicate(format: "\(SiteItemAttributes.siteID) = %@ ", siteID)
        
        
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<SiteItem>(entityName: SiteItem.description())
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
                let siteItemList=try minionManagedObjectContextWorker.fetch(fetchRequest) as NSArray
                var _:NSManagedObject
                for obj in siteItemList{
                    minionManagedObjectContextWorker.delete(obj as! NSManagedObject)
                    
                }
                try minionManagedObjectContextWorker.save()
            }catch let fetchError as NSError  {
                
                print("retrieveById error: \(fetchError.localizedDescription)")
            }

        }
        
       
    }

    func deleteSiteItem(_ siteItem: SiteItem) {
        //Delete event item from persistance layer
        let minionManagedObjectContextWorker: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        //Add a predicate to filter by eventId
        let findByIdPredicate =
            NSPredicate(format: "\(SiteItemAttributes.siteItemID) = %@ ", siteItem.siteItemID!)
        
        
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<SiteItem>(entityName: SiteItem.description())
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
                let siteItemList=try minionManagedObjectContextWorker.fetch(fetchRequest) as NSArray
                var obj:NSManagedObject
                for obj in siteItemList{
                    minionManagedObjectContextWorker.delete(obj as! NSManagedObject)
                    
                }
                try minionManagedObjectContextWorker.save()
            }catch let fetchError as NSError  {
                
                print("retrieveById error: \(fetchError.localizedDescription)")
            }
        }
        
       
        self.postUpdateNotification()
    }
    func deleteAllSiteItem() {
        //Delete event item from persistance layer
        let minionManagedObjectContextWorker: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        //Add a predicate to filter by eventId
        
        
        
        // Create Fetch Request
       let fetchRequest = NSFetchRequest<SiteItem>(entityName: SiteItem.description())
        
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
                let siteItemList=try minionManagedObjectContextWorker.fetch(fetchRequest) as NSArray
                var obj:NSManagedObject
                for obj in siteItemList{
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
    func IsSiteItemExist(_ url:String) ->Bool
    {
        var isExist:Bool=false
        let allSiteItem=getAllSiteItem()
        for item in allSiteItem
        {
            if (item.siteItemURL == url)
            {
                isExist=true
                break
            }
        }
        return isExist
        
    }

}
