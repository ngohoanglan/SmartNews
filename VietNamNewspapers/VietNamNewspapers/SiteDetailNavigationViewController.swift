//
//  SiteDetailNavigationViewController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 7/18/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class SiteDetailNavigationViewController: ENSideMenuNavigationController, ENSideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: ENSiteDetailMenuViewController(), menuPosition:.right)
      
        if(UIDevice.current.userInterfaceIdiom == .phone)
        {
            sideMenu?.menuWidth = UIScreen.main.bounds.size.width-50//290.0 // optional, default is 160
        }
        else
        {
            sideMenu?.menuWidth = 500.0
        }
        //sideMenu?.bouncingEnabled = false
        //sideMenu?.allowPanGesture = false
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
    
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
