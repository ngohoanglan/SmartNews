//
//  FeedsViewController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 7/26/17.
//  Copyright © 2017 admin. All rights reserved.
//
import  FBAudienceNetwork
import GoogleMobileAds
import Foundation
import UIKit
import PageMenuKit
class FeedsViewController : BaseViewController,FBInterstitialAdDelegate
    
{  fileprivate var siteController:SiteController!
    fileprivate var siteItemController:SiteItemController!
    fileprivate var  feedDataController=FeedDataController.shareInstance
    var siteSelectedID:String!
    var pageMenuController: PMKPageMenuController? = nil
    fileprivate var siteItemList:Array<SiteItem>=[]
    fileprivate var siteSelected:Site!
    var passOject:UserDefaults!
    var adsBanner: GADBannerView = GADBannerView()
    let setting = Settings()
    var searchResultController: SearchResultController!
    var interstitialAd: FBInterstitialAd!
    override func setup() {
        super.setup()
        
        self.title = "PageMenuKit Frameworks"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        siteController=SiteController.shareInstance
        siteItemController=SiteItemController.shareInstance
        feedDataController=FeedDataController.shareInstance
        passOject=UserDefaults()
        siteSelectedID=passOject.value(forKey: "siteID_key") as! String
        siteSelected=siteController.getSiteById(siteSelectedID as NSString)
        siteItemList=siteItemController.getSiteItemBySiteId(siteSelectedID as NSString)
        
        
        var controllers: [UIViewController] = []
        for item in siteItemList {
            let viewController: DataViewController = DataViewController()
            viewController.title = item.siteItemName
            viewController._siteItemSelected=item
            controllers.append(viewController)
        }
        
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        /*
         * Available menuStyles:
         * .Plain, .Tab, .Smart, .Hacka, .Ellipse, .Web, .Suite, .NetLab, .NHK
         * See PMKPageMenuItem.swift in PageMenuKit folder.
         * "menuColors: []" means that we will use the default colors.
         */
        let kMenuItemWidth=self.view.bounds.size.width
        var my_itemWidth=kMenuItemWidth/CGFloat(controllers.count)
        if(my_itemWidth<120.0)
        {
            my_itemWidth=120.0
        }
        
        
        
        pageMenuController = PMKPageMenuController(controllers: controllers, menuStyle: .Smart, menuColors: [], topBarHeight: 0,kMenuItemWidth: my_itemWidth)
        //    pageMenuController = PMKPageMenuController(controllers: controllers, menuStyle: .Plain, menuColors: [.purple], topBarHeight: statusBarHeight)
        pageMenuController?.delegate = self
        self.addChild(pageMenuController!)
        
        pageMenuController!.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(pageMenuController!.view)
        pageMenuController?.didMove(toParent: self)
        
        self.navigationItem.title=siteSelected.siteName
        
        //SearchBarButton
        searchResultController = SearchResultController()
        
        let tabbaritem=UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(FeedsViewController.searchBarClick))
        
        self.navigationItem.rightBarButtonItem = tabbaritem
        
        
        if(setting.getAdsRemove()==false && setting.getAdHasShow()==false)
        {
            interstitialAd=FBInterstitialAd(placementID: "320895052423142_320897145756266")
            interstitialAd.delegate=self
            interstitialAd.load()
        }
        //FacebookAds
        
        //
        //EndSearchBarButton
        
        //
        
        
        adsBanner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(adsBanner)
        
        
        NSLayoutConstraint(item: pageMenuController!.view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: pageMenuController!.view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: pageMenuController!.view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: pageMenuController!.view, attribute: .centerX, relatedBy: .equal, toItem: adsBanner, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: adsBanner, attribute: .top, relatedBy: .equal, toItem: pageMenuController!.view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: adsBanner, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: adsBanner, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: adsBanner, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
        
        
        
        var backBarButton:UIBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem=backBarButton
        
    }
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        if interstitialAd.isAdValid
        {
            interstitialAd.show(fromRootViewController: self)
            setting.setAdHasShow(true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBar.isHidden = false
        
        //End Ads banner
        
    }
    @objc func searchBarClick() {
        
        self.navigationController?.pushViewController(searchResultController!, animated: true)
    }
}

extension FeedsViewController: PMKPageMenuControllerDelegate
{
    func pageMenuController(_ pageMenuController: PMKPageMenuController, willMoveTo viewController: UIViewController, at menuIndex: Int) {
    }
    
    func pageMenuController(_ pageMenuController: PMKPageMenuController, didMoveTo viewController: UIViewController, at menuIndex: Int) {
    }
    
    func pageMenuController(_ pageMenuController: PMKPageMenuController, didPrepare menuItems: [PMKPageMenuItem]) {
        // XXX: For .Hacka style
        var i: Int = 1
        for item: PMKPageMenuItem in menuItems {
            item.badgeValue = String(format: "%zd", i)
            i += 1
        }
    }
    
    func pageMenuController(_ pageMenuController: PMKPageMenuController, didSelect menuItem: PMKPageMenuItem, at menuIndex: Int) {
        menuItem.badgeValue = nil // XXX: For .Hacka style
    }
    
}
