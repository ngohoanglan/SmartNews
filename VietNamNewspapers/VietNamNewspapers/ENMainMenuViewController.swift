//
//  ENMainMenuViewController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 7/12/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class ENMainMenuViewController: UITableViewController {
    var selectedMenuItem : Int = 0
     var menuItems:[ [String] ] = []
    //var endelegate : ENMySlideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsets.init(top: 80, left: 0, bottom: 0, right: 0) //
     
        //tableView.backgroundColor = UIColor.clearColor()
         tableView.backgroundColor=UIColor.white//UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
        tableView.scrollsToTop = false
        tableView.separatorStyle = .none
       menuItems.append([(NSLocalizedString("add_more_newspaper", comment: "")),"ic_explore"])
        menuItems.append([(NSLocalizedString("favorite_article", comment: "")),"ic_bookmark"])
         menuItems.append([(NSLocalizedString("share_app", comment: "")),"ic_share"])
         menuItems.append([(NSLocalizedString("rate_app", comment: "")),"ic_rate_review"])
         menuItems.append([(NSLocalizedString("contact_us", comment: "")),"ic_contact_mail"])
        /*
        menuItems.append(NSLocalizedString("favorite_article", comment: ""))
        menuItems.append(NSLocalizedString("add_more_newspaper", comment: ""))
        menuItems.append(NSLocalizedString("share_app", comment: ""))
        menuItems.append(NSLocalizedString("rate_app", comment: ""))
        menuItems.append(NSLocalizedString("contact_us", comment: ""))
        */
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.selectRow(at: IndexPath(row: selectedMenuItem, section: 0), animated: false, scrollPosition: .middle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58.0
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.white
            cell!.textLabel?.textColor = UIColor.black
            let selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        let indexRow = (indexPath as NSIndexPath).row
        
        switch indexRow
        {
        case 0:
            cell!.textLabel?.text=menuItems[0][0]
            
            cell?.imageView?.image=UIImage(named: menuItems[0][1])
          
        case 1:
            cell!.textLabel?.text=menuItems[1][0]
            cell?.imageView?.image=UIImage(named: menuItems[1][1])
            
        case 2:
            cell!.textLabel?.text=menuItems[2][0]
            cell?.imageView?.image=UIImage(named: menuItems[2][1])
            
        case 3:
            cell!.textLabel?.text=menuItems[3][0]
            cell?.imageView?.image=UIImage(named: menuItems[3][1])
        
        case 4:
            cell!.textLabel?.text=menuItems[4][0]
            cell?.imageView?.image=UIImage(named: menuItems[4][1])
            
        default:
            cell!.textLabel?.text=menuItems[0][0]
            cell?.imageView?.image=UIImage(named: menuItems[0][1])
        }
        
        cell!.textLabel?.textColor = UIColor.black
        
        return cell!
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       sideMenuController()?.sideMenu?.delegate?.sideMenuIndexSelected!((indexPath as NSIndexPath).row)
        sideMenuController()?.sideMenu?.toggleMenu()
         }
    
    
         // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue!, sender: Any!) {
        
        //sideMenuController()?.sideMenu?.toggleMenu()
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
    
    
}
