//
//  SiteSettingTableViewController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 8/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class SiteSettingTableViewController: UITableViewController {
    var passOject:UserDefaults!
    fileprivate var siteController:SiteController!
    fileprivate var siteItemController:SiteItemController!
    fileprivate var feedDataController:FeedDataController!
    fileprivate var siteItemList:Array<SiteItem>=[]
    fileprivate var siteSelected:Site!
    fileprivate var siteItemSelected:SiteItem!
    var siteSelectedID:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuController()?.sideMenu?.hideSideMenu()
        sideMenuController()?.sideMenu?.allowLeftSwipe=false
        sideMenuController()?.sideMenu?.allowRightSwipe=false
        sideMenuController()?.sideMenu?.allowPanGesture=false
        siteController=SiteController.shareInstance
        siteItemController=SiteItemController.shareInstance
        feedDataController=FeedDataController.shareInstance
        passOject=UserDefaults()
        siteSelectedID=passOject.value(forKey: "siteID_key") as! String
        siteSelected=siteController.getSiteById(siteSelectedID as NSString)
        siteItemList=siteItemController.getSiteItemBySiteId(siteSelectedID as NSString)
        self.isEditing=true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return siteItemList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SiteSettingTableViewCell
        
        // Configure the cell...
        cell.lbSiteItemName.text=siteItemList[(indexPath as NSIndexPath).row].siteItemName
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let siteItemDelete=siteItemList[(indexPath as NSIndexPath).row]
            let mess=String.localizedStringWithFormat(NSLocalizedString("confirm_delete_newspaper", comment: ""), siteItemDelete.siteItemName! )
            let alert = UIAlertController(title: NSLocalizedString("delete_item", comment: ""), message: mess, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
                
                //Delete to Database
                
                self.feedDataController.deleteFeedDataBySiteItemID(siteItemDelete.siteItemID! as NSString)
                self.siteItemController.deleteSiteItem(siteItemDelete)
                
                
                self.siteItemList.remove(at: (indexPath as NSIndexPath).row)
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }))
            
            
            
            
        }
        
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let source=siteItemList[(sourceIndexPath as NSIndexPath).row]
       
        /*
        let destPosition=dest.position
        let sourcePosition=source.position
        
        let newSourceSiteItemUpdate:Dictionary<String,AnyObject>= [SiteItemAttributes.position.rawValue : destPosition!]
        self.siteItemController.updateSiteItem(source, newSiteItemDetails: newSourceSiteItemUpdate)
        let newDestSiteItemUpdate:Dictionary<String,AnyObject>= [SiteItemAttributes.position.rawValue : sourcePosition!]
        self.siteItemController.updateSiteItem(dest, newSiteItemDetails: newDestSiteItemUpdate)
        */
        
        
        siteItemList.remove(at: (sourceIndexPath as NSIndexPath).row)
        siteItemList.insert(source, at: (destinationIndexPath as NSIndexPath).row)
        var index:Int=0
        for siteItem in siteItemList
            
        {
            let newSiteItemUpdate:Dictionary<String,AnyObject> = [SiteItemAttributes.position.rawValue : index as AnyObject]
            self.siteItemController.updateSiteItem(siteItem, newSiteItemDetails: newSiteItemUpdate)

            index=index+1
        }

        
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
