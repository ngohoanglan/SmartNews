//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit

protocol MySlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(index : Int)
}

class MainMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    var menuItems:Array<String>=[]
    @IBOutlet weak var tblTableView: UITableView!
    /**
     *  Array to display menu options
     */
   // @IBOutlet var tblMenuOptions : UITableView!
    
    /**
     *  Transparent button to hide menu
     */
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    /**
     *  Array containing menu options
     */
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
     *  Menu button which was tapped to display the menu
     */
    var btnMenu : UIButton!
    
    /**
     *  Delegate of the MenuVC
     */
    var mydelegate : MySlideMenuDelegate?
     private var panRecognizer : UIPanGestureRecognizer?
    override func viewDidLoad() {
        super.viewDidLoad()
        menuItems.append(NSLocalizedString("search_article", comment: ""))
        menuItems.append(NSLocalizedString("favorite_article", comment: ""))
        menuItems.append(NSLocalizedString("add_more_newspaper", comment: ""))
        menuItems.append(NSLocalizedString("share_app", comment: ""))
        menuItems.append(NSLocalizedString("rate_app", comment: ""))
        menuItems.append(NSLocalizedString("contact_us", comment: ""))
        
        self.tblTableView.tableFooterView = UIView()
        self.tblTableView.delegate=self
        self.tblTableView.dataSource=self
        
         tblTableView.backgroundColor=UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
        // Do any additional setup after loading the view.
        self.panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panRecognizer!.delegate = self
        tblTableView.addGestureRecognizer(panRecognizer!)
    
    }
   
    
    func handlePan(recognizer : UIPanGestureRecognizer) {
      
        
        let leftToRight = recognizer.velocityInView(recognizer.view).x > 0
        
        switch recognizer.state {
        case .Began:
            
            break
            
        case .Changed:
           
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.view.frame = CGRectMake(-UIScreen.mainScreen().bounds.size.width, 0, UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height)
                self.view.layoutIfNeeded()
                self.view.backgroundColor = UIColor.clearColor()
                }, completion: { (finished) -> Void in
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
            })

            break
            default:
            
            break
        }

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
        
        if (self.mydelegate != nil) {
            var index = Int(button.tag)
            if(button == self.btnMenu){
                index = -1
            }
            mydelegate?.slideMenuItemSelectedAtIndex(index)
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
        
        cell.textLabel?.text=menuItems[indexPath.row]
        cell.textLabel?.textColor=UIColor.whiteColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let btn = UIButton(type: UIButtonType.Custom)
        btn.tag = indexPath.row
        self.buttonOverlayMenu(btn)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
}