//
//  SiteDetailTableViewController.swift
//  VietNamNewspapers
//
//  Created by admin on 4/4/16.
//  Copyright © 2016 admin. All rights reserved.
//
//import ImageLoader
import GoogleMobileAds
import UIKit
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


class SiteDetailTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating
,ENSideMenuDelegate, UISearchBarDelegate ,UIGestureRecognizerDelegate,GADInterstitialDelegate{
    var shouldShowSearchResults = false
    var searchController: UISearchController = ({
        
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.searchBarStyle = .minimal
        controller.searchBar.sizeToFit()
        return controller
    })()
    
   
   // @IBOutlet weak var constrainTableTopAdmob: NSLayoutConstraint!
    
    //  @IBOutlet weak var constrainTableTop: NSLayoutConstraint!
    //  @IBOutlet weak var constrainadmobHeight: NSLayoutConstraint!
    @IBOutlet weak var btnShowMenu: UIBarButtonItem!
   
    //@IBOutlet weak var adsBanner: GADBannerView!
    @IBOutlet weak var adsBannerConstraintHeight: NSLayoutConstraint!
     @IBOutlet weak var adsBanner: GADBannerView!
    @IBOutlet weak var barBack: UIBarButtonItem!
    fileprivate var httpClient:HTTPClient!
    @IBOutlet weak var tableViewFeedList: UITableView!
    var passOject:UserDefaults!
    fileprivate var siteController:SiteController!
    fileprivate var siteItemController:SiteItemController!
    fileprivate var feedDataController:FeedDataController!
    fileprivate var feedDataList:Array<FeedData>=[]
    fileprivate var feedDataFilteredList:Array<FeedData>=[]
    fileprivate var siteItemList:Array<SiteItem>=[]
    fileprivate var siteSelected:Site!
    fileprivate var siteItemSelected:SiteItem!
    fileprivate var previousSiteItem:SiteItem!
    var siteSelectedID:String!
    let refreshControl = UIRefreshControl()
    let indicator=UIActivityIndicatorView(style: .gray)
    var rightBarItem:UIBarButtonItem=UIBarButtonItem()
    var leftBarItem:UIBarButtonItem=UIBarButtonItem()
    var verticalPostionContent:CGFloat=0
    let setting = Settings()
    var selectedMenuItem:Int=0
    var isDownloadImage:Bool=true
    var textSize:CGFloat=0.0
    var isExpandDescription:Bool=false
    //var runAppCount:Int=0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adsBannerConstraintHeight.constant=0.0
        
        tableViewFeedList.estimatedRowHeight = 154
        tableViewFeedList.rowHeight = UITableView.automaticDimension
        self.setup()
        
       
        isDownloadImage=setting.getBlockImage()
        isExpandDescription=setting.getExpandDescription()
        textSize=CGFloat(setting.getTextSize())
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(SiteDetailTableViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(SiteDetailTableViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        
        passOject=UserDefaults()
        siteSelectedID=passOject.value(forKey: "siteID_key") as! String
        siteSelected=siteController.getSiteById(siteSelectedID as NSString)
        siteItemList=siteItemController.getSiteItemBySiteId(siteSelectedID as NSString)
        
        siteItemSelected=siteItemList[0]
        
        self.navigationItem.title=siteItemSelected.siteItemName
        self.tableViewFeedList.delegate=self
        self.tableViewFeedList.dataSource=self
        
        if(UIDevice.current.userInterfaceIdiom == .phone)
        {
            self.navigationItem.titleView=searchController.searchBar
        }
        else //iPad
        {
            searchController.searchBar.showsCancelButton=true
            let uiViewSearchBar=UIView()
            uiViewSearchBar.frame=searchController.searchBar.bounds
            uiViewSearchBar.addSubview(searchController.searchBar)
            navigationItem.titleView=uiViewSearchBar
        }
        searchController.searchBar.delegate=self
        searchController.searchResultsUpdater=self
        self.searchController.searchBar.placeholder=siteItemSelected.siteItemName
        
        refreshControl.addTarget(self, action: #selector(SiteDetailTableViewController.refreshControlAction(_:)), for: UIControl.Event.valueChanged)
        self.tableViewFeedList.insertSubview(refreshControl, at: 0)
        
        rightBarItem=self.navigationItem.rightBarButtonItem!
        leftBarItem=self.navigationItem.leftBarButtonItem!
        
        self.sideMenuController()?.sideMenu?.delegate = self
        self.sideMenuController()?.sideMenu?.allowLeftSwipe=false
        self.sideMenuController()?.sideMenu?.allowRightSwipe=false
        
        
        if(setting.getShowAds())
        {
            
            if(setting.getAdsType() == Settings.AdsType.Interestial.rawValue){
                adsBannerConstraintHeight.constant=0.0
            let App = UIApplication.shared.delegate as! AppDelegate
            if(App.hasShowAds==false)
            {
                App.gViewController = self;
                App.showAdmobInterstitial(kGoogleFullScreenAppUnitID: setting.getAdmobKey())
            }
            }
            else if(setting.getAdsType() == Settings.AdsType.Banner.rawValue){
                adsBannerConstraintHeight.constant=50.0
                adsBanner.adUnitID = setting.getAdmobKey()
                adsBanner.rootViewController = self
                adsBanner.load(GADRequest())
            }
            
            
        }
    }
    
    override  func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        /* Smart Banner Ads
         switch UIDevice.currentDevice().orientation{
         case .Portrait:
         if(runAppCount>2 && setting.getAdsRemove()==false){
         
         constrainTableTopAdmob.constant=50.0
         constrainadmobHeight.constant=50.0
         admobBanner.adSize=kGADAdSizeSmartBannerPortrait
         }
         case .LandscapeLeft:
         
         constrainTableTopAdmob.constant=0.0
         constrainadmobHeight.constant=0.0
         
         case .LandscapeRight:
         constrainTableTopAdmob.constant=0.0
         constrainadmobHeight.constant=0.0
         default:
         constrainTableTopAdmob.constant=0.0
         constrainadmobHeight.constant=0.0
         break
         
         }*/
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            let index:Int=siteItemList.firstIndex(of: siteItemSelected)!
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                if(index<siteItemList.count-1)
                {
                    siteItemSelected=siteItemList[index+1]
                    self.searchController.searchBar.placeholder=siteItemSelected.siteItemName
                    SelectionChange(siteItemSelected, autoFreshing: false, isError: false)
                    
                }
                else
                {
                    toggleSideMenuView()
                }
                
            case UISwipeGestureRecognizer.Direction.right:
                
                if(index>0)
                {
                    siteItemSelected=siteItemList[index-1]
                    self.searchController.searchBar.placeholder=siteItemSelected.siteItemName
                    SelectionChange(siteItemSelected, autoFreshing: false, isError: false)
                }
                else
                {
                    toggleSideMenuView()
                }
            default:
                break
            }
        }
    }
    
    //Begin Search Bar
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.navigationItem.rightBarButtonItem=nil
        self.navigationItem.leftBarButtonItem=nil
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        // tableViewFeedList.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.navigationItem.rightBarButtonItem=rightBarItem
        self.navigationItem.leftBarButtonItem=leftBarItem
        shouldShowSearchResults = false
        tableViewFeedList.reloadData()
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableViewFeedList.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        
        feedDataFilteredList = feedDataList.filter() {
            return ($0.title!.lowercased().range(of: (searchString?.lowercased())!) != nil || $0.feedDescription!.lowercased().range(of: (searchString?.lowercased())!) != nil)
        }
        
        // Reload the tableview.
        tableViewFeedList.reloadData()
    }
    
    //End Search Bar
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        SelectionChange(siteItemSelected, autoFreshing: true, isError: false)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        siteItemList=siteItemController.getSiteItemBySiteId(siteSelectedID as NSString)
        self.tableViewFeedList.estimatedRowHeight = 100.0
        self.tableViewFeedList.rowHeight = UITableView.automaticDimension
        SelectionChange(siteItemSelected, autoFreshing: false, isError: false)
    }
    
    @IBAction func btnShowMenu(_ sender: UIButton) {
        
        toggleSideMenuView()
        
    }
    fileprivate func setup(){
        siteController=SiteController.shareInstance
        siteItemController=SiteItemController.shareInstance
        feedDataController=FeedDataController.shareInstance
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if shouldShowSearchResults{
            return feedDataFilteredList.count
        }
        else
        {
            return feedDataList.count
        }
        
    }
    var btnExpandTapped:Bool=false
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var feedData:FeedData
        if shouldShowSearchResults
        {
            feedData=feedDataFilteredList[(indexPath as NSIndexPath).row]
        }
        else{
            feedData=feedDataList[(indexPath as NSIndexPath).row]
        }
        
        if(!btnExpandTapped)
        {
            feedData.isExpand=isExpandDescription
        }
        
        
        if(feedData.linkImage?.count>10 && isDownloadImage==true)
        {
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellNotDesc", for: indexPath)
                as! FeedNotDescriptionViewCell
            if(feedData.imageArray?.count>0)
            {
                cell.feedImageCell.image=UIImage(data: feedData.imageArray! as Data)
            }
            else
            {
                
                //
                cell.feedImageCell.image=nil
                //
                /* lan.nh
                cell.feedImageCell.load.request(with: feedData.linkImage!, onCompletion: { image, error, operation in
                    print("image \(image?.size), render-image \(cell.feedImageCell.image?.size)")
                    if operation == .network {
                        let myImage : UIImage = Utils.resizeImage(image!, maxWidth: 75, maxHeight: 75)
                        let transition = CATransition()
                        transition.duration = 0.5
                        transition.type = kCATransitionFade
                        cell.feedImageCell.layer.add(transition, forKey: nil)
                        cell.feedImageCell.image = myImage
                        
                         feedData.imageArray=UIImagePNGRepresentation(myImage)
                        let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.imageArray.rawValue : feedData.imageArray! as AnyObject]
                        self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
                    }
                })
                */
                /*
                let myCompletionHandler: (URL?, UIImage?, NSError?,CacheType?) -> Void = { (data, response, error,cachtype) in
                    // this is where the completion handler code goes
                    if response != nil{
                        //convert NSData->Image
                        let image : UIImage = Utils.resizeImage(response!, maxWidth: 75, maxHeight: 75)
                        // let image : UIImage = self.RBSquareImageTo(response!, size: CGSize(width: 90, height: 90))
                        feedData.imageArray=UIImagePNGRepresentation(image)
                        let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.imageArray.rawValue : feedData.imageArray! as AnyObject]
                        self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
                    }
                }
                cell.feedImageCell.load(feedData.linkImage!, placeholder: cell.feedImageCell.image, completionHandler: myCompletionHandler)*/
            }
            
            if(feedData.isRead==1)
            {
                
                cell.lbTitleCell.font = UIFont.systemFont(ofSize: textSize)
            }
            else
            {
                cell.lbTitleCell.font = UIFont.boldSystemFont(ofSize: textSize)
            }
            cell.lbTitleCell.text=feedData.title
            // cell.lbDescription.text=feedData.feedDescription
            cell.lbDescription.font=UIFont.systemFont(ofSize: textSize-2)
            cell.lbPubdate.text=feedData.pubDateString
            if(!feedData.isExpand )
            {
                let image = UIImage(named: "expand") as UIImage?
                cell.btnExpand.setImage(image, for: UIControl.State())
                //cell.csDescriptionHeight.constant=0.0
                cell.lbDescription.text=""
            }
            else
            {
                let image = UIImage(named: "collpase") as UIImage?
                cell.btnExpand.setImage(image, for: UIControl.State())
                //cell.csDescriptionHeight.constant=70.0
                cell.lbDescription.text=feedData.feedDescription
            }
            
            cell.btnExpandTapped = {
                self.btnExpandTapped=true
                if(!feedData.isExpand)
                {
                    feedData.isExpand = true
                    // cell.csDescriptionHeight.constant=70.0
                }
                else
                {
                    feedData.isExpand = false
                    //cell.csDescriptionHeight.constant=0.0
                }
                let indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                self.tableViewFeedList.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            }
            cell.btnShareTapped =
                {
                    if let name = URL(string: feedData.link!) {
                        let objectsToShare = [name]
                        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        
                        self.present(activityVC, animated: true, completion: nil)
                    }
            }
            if(feedData.isFavorite == 1)
            {
                let image = UIImage(named: "importan") as UIImage?
                cell.btImportan.setImage(image, for: UIControl.State())
            }
            else
            {
                let image = UIImage(named: "not_importan") as UIImage?
                cell.btImportan.setImage(image, for: UIControl.State())
            }
            cell.btnImportanTapped =
                {
                    if(feedData.isFavorite == 1)
                    {
                        let image = UIImage(named: "not_importan") as UIImage?
                        cell.btImportan.setImage(image, for: UIControl.State())
                        feedData.isFavorite=0
                    }
                    else
                    {
                        let image = UIImage(named: "importan") as UIImage?
                        cell.btImportan.setImage(image, for: UIControl.State())
                        feedData.isFavorite=1
                    }
                    let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.isFavorite.rawValue : feedData.isFavorite!]
                    self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
                    let indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                    self.tableViewFeedList.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            }
            
            
            let taplabeTitlelAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SiteDetailTableViewController.labeTitlelAction(_:)))
            cell.lbTitleCell.addGestureRecognizer(taplabeTitlelAction)
            cell.lbTitleCell.tag=(indexPath as NSIndexPath).row
            cell.lbTitleCell.isUserInteractionEnabled=true
            taplabeTitlelAction.delegate = self // Remember to extend your class with UIGestureRecognizerDelegate
            
            let taplabeDesciptionAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SiteDetailTableViewController.labeTitlelAction(_:)))
            cell.lbDescription.addGestureRecognizer(taplabeDesciptionAction)
            cell.lbDescription.tag=(indexPath as NSIndexPath).row
            cell.lbDescription.isUserInteractionEnabled=true
            taplabeDesciptionAction.delegate = self // Remember to extend your class with UIGestureRecognizerDelegate
            
            return cell
        }
            
        else
        {
            let cellNotImage = tableView.dequeueReusableCell(withIdentifier: "CellNotImage", for: indexPath)
                as! FeedDataTableViewCell
            if(feedData.isRead==1)
            {
                cellNotImage.lbTitle.font = UIFont.systemFont(ofSize: textSize)
            }
            else
            {
                cellNotImage.lbTitle.font = UIFont.boldSystemFont(ofSize: textSize)
            }
            cellNotImage.lbTitle.text=feedData.title
            //cellNotImage.lbDescription.text=feedData.feedDescription
            cellNotImage.lbDescription.font=UIFont.systemFont(ofSize: textSize-2)
            cellNotImage.lbPubDate.text=feedData.pubDateString
            
            //
            if(!feedData.isExpand)
            {
                let image = UIImage(named: "expand") as UIImage?
                cellNotImage.btnExpand.setImage(image, for: UIControl.State())
                //  cellNotImage.csHeightDescription.constant=0.0
                cellNotImage.lbDescription.text = ""
            }
            else
            {
                let image = UIImage(named: "collpase") as UIImage?
                cellNotImage.btnExpand.setImage(image, for: UIControl.State())
                //cellNotImage.csHeightDescription.constant=70.0
                cellNotImage.lbDescription.text = feedData.feedDescription
                
            }
            cellNotImage.btnExpandTapped = {
                self.btnExpandTapped=true
                if(!feedData.isExpand)
                {
                    feedData.isExpand = true
                    //  cellNotImage.csHeightDescription.constant=70.0
                }
                else
                {
                    feedData.isExpand = false
                    // cellNotImage.csHeightDescription.constant=0.0
                }
                let indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                self.tableViewFeedList.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            }
            cellNotImage.btnShareTapped =
                {
                    
                    if let name = URL(string: feedData.link!) {
                        let objectsToShare = [name]
                        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
                        {
                            if ( activityVC.responds(to: #selector(getter: UIViewController.popoverPresentationController)) ) {
                                activityVC.popoverPresentationController?.sourceView = cellNotImage.btnShare
                            }
                        }
                        self.present(activityVC, animated: true, completion: nil)
                    }
                    
                    
                    
            }
            if(feedData.isFavorite == 1)
            {
                let image = UIImage(named: "importan") as UIImage?
                cellNotImage.btnImportan.setImage(image, for: UIControl.State())
            }
            else
            {
                let image = UIImage(named: "not_importan") as UIImage?
                cellNotImage.btnImportan.setImage(image, for: UIControl.State())
            }
            cellNotImage.btnImportanTapped =
                {
                    if(feedData.isFavorite == 1)
                    {
                        let image = UIImage(named: "not_importan") as UIImage?
                        cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                        feedData.isFavorite=0
                    }
                    else
                    {
                        let image = UIImage(named: "importan") as UIImage?
                        cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                        feedData.isFavorite=1
                    }
                    let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.isFavorite.rawValue : feedData.isFavorite!]
                    self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
                    let indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                    self.tableViewFeedList.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            }
            
            //
            let taplabeTitlelAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SiteDetailTableViewController.labeTitlelAction(_:)))
            cellNotImage.lbTitle.addGestureRecognizer(taplabeTitlelAction)
            cellNotImage.lbTitle.tag=(indexPath as NSIndexPath).row
            cellNotImage.lbTitle.isUserInteractionEnabled=true
            taplabeTitlelAction.delegate = self // Remember to extend your class with UIGestureRecognizerDelegate
            
            let taplabeDesciptionAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SiteDetailTableViewController.labeTitlelAction(_:)))
            cellNotImage.lbDescription.addGestureRecognizer(taplabeDesciptionAction)
            cellNotImage.lbDescription.tag=(indexPath as NSIndexPath).row
            cellNotImage.lbDescription.isUserInteractionEnabled=true
            taplabeDesciptionAction.delegate = self // Remember to extend your class with UIGestureRecognizerDelegate
            
            
            return cellNotImage
            
            
        }
        
    }
    @objc func labeTitlelAction(_ gr:UITapGestureRecognizer)
    {
        
        
        openWebView(gr.view?.tag)
        
    }
    func openWebView(_ tag:Int!)
    {
        var feedData:FeedData
        
        if shouldShowSearchResults
        {
            feedData=feedDataFilteredList[tag]
        }
        else{
            feedData=feedDataList[tag]
        }
        feedData.isRead=1
        let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.isRead.rawValue : feedData.isRead!]
        self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
        let indexPath=IndexPath(item: tag, section: 0)
        self.tableViewFeedList.reloadRows(at: [indexPath], with: .none)
        let url=feedData.link
        
        
        let nsUrl=URL(string: url!)
         UIApplication.shared.openURL(nsUrl!)
         
    
        /*
        if((url?.contains("bild.de")) == true )
        {
            
            let nsUrl=URL(string: url!)
            UIApplication.shared.openURL(nsUrl!)
            
        }
        else
        {
            let mapViewControllerObj = self.storyboard!.instantiateViewController(withIdentifier: "storyboardWebView") as! WebViewViewController
            passOject.set(feedData.link, forKey: "feed_url_key")
            passOject.set(siteItemSelected.siteItemName, forKey: "siteItemName_key")
            sideMenuController()?.sideMenu?.menuViewController.viewDidLoad()
            self.navigationController?.pushViewController(mapViewControllerObj, animated: true)
        }
         */
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier=="segueSiteDetail"
        {
            passOject.set(0, forKey: "contentOffsettableViewFeedList_key")
        }
        else
        {
            passOject.set(tableViewFeedList.contentOffset.y, forKey: "contentOffsettableViewFeedList_key")
        }
    }
    fileprivate func SelectionChange(_ siteItem:SiteItem, autoFreshing:Bool, isError:Bool)
    {
        if(siteItem.siteItemURL?.contains("http"))!
        {
            siteItem.siteItemURL=Utils.enCryptString2(siteItem.siteItemURL!)
        }
        
        self.tableViewFeedList.tableHeaderView=nil
        feedDataList=feedDataController.getFeedDataBySiteItemId(siteItem.siteItemID! as NSString)
        //
        self.tableViewFeedList.reloadData()
        
        let currentTimeAdded=(Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.minute, value: -2, to: Date(), options: NSCalendar.Options.init(rawValue: 0))
        if(siteItem.loadTime == nil || autoFreshing || siteItem.loadTime?.compare(currentTimeAdded!)==ComparisonResult.orderedAscending)
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            indicator.center=view.center
            indicator.hidesWhenStopped=true
            indicator.startAnimating()
            view.addSubview(indicator)
            httpClient=HTTPClient()
            var urlString:String
            let currentTime=Date()
            
            //FeedEncoding
            if(siteItem.encoding?.isEmpty==true||siteItem.encoding==nil)
            {
                urlString=Utils.deCryptString2(siteItem.siteItemURL!)
                
            }
            else
            {
                
                let HOST_API = "http://thealllatestnews.com/api/home/"
                // let urlEncrypted=enCryptString(siteItem.siteItemURL!)
                urlString=HOST_API+siteItem.siteItemURL!+"/"+siteItem.encoding!
            }
            if(siteItem.isFavorite==1 || isError)
            {
                var encoding="UTF-8"
                let HOST_API = "http://thealllatestnews.com/api/home/"
                if(siteItem.encoding != nil)
                {
                    encoding=siteItem.encoding!
                }
                urlString=HOST_API+siteItem.siteItemURL!+"/"+encoding
            }
            var request:URLRequest = URLRequest(url: URL(string: urlString)!)
            request.setValue("application/json, text/html, application/xhtml+xml, */*", forHTTPHeaderField: "Accept")
            request.setValue("Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)", forHTTPHeaderField: "User-Agent")
            
            
            self.httpClient.doGet(request) { (data, error, httpStatusCode) -> Void in
                if (httpStatusCode == nil || httpStatusCode!.rawValue != HTTPStatusCode.ok.rawValue)
                {
                    if(isError)
                    {
                        self.DownloadError(autoFreshing)
                    }
                    else
                    {
                        self.SelectionChange(siteItem, autoFreshing: false, isError: true)
                    }
                }
                    
                else {
                    //Read JSON response in seperate thread
                    DispatchQueue.global(qos: .userInitiated).async(execute: {
                        
                        
                        let newSiteItemUpdate:Dictionary<String,AnyObject> = [SiteItemAttributes.loadTime.rawValue : currentTime as AnyObject]
                        self.siteItemController.updateSiteItem(siteItem, newSiteItemDetails: newSiteItemUpdate)
                        
                        var feedXML=NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                        feedXML = Utils.RemoveHTMLTagsAndSymbols(feedXML)
                        
                        
                        //Encoding
                        let contentEncoding = feedXML.subStringFromTwoTag("<?xml", endTag: ">")
                        // var isUTF8Encoding=self.checkUFT8Encoding(contentEncoding)
                        if( siteItem.encoding?.isEmpty==false && siteItem.encoding != nil && Utils.checkUFT8Encoding(contentEncoding)==true )
                        {
                            
                            let newSiteItemUpdate:Dictionary<String,AnyObject> = [SiteItemAttributes.encoding.rawValue : "" as AnyObject]
                            self.siteItemController.updateSiteItem(siteItem, newSiteItemDetails: newSiteItemUpdate)
                            
                            
                        }
                        
                        if (feedXML.contains("<rss") || feedXML.contains("<rdf:RDF"))
                        {
                            let startTag="<item"
                            let endTag="</item>"
                            
                            var content = feedXML.subStringFromTwoTag(startTag, endTag: endTag)
                            
                            while(!content.isEmpty && content != "")
                            {
                                if(feedXML.contains("<authors>") && feedXML.contains("</authors>"))
                                {
                                    let authors=feedXML.subStringFromTwoTag("<authors>", endTag: "</authors>")
                                    feedXML=feedXML.replacingOccurrences(of: authors, with: "")
                                }
                                
                                content=feedXML.subStringFromTwoTag(startTag, endTag: endTag)
                                
                                //title
                                var feedTitle=content.subStringFromTwoTag("<title>", endTag: "</title>")
                                if(feedTitle.contains("<![CDATA["))
                                {
                                    feedTitle=feedTitle.subStringFromTwoTag("<![CDATA[", endTag: "]]>")
                                }
                                
                                //link
                                var feedLink=content.subStringFromTwoTag("<link>", endTag: "</link>")
                                if(feedLink.contains("<![CDATA["))
                                {
                                    feedLink=feedLink.subStringFromTwoTag("<![CDATA[", endTag: "]]>")
                                }
                                if(feedLink.isEmpty)
                                {
                                    feedLink=content.subStringFromTwoTag("<guid>", endTag: "</guid>")
                                }
                                
                                if(feedLink.isEmpty)
                                {
                                    if(feedLink.contains("<![CDATA["))
                                    {
                                        feedLink=feedLink.subStringFromTwoTag("<![CDATA[", endTag: "]]>")
                                    }
                                }
                                if(feedLink.isEmpty)
                                {
                                    var matched=feedLink.matchesForRegexInText("href=\"([^']*)\"", text: content)
                                    if matched.count>0
                                    {
                                        feedLink=matched[0]
                                    }
                                    feedLink=feedLink.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "href=", with: "")
                                    feedLink=feedLink.trimmingCharacters(in: CharacterSet.whitespaces)
                                    
                                }
                                feedLink=feedLink.trimmingCharacters(in: CharacterSet.whitespaces)
                                //pubdate
                                var pubDateString=content.subStringFromTwoTag("<pubDate>", endTag: "</pubDate>")
                                if(pubDateString.contains("<![CDATA["))
                                {
                                    pubDateString=pubDateString.subStringFromTwoTag("<![CDATA[", endTag: "]]>")
                                }
                                var imgFeed=content.subStringFromTwoTag("<enclosure>", endTag: "</enclosure>")
                                if(imgFeed.isEmpty)
                                {
                                    imgFeed=content.subStringFromTwoTag("<media:thumbnail>", endTag: "</media:thumbnail>")
                                    
                                }
                                var feedDescription=content.subStringFromTwoTag("<description>", endTag: "</description>")
                                if(feedDescription.contains("[CDATA["))
                                {
                                    if(imgFeed.isEmpty)
                                    {
                                        var imgLinks = feedDescription.matchesForRegexInText("(http://[^\\s]+(.jpg|.png))", text: feedDescription)
                                        if(imgLinks.count>0)
                                        {
                                            imgFeed=imgLinks[0]
                                        }
                                    }
                                    
                                    feedDescription=feedDescription.subStringFromTwoTag("[CDATA[", endTag: "]]")
                                }
                                if(imgFeed=="" || imgFeed.contains("http")==false)
                                {
                                    var imgLinks = feedDescription.matchesForRegexInText("(http://[^\\s]+(.jpg|.png))", text: content)
                                    if(imgLinks.count>0)
                                    {
                                        imgFeed=imgLinks[0]
                                    }
                                    else
                                    {
                                        
                                        var imgLinks = feedDescription.matchesForRegexInText("\\s*(?i)src\\s*=\\s*(\"([^\"]*\")|'[^']*'|([^'\">\\s]+))", text: content)
                                        if(imgLinks.count>0)
                                        {
                                            imgFeed=imgLinks[0]
                                            imgFeed=imgFeed.replacingOccurrences(of: "src=", with: "").replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
                                        }
                                            
                                        else if(content.contains("media:content type=\"image/jpeg\""))
                                        {
                                            let mediaContent=content.subStringFromTwoTag("<media:content", endTag: "</media:content>")
                                            var imgLinks = feedDescription.matchesForRegexInText("\\s*(?i)url\\s*=\\s*(\"([^\"]*\")|'[^']*'|([^'\">\\s]+))", text: content)
                                            if(imgLinks.count>0)
                                            {
                                                imgFeed=imgLinks[0]
                                                imgFeed=imgFeed.replacingOccurrences(of: "url=", with: "").replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
                                            }
                                            
                                        }
                                    }
                                    if(imgFeed.contains("gstatic.com"))//Google News
                                    {
                                        
                                        imgFeed=imgFeed.replacingOccurrences(of: "&quot;//", with: "http://")
                                        imgFeed=imgFeed.replacingOccurrences(of: "&quot;", with: "")
                                        if(!imgFeed.contains("http"))
                                        {
                                            imgFeed=imgFeed.replacingOccurrences(of: "//", with: "http://")
                                        }
                                    }
                                }
                                if(imgFeed != "" && imgFeed.contains("feeds.feedburner.com") || imgFeed.contains("feedsportal") || imgFeed.contains("assets.feedblitz.com") || imgFeed.contains("www.dr.dk") || imgFeed.contains("tv2.dk") || imgFeed.contains(".gif"))
                                {
                                    
                                    imgFeed=""
                                }
                                feedDescription=feedDescription.replacingOccurrences(of: "<[^>]+>", with: "",options: .regularExpression, range: nil)
                                feedDescription=String(htmlEncodedString: feedDescription)!
                                feedTitle=String(htmlEncodedString: feedTitle)!
                                let feedIsExist=self.feedDataController.getFeedDataBySiteItemIdAndLink(self.siteItemSelected.siteItemID! as NSString, link: feedLink as NSString)
                                if(feedIsExist.count==0 && !feedTitle.isEmpty && !feedLink.isEmpty)
                                {
                                    var fieldDetails=[String:NSObject]()
                                    let feedID:String=UUID().uuidString
                                    fieldDetails[FeedDataAttributes.feedID.rawValue]=feedID as NSObject?
                                    fieldDetails[FeedDataAttributes.timeStamp.rawValue]=Date().timeIntervalSince1970 as NSObject?
                                    fieldDetails[FeedDataAttributes.siteID.rawValue]=self.siteItemSelected.siteID as NSObject?
                                    fieldDetails[FeedDataAttributes.siteItemID.rawValue]=self.siteItemSelected.siteItemID as NSObject?
                                    fieldDetails[FeedDataAttributes.loadTime.rawValue]=currentTime as NSObject?
                                    fieldDetails[FeedDataAttributes.title.rawValue]=feedTitle as NSObject?
                                    fieldDetails[FeedDataAttributes.pubDateString.rawValue]=pubDateString as NSObject?
                                    feedLink=self.getFullURL(url: feedLink, domainURL: siteItem.siteItemURL!)
                                    fieldDetails[FeedDataAttributes.link.rawValue]=feedLink as NSObject?
                                    fieldDetails[FeedDataAttributes.feedDescription.rawValue]=feedDescription as NSObject?
                                    fieldDetails[FeedDataAttributes.linkImage.rawValue]=imgFeed as NSObject?
                                    
                                    DispatchQueue.main.sync(execute: {
                                        self.feedDataController.saveFeedData(fieldDetails)
                                    })
                                    
                                }
                                feedXML=feedXML.replacingOccurrences(of: startTag+content+endTag, with: "")
                                
                            }
                            
                        }
                        else  if (feedXML.contains("<feed>") || feedXML.contains("<feed "))
                            
                        {
                            var content = feedXML.subStringFromTwoTag("<entry>", endTag: "</entry>")
                            while(!content.isEmpty && content != "")
                            {
                                
                                content=feedXML.subStringFromTwoTag("<entry>", endTag: "</entry>")
                                if(content == "")
                                {
                                    break
                                }
                                //title
                                var feedTitle=content.subStringFromTwoTag("<title", endTag: "</title>")
                                if(feedTitle.contains("<![CDATA["))
                                {
                                    feedTitle=feedTitle.subStringFromTwoTag("<![CDATA[", endTag: "]]>")
                                }
                                
                                //link
                                var feedLink:String!
                                feedLink=content.subStringFromTwoTag("<link>", endTag: "</link>")
                                if feedLink.isEmpty
                                {
                                    feedLink=content.subStringFromTwoTag("<link", endTag: "/>")
                                }
                                var matched=feedLink.matchesForRegexInText("href=\"([^']*)\"", text: feedLink)
                                if matched.count>0
                                {
                                    feedLink=matched[0]
                                }
                                feedLink=feedLink.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "href=", with: "")
                                feedLink=feedLink.trimmingCharacters(in: CharacterSet.whitespaces)
                                
                                //pubdate
                                var pubDateString=content.subStringFromTwoTag("<published>", endTag: "</published>")
                                if(pubDateString.contains("<![CDATA["))
                                {
                                    pubDateString=pubDateString.subStringFromTwoTag("<![CDATA[", endTag: "]]>")
                                }
                                
                                
                                var feedDescription:String!
                                
                                var description  = content.matchesForRegexInText("<summary[^>]*>(.*?)</summary>", text: content)
                                if description.isEmpty
                                {
                                    description  = content.matchesForRegexInText("<content[^>]*>(.*?)</content>", text: content)
                                    
                                }
                                if description.isEmpty == false
                                {
                                    feedDescription=description[0].replacingOccurrences(of: "<[^>]+>", with: "",options: .regularExpression, range: nil)
                                }
                                var imgFeed:String=""
                                if(feedDescription != nil)
                                {
                                    var imgLinks = feedDescription.matchesForRegexInText("(http://[^\\s]+(.jpg|.png))", text: content)
                                    if(imgLinks.count>0)
                                    {
                                        imgFeed=imgLinks[0]
                                    }
                                }
                                
                                if(imgFeed=="" || imgFeed.contains("http")==false)
                                {
                                    var imgLinks = feedDescription.matchesForRegexInText("(http://[^\\s]+(.jpg|.png))", text: content)
                                    if(imgLinks.count>0)
                                    {
                                        imgFeed=imgLinks[0]
                                    }
                                    else
                                    {
                                        
                                        var imgLinks = feedDescription.matchesForRegexInText("\\s*(?i)src\\s*=\\s*(\"([^\"]*\")|'[^']*'|([^'\">\\s]+))", text: content)
                                        if(imgLinks.count>0)
                                        {
                                            imgFeed=imgLinks[0]
                                            imgFeed=imgFeed.replacingOccurrences(of: "src=", with: "").replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\"", with: "")
                                        }
                                    }
                                    if(imgFeed.contains("gstatic.com"))//Google News
                                    {
                                        
                                        imgFeed=imgFeed.replacingOccurrences(of: "&quot;//", with: "http://")
                                        imgFeed=imgFeed.replacingOccurrences(of: "&quot;", with: "")
                                        if(!imgFeed.contains("http"))
                                        {
                                            imgFeed=imgFeed.replacingOccurrences(of: "//", with: "http://")
                                        }
                                    }
                                    
                                }
                                if(imgFeed != "" && imgFeed.contains("feeds.feedburner.com") || imgFeed.contains("assets.feedblitz.com") || imgFeed.contains(".gif"))
                                {
                                    
                                    imgFeed=""
                                }
                                feedDescription=String(htmlEncodedString: feedDescription)!
                                feedTitle=String(htmlEncodedString: feedTitle)!
                                let feedIsExist=self.feedDataController.getFeedDataBySiteItemIdAndLink(self.siteItemSelected.siteItemID! as NSString, link: feedLink as NSString)
                                if(feedIsExist.count==0 && !feedTitle.isEmpty && !feedLink.isEmpty)
                                {
                                    var fieldDetails=[String:NSObject]()
                                    let feedID:String=UUID().uuidString
                                    fieldDetails[FeedDataAttributes.feedID.rawValue]=feedID as NSObject?
                                    fieldDetails[FeedDataAttributes.timeStamp.rawValue]=Date().timeIntervalSince1970 as NSObject?
                                    fieldDetails[FeedDataAttributes.siteID.rawValue]=self.siteItemSelected.siteID as NSObject?
                                    fieldDetails[FeedDataAttributes.siteItemID.rawValue]=self.siteItemSelected.siteItemID as NSObject?
                                    fieldDetails[FeedDataAttributes.loadTime.rawValue]=currentTime as NSObject?
                                    fieldDetails[FeedDataAttributes.title.rawValue]=feedTitle as NSObject?
                                    fieldDetails[FeedDataAttributes.pubDateString.rawValue]=pubDateString as NSObject?
                                    feedLink=self.getFullURL(url: feedLink, domainURL: siteItem.siteItemURL!)
                                    
                                    fieldDetails[FeedDataAttributes.link.rawValue]=feedLink as NSObject?
                                    fieldDetails[FeedDataAttributes.feedDescription.rawValue]=feedDescription as NSObject?
                                    fieldDetails[FeedDataAttributes.linkImage.rawValue]=imgFeed as NSObject?
                                    DispatchQueue.main.sync(execute: {
                                        self.feedDataController.saveFeedData(fieldDetails)
                                    })
                                    
                                }
                                feedXML=feedXML.replacingOccurrences(of: "<entry>"+content+"</entry>", with: "")
                                
                            }
                            
                        }
                        // Post notification to update datasource of a given ViewController/UITableView
                        DispatchQueue.main.async {
                            self.stopDownloadFeed(autoFreshing)
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    })
                    
                }
            }
            
        }
        
    }
    fileprivate func DownloadError(_ autoFreshing:Bool)
    {
        DispatchQueue.main.async {
            let lb=UILabel()
            lb.frame=CGRect(x: 0, y: 0, width: 320, height: 20)
            lb.text=NSLocalizedString("error_message", comment: "")
            lb.textAlignment = .center
            lb.backgroundColor=UIColor.red
            lb.textColor=UIColor.white
            self.tableViewFeedList.tableHeaderView=lb
            self.tableViewFeedList.reloadData()
            self.stopDownloadFeed(autoFreshing)
            
            
        }
        
        
    }
    fileprivate func stopDownloadFeed(_ autoFreshing:Bool)
    {
        self.sideMenuController()?.sideMenu?.menuViewController.viewDidLoad()
        self.feedDataList=self.feedDataController.getFeedDataBySiteItemId(self.siteItemSelected.siteItemID! as NSString)
        
        self.tableViewFeedList.reloadData()
        self.indicator.stopAnimating()
        if(autoFreshing)
        {
            self.refreshControl.endRefreshing()
        }
    }
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
       adsBannerConstraintHeight.constant=0.0
        
    }
    
    func sideMenuWillClose() {
        if(setting.getShowAds() && setting.getAdsType()==Settings.AdsType.Banner.rawValue){
            
            adsBannerConstraintHeight.constant=50.0
            
        }
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        //print("sideMenuShouldOpenSideMenu")
        
        return true
    }
    
    func sideMenuDidClose() {
        //print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        //print("sideMenuDidOpen")
    }
    func sideMenuIndexSelected(_ index: Int) {
        if(index > -1){
            
            self.tableViewFeedList.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            siteItemSelected=siteItemList[index]
            //self.navigationItem.title=siteItemSelected.siteItemName
            //navigationbarTitle.title=siteItemSelected.siteItemName
            self.searchController.searchBar.placeholder=siteItemSelected.siteItemName
            SelectionChange(siteItemSelected, autoFreshing: false, isError: false)
        }
        else
        {
            passOject.set(siteSelectedID, forKey: "siteID_key")
            let mapViewControllerObj = self.storyboard!.instantiateViewController(withIdentifier: "siteSettingStoryBoard") as! SiteSettingTableViewController
            
            self.navigationController?.pushViewController(mapViewControllerObj, animated: true)
        }
        
    }
    func getFullURL(url:String,domainURL:String)->String
    {
        var domain=domainURL
        if(!domainURL.contains("http"))
        {
            domain=Utils.deCryptString2(domainURL)
        }
        var hostname=url
        let baseURL=NSURL(string: domain)
        
        if(url.contains("http")==false){
            hostname=(baseURL?.host)!+url
        }
        return hostname
        
        
    }
}
