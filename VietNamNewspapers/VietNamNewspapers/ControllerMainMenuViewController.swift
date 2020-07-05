//
//  ControllerMainMenuViewController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 7/12/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class ControllerMainMenuViewController: ENSideMenuNavigationController, ENSideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: ENMainMenuViewController(), menuPosition:.left)
        //sideMenu?.delegate = self //optional
        if(UIDevice.current.userInterfaceIdiom == .phone)
        {
            sideMenu?.menuWidth = 300.0 // optional, default is 160
        }
        else
        {
            sideMenu?.menuWidth = 600.0
        }
        //sideMenu?.bouncingEnabled = false
        //sideMenu?.allowPanGesture = false
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
