//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(index : Int)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var siteSelected:Site!
    var siteSelectedID:String!
 private var siteItemList:Array<SiteItem>=[]
   var passOject:NSUserDefaults!
    private var siteController:SiteController!
    private var siteItemController:SiteItemController!
    /**
     *  Array to display menu options
     */
   // @IBOutlet var tblMenuOptions : UITableView!
    
    /**
     *  Transparent button to hide menu
     */
    //@IBOutlet var btnCloseMenuOverlay : UIButton!
    
    @IBOutlet weak var tableViewMenu: UITableView!
    @IBOutlet weak var buttonCloseMenu: UIButton!
    /**
     *  Array containing menu options
     */
    
    
   // @IBOutlet weak var tableViewMenuOption: UITableView!
    /**
     *  Menu button which was tapped to display the menu
     */
    var btnMenu : UIButton!
    
    /**
     *  Delegate of the MenuVC
     */
    var delegate : SlideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewMenu.tableFooterView = UIView()
        self.tableViewMenu.delegate=self
        self.tableViewMenu.dataSource=self
        siteController=SiteController.shareInstance
        siteItemController=SiteItemController.shareInstance
        passOject=NSUserDefaults()
        siteSelectedID=passOject.valueForKey("siteID_key") as! String
        siteSelected=siteController.getSiteById(siteSelectedID)
        siteItemList=siteItemController.getSiteItemBySiteId(siteSelectedID)
        // Do any additional setup after loading the view.
        
        tableViewMenu.backgroundColor=UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    
    
    @IBAction func buttonOverlayMenu(button: UIButton) {
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            var index = Int(button.tag)
            if(button == self.btnMenu){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
    
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame = CGRectMake(-UIScreen.mainScreen().bounds.size.width, 0, UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clearColor()
            }, completion: { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })

    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clearColor()
        
        cell.textLabel?.text=siteItemList[indexPath.row].siteItemName!
        cell.textLabel?.textColor=UIColor.whiteColor()
       
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let btn = UIButton(type: UIButtonType.Custom)
        btn.tag = indexPath.row
        self.buttonOverlayMenu(btn)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return siteItemList.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
}