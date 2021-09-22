//
//  ENSiteDetailMenuViewController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 7/18/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class ENSiteDetailMenuViewController: UITableViewController,UIGestureRecognizerDelegate {
    fileprivate var siteSelected:Site!
    var siteSelectedID:String!
    fileprivate var siteItemList:Array<SiteItem>=[]
    var passOject:UserDefaults!
    fileprivate var siteController:SiteController!
    fileprivate var siteItemController:SiteItemController!
    //fileprivate var feedController:FeedDataController!
     var selectedMenuItem : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        siteController=SiteController.shareInstance
        siteItemController=SiteItemController.shareInstance
        //feedController=FeedDataController.shareInstance
        passOject=UserDefaults()
        siteSelectedID=passOject.value(forKey: "siteID_key") as! String
        siteSelected=siteController.getSiteById(siteSelectedID as NSString)
        siteItemList=siteItemController.getSiteItemBySiteId(siteSelectedID as NSString)
        tableView.reloadData()
        // Do any additional setup after loading the view.
      
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsets.init(top: 64.0, left: 0, bottom: 0, right: 0) //
         tableView.separatorStyle = .singleLine
        //tableView.backgroundColor = UIColor.clearColor()
        tableView.backgroundColor=UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
       
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.selectRow(at: IndexPath(row: selectedMenuItem, section: 0), animated: false, scrollPosition: .middle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView() // The width will be the same as the cell, and the height should be set in tableView:heightForRowAtIndexPath:
        let label = UILabel()
        label.text=siteSelected.siteName
        label.textColor=UIColor.white
        label.font=UIFont.boldSystemFont(ofSize: label.font.pointSize)
        
        let taplbOpenSettingAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ENSiteDetailMenuViewController.taplbOpenSettingAction(_:)))
        label.addGestureRecognizer(taplbOpenSettingAction)
        label.isUserInteractionEnabled=true
        taplbOpenSettingAction.delegate = self // Remember to extend your class with
        
        
        let button   = UIButton(type: UIButton.ButtonType.system)
        button.addTarget(self, action: #selector(ENSiteDetailMenuViewController.openSetting(_:)), for:.touchUpInside)
        label.translatesAutoresizingMaskIntoConstraints=false
        button.translatesAutoresizingMaskIntoConstraints=false
        button.setImage(UIImage(named: "setting"), for: UIControl.State())
        button.tintColor=UIColor.white
        let views = ["label": label,"button":button,"view": view]
        view.addSubview(label)
        view.addSubview(button)
        view.backgroundColor=UIColor(red: 0/255, green: 50/255, blue: 149/255, alpha: 1)
        
        let tapViewOpenSettingAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ENSiteDetailMenuViewController.taplbOpenSettingAction(_:)))
        view.addGestureRecognizer(tapViewOpenSettingAction)
        view.isUserInteractionEnabled=true
        tapViewOpenSettingAction.delegate = self // Remember to extend your class with

       /*
        let horizontallayoutContraints1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[label]-60-[button]-10-|", options: .AlignAllCenterY, metrics: nil, views: views)
        view.addConstraints(horizontallayoutContraints1)
        */
        let horizontallayoutContraints = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        
        view.addConstraint(horizontallayoutContraints)
        
        let settingHorizontalContrains=NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -15.0)
        view.addConstraint(settingHorizontalContrains)
        
        let settingVerticalContrains = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        view.addConstraint(settingVerticalContrains)
        
        let verticalLayoutContraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalLayoutContraint)
        return view
    }
    @objc func openSetting(_ sender:UIButton)
    {
        sideMenuController()?.sideMenu?.delegate?.sideMenuIndexSelected!(-10)
        sideMenuController()?.sideMenu?.hideSideMenu()
        
       // sideMenuController()?.sideMenu?.hideSideMenu()
    }
    @objc func taplbOpenSettingAction(_ gr:UITapGestureRecognizer)
    {
        sideMenuController()?.sideMenu?.delegate?.sideMenuIndexSelected!(-10)
         sideMenuController()?.sideMenu?.hideSideMenu()
      // sideMenuController()?.sideMenu?.toggleMenu()
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    /*
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return siteSelected.siteName
    }*/
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return siteItemList.count
    }
    open func reloadView()
    {
     siteItemList=siteItemController.getSiteItemBySiteId(siteSelectedID as NSString)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       var siteItem = siteItemList[(indexPath as NSIndexPath).row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clear
            cell!.textLabel?.textColor = UIColor.darkGray
            let selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
         let fontSize=(cell?.textLabel?.font.pointSize)
        cell!.textLabel?.text=siteItem.siteItemName
        cell?.textLabel?.font=UIFont.boldSystemFont(ofSize: fontSize!)
        cell!.textLabel?.textColor=UIColor.white
        let fontName=cell?.textLabel?.font.fontName
        let fontSizeDetail=fontSize! - CGFloat(5.0)
        cell!.detailTextLabel?.font=UIFont(name: fontName!, size: fontSizeDetail)
        cell!.detailTextLabel?.textColor=UIColor.white
        cell?.detailTextLabel?.text="ABC"//feedController.getFeedStatusBySiteItemID(siteItem.siteItemID! as NSString)
     cell?.detailTextLabel?.backgroundColor=UIColor(red: 1/255, green: 1/255, blue: 149/255, alpha: 0.1)
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       selectedMenuItem=(indexPath as NSIndexPath).row
        sideMenuController()?.sideMenu?.delegate?.sideMenuIndexSelected!((indexPath as NSIndexPath).row)
        sideMenuController()?.sideMenu?.toggleMenu()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        //sideMenuController()?.sideMenu?.toggleMenu()
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
}


}
