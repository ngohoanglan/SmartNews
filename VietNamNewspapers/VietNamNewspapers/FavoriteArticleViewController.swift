//
//  FavoriteArticleViewController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 6/19/16.
//  Copyright © 2016 admin. All rights reserved.
//
import ImageLoader
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


class FavoriteArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating
, UISearchBarDelegate,UIGestureRecognizerDelegate {
    var shouldShowSearchResults = false
    var searchController: UISearchController = ({
        
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.searchBarStyle = .minimal
        controller.searchBar.sizeToFit()
        return controller
    })()
    var btnShowMenu: UIBarButtonItem!
    
    var feedTableView: UITableView = UITableView()
    var barBack: UIBarButtonItem!
    fileprivate var httpClient:HTTPClient!
   
    // @IBOutlet weak var navigationbarTitle: UINavigationItem!
    var passOject:UserDefaults!
    
    fileprivate var feedDataController:FeedDataController!
    fileprivate var feedDataList:Array<FeedData>=[]
    fileprivate var feedDataFilteredList:Array<FeedData>=[]
    fileprivate var siteItemList:Array<SiteItem>=[]
    var isBlockImage:Bool=false
    var textSize:CGFloat=0.0
    var isExpandDescription:Bool=false
    let setting = Settings()
    var cellFontSize:CGFloat=13.0
    var cellIPadFontSize:CGFloat=17.0
    var imageSize:CGFloat=75.0
    var adsBanner: GADBannerView = GADBannerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.setup()
        passOject=UserDefaults()
        cellFontSize=CGFloat(setting.getTextSize())
        cellIPadFontSize = CGFloat(setting.getTextSize())+4
        // Get main screen bounds
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        
        
        feedTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        
        feedTableView.dataSource = self
        feedTableView.delegate = self
        feedTableView.estimatedRowHeight = 154
        feedTableView.rowHeight = UITableView.automaticDimension
        feedTableView.separatorStyle = .none
        if(UIDevice.current.userInterfaceIdiom == .phone)
        {
            feedTableView.register(UINib(nibName: "FeedImageViewCell", bundle: nil), forCellReuseIdentifier: "CellNotDesc")
            feedTableView.register(UINib(nibName: "FeedViewCell", bundle: nil), forCellReuseIdentifier: "CellNotImage")
        }
        else
        {
            feedTableView.register(UINib(nibName: "FeedImageViewCellIPad", bundle: nil), forCellReuseIdentifier: "CellNotDescIPad")
            feedTableView.register(UINib(nibName: "FeedViewCellIPad", bundle: nil), forCellReuseIdentifier: "CellNotImageIPad")
        }
        
        
        
        SelectionChange()
        feedTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(feedTableView)
        
        //Ads banner
        //adsBanner.adUnitID = "ca-app-pub-3108267494433171/2104853242"
        //setting.getAdmobKey()
        //adsBanner.rootViewController = self
       // adsBanner.load(GADRequest())
       // adsBanner.adSize=kGADAdSizeFullBanner
        
        adsBanner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(adsBanner)
        
        NSLayoutConstraint(item: feedTableView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: feedTableView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: feedTableView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: feedTableView, attribute: .centerX, relatedBy: .equal, toItem: adsBanner, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: adsBanner, attribute: .top, relatedBy: .equal, toItem: feedTableView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: adsBanner, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: adsBanner, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: adsBanner, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0).isActive = true
        /*
        //Constraints
        feedTableView.translatesAutoresizingMaskIntoConstraints=false
        let leading = NSLayoutConstraint(item: feedTableView,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self.view,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 0.0)
        
        let trailing = NSLayoutConstraint(item: feedTableView,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self.view,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: -0.0)
        
        let top = NSLayoutConstraint(item: feedTableView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: self.view,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 0.0)
        let bottom = NSLayoutConstraint(item: feedTableView,
                                        attribute: .bottomMargin,
                                        relatedBy: .equal,
                                        toItem: self.view,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: -0.0)
        
        //NSLayoutConstraint.activate([leading, trailing, top])
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
        //End constraint
        
        */
       
        
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
        
        self.navigationItem.leftBarButtonItem=nil
        self.navigationItem.rightBarButtonItem=nil
        isBlockImage=setting.getBlockImage()
        isExpandDescription=setting.getExpandDescription()
        textSize=CGFloat(setting.getTextSize())
    }
    //Begin Search Bar
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        // tableViewFeedList.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        shouldShowSearchResults = false
        feedTableView.reloadData()
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            feedTableView.reloadData()
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
        feedTableView.reloadData()
    }
    
    //End Search Bar
    override func viewDidAppear(_ animated: Bool) {
        self.feedTableView.estimatedRowHeight = 100.0
        self.feedTableView.rowHeight = UITableView.automaticDimension
        SelectionChange()
        
        
    }
    @IBAction func btnShowMenu(_ sender: UIButton) {
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
                
                }, completion: { (finished) -> Void in
                    viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
    }
    fileprivate func setup(){
        //siteController=SiteController.shareInstance
        //siteItemController=SiteItemController.shareInstance
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
        
       
        if(UIDevice.current.userInterfaceIdiom == .phone)
        {
            if((feedData.linkImage != nil ) && (feedData.linkImage?.count)!>10 && setting.getBlockImage()==true)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellNotDesc", for: indexPath)
                    as! FeedNotDescriptionViewCell
                
                
                if(feedData.imageArray != nil && (feedData.imageArray?.count)!>0)
                {
                    cell.feedImageCell.image=UIImage(data: feedData.imageArray! as Data)
                }
                else
                {
                    
                    //
                    cell.feedImageCell.image=nil
                    //
                  
                    cell.feedImageCell.load.request(with: feedData.linkImage!, onCompletion: { image, error, operation in
                        
                        if operation == .network {
                            let myImage : UIImage = Utils.resizeImage(image!, maxWidth: self.imageSize, maxHeight: self.imageSize)
                            let transition = CATransition()
                            transition.duration = 0.5
                            transition.type = CATransitionType.fade
                            cell.feedImageCell.layer.add(transition, forKey: nil)
                            cell.feedImageCell.image = myImage
                            
                            feedData.imageArray=myImage.pngData()
                            let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.imageArray.rawValue : feedData.imageArray! as AnyObject]
                            self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
                        }
                    })
                   
                    
                }
                
                if(feedData.isRead==1)
                {
                    
                    cell.lbTitleCell.font = UIFont.systemFont(ofSize: cellFontSize)
                }
                else
                {
                    cell.lbTitleCell.font = UIFont.boldSystemFont(ofSize: cellFontSize)
                }
                cell.lbTitleCell.text=feedData.title
                // cell.lbDescription.text=feedData.feedDescription
                cell.lbDescription.font=UIFont.systemFont(ofSize: cellFontSize)
                cell.lbPubdate.text=feedData.pubDateString
                if(!feedData.isExpand )
                {
                    let image = UIImage(named: "ic_expand_more") as UIImage?
                    cell.btnExpand.setImage(image, for: UIControl.State())
                    //cell.csDescriptionHeight.constant=0.0
                    cell.lbDescription.text=""
                }
                else
                {
                    let image = UIImage(named: "ic_expand_less") as UIImage?
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
                    self.feedTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                }
                cell.btnShareTapped =
                    {
                        if let name = URL(string: feedData.link!) {
                            let objectsToShare = [name]
                            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
                            {
                                if ( activityVC.responds(to: #selector(getter: UIViewController.popoverPresentationController)) ) {
                                    activityVC.popoverPresentationController?.sourceView = self.view
                                }
                            }
                            self.present(activityVC, animated: true, completion: nil)
                            
                        }
                }
                if(feedData.isFavorite == 1)
                {
                    let image = UIImage(named: "ic_bookmark") as UIImage?
                    cell.btImportan.setImage(image, for: UIControl.State())
                }
                else
                {
                    let image = UIImage(named: "ic_bookmark_border") as UIImage?
                    cell.btImportan.setImage(image, for: UIControl.State())
                }
                cell.btnImportanTapped =
                    {
                        if(feedData.isFavorite == 1)
                        {
                            let image = UIImage(named: "ic_bookmark_border") as UIImage?
                            cell.btImportan.setImage(image, for: UIControl.State())
                            feedData.isFavorite=0
                        }
                        else
                        {
                            let image = UIImage(named: "ic_bookmark") as UIImage?
                            cell.btImportan.setImage(image, for: UIControl.State())
                            feedData.isFavorite=1
                        }
                        let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.isFavorite.rawValue : feedData.isFavorite!]
                        self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
                        let indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                        self.feedTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
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
                    cellNotImage.lbTitle.font = UIFont.systemFont(ofSize: cellFontSize)
                }
                else
                {
                    cellNotImage.lbTitle.font = UIFont.boldSystemFont(ofSize: cellFontSize)
                }
                cellNotImage.lbTitle.text=feedData.title
                //cellNotImage.lbDescription.text=feedData.feedDescription
                cellNotImage.lbDescription.font=UIFont.systemFont(ofSize: cellFontSize)
                cellNotImage.lbPubDate.text=feedData.pubDateString
                
                //
                if(!feedData.isExpand)
                {
                    let image = UIImage(named: "ic_expand_more") as UIImage?
                    cellNotImage.btnExpand.setImage(image, for: UIControl.State())
                    //  cellNotImage.csHeightDescription.constant=0.0
                    cellNotImage.lbDescription.text = ""
                }
                else
                {
                    let image = UIImage(named: "ic_expand_less") as UIImage?
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
                    self.feedTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
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
                    let image = UIImage(named: "ic_bookmark") as UIImage?
                    cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                }
                else
                {
                    let image = UIImage(named: "ic_bookmark_border") as UIImage?
                    cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                }
                cellNotImage.btnImportanTapped =
                    {
                        if(feedData.isFavorite == 1)
                        {
                            let image = UIImage(named: "ic_bookmark_border") as UIImage?
                            cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                            feedData.isFavorite=0
                        }
                        else
                        {
                            let image = UIImage(named: "ic_bookmark") as UIImage?
                            cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                            feedData.isFavorite=1
                        }
                        let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.isFavorite.rawValue : feedData.isFavorite!]
                        self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
                        let indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                        self.feedTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
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
        else //IPad
        {
            if((feedData.linkImage != nil ) && (feedData.linkImage?.count)!>10 && setting.getBlockImage()==true)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellNotDescIPad", for: indexPath)
                    as! FeedNotDescriptionViewCellIPad
                
                
                if(feedData.imageArray != nil && (feedData.imageArray?.count)!>0)
                {
                    cell.feedImageCell.image=UIImage(data: feedData.imageArray! as Data)
                }
                else
                {
                    
                    //
                    cell.feedImageCell.image=nil
                    //
                    
                    cell.feedImageCell.load.request(with: feedData.linkImage!, onCompletion: { image, error, operation in
                        
                        if operation == .network {
                            let myImage : UIImage = Utils.resizeImage(image!, maxWidth: self.imageSize+50, maxHeight: self.imageSize+50)
                            let transition = CATransition()
                            transition.duration = 0.5
                            transition.type = CATransitionType.fade
                            cell.feedImageCell.layer.add(transition, forKey: nil)
                            cell.feedImageCell.image = myImage
                            
                            feedData.imageArray=myImage.pngData()
                            let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.imageArray.rawValue : feedData.imageArray! as AnyObject]
                            self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
                        }
                    })

                    
                }
                
                if(feedData.isRead==1)
                {
                    
                    cell.lbTitleCell.font = UIFont.systemFont(ofSize: cellIPadFontSize)
                }
                else
                {
                    cell.lbTitleCell.font = UIFont.boldSystemFont(ofSize: cellIPadFontSize)
                }
                cell.lbTitleCell.text=feedData.title
                // cell.lbDescription.text=feedData.feedDescription
                cell.lbDescription.font=UIFont.systemFont(ofSize: cellIPadFontSize)
                cell.lbPubdate.text=feedData.pubDateString
                if(!feedData.isExpand )
                {
                    let image = UIImage(named: "ic_expand_more") as UIImage?
                    cell.btnExpand.setImage(image, for: UIControl.State())
                    //cell.csDescriptionHeight.constant=0.0
                    cell.lbDescription.text=""
                }
                else
                {
                    let image = UIImage(named: "ic_expand_less") as UIImage?
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
                    self.feedTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                }
                cell.btnShareTapped =
                    {
                        if let name = URL(string: feedData.link!) {
                            let objectsToShare = [name]
                            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
                            {
                                if ( activityVC.responds(to: #selector(getter: UIViewController.popoverPresentationController)) ) {
                                    activityVC.popoverPresentationController?.sourceView = cell.btnShare
                                }
                            }
                            self.present(activityVC, animated: true, completion: nil)
                        }
                }
                if(feedData.isFavorite == 1)
                {
                    let image = UIImage(named: "ic_bookmark") as UIImage?
                    cell.btImportan.setImage(image, for: UIControl.State())
                }
                else
                {
                    let image = UIImage(named: "ic_bookmark_border") as UIImage?
                    cell.btImportan.setImage(image, for: UIControl.State())
                }
                cell.btnImportanTapped =
                    {
                        if(feedData.isFavorite == 1)
                        {
                            let image = UIImage(named: "ic_bookmark_border") as UIImage?
                            cell.btImportan.setImage(image, for: UIControl.State())
                            feedData.isFavorite=0
                        }
                        else
                        {
                            let image = UIImage(named: "ic_bookmark") as UIImage?
                            cell.btImportan.setImage(image, for: UIControl.State())
                            feedData.isFavorite=1
                        }
                        let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.isFavorite.rawValue : feedData.isFavorite!]
                        self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
                        let indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                        self.feedTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
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
                let cellNotImage = tableView.dequeueReusableCell(withIdentifier: "CellNotImageIPad", for: indexPath)
                    as! FeedDataTableViewCellIPad
                if(feedData.isRead==1)
                {
                    cellNotImage.lbTitle.font = UIFont.systemFont(ofSize: cellIPadFontSize)
                }
                else
                {
                    cellNotImage.lbTitle.font = UIFont.boldSystemFont(ofSize: cellIPadFontSize)
                }
                cellNotImage.lbTitle.text=feedData.title
                //cellNotImage.lbDescription.text=feedData.feedDescription
                cellNotImage.lbDescription.font=UIFont.systemFont(ofSize: cellIPadFontSize)
                cellNotImage.lbPubDate.text=feedData.pubDateString
                
                //
                if(!feedData.isExpand)
                {
                    let image = UIImage(named: "ic_expand_more") as UIImage?
                    cellNotImage.btnExpand.setImage(image, for: UIControl.State())
                    //  cellNotImage.csHeightDescription.constant=0.0
                    cellNotImage.lbDescription.text = ""
                }
                else
                {
                    let image = UIImage(named: "ic_expand_less") as UIImage?
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
                    self.feedTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
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
                    let image = UIImage(named: "ic_bookmark") as UIImage?
                    cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                }
                else
                {
                    let image = UIImage(named: "ic_bookmark_border") as UIImage?
                    cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                }
                cellNotImage.btnImportanTapped =
                    {
                        if(feedData.isFavorite == 1)
                        {
                            let image = UIImage(named: "ic_bookmark_border") as UIImage?
                            cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                            feedData.isFavorite=0
                        }
                        else
                        {
                            let image = UIImage(named: "ic_bookmark") as UIImage?
                            cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                            feedData.isFavorite=1
                        }
                        let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.isFavorite.rawValue : feedData.isFavorite!]
                        self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
                        let indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                        self.feedTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
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
        
    }
    func labeTitlelAction(_ gr:UITapGestureRecognizer)
    {
        
        
        openWebView(gr.view?.tag)
        
    }
    func openWebView(_ tag:Int!)
    {
        var feedData:FeedData
        feedData=feedDataList[tag]
        
        feedData.isRead=1
        let newFeedUpdate:Dictionary<String,AnyObject> = [FeedDataAttributes.isRead.rawValue : feedData.isRead!]
        self.feedDataController.updateFeedData(feedData, newFeedDataDetails: newFeedUpdate)
        let indexPath=IndexPath(item: tag, section: 0)
        self.feedTableView.reloadRows(at: [indexPath], with: .none)
        let urlFeed=feedData.link!
        
        
        if let url = URL(string: urlFeed) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                          completionHandler: {
                                            (success) in
                                            print("Open \(urlFeed): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(urlFeed): \(success)")
            }
        }
    }
    fileprivate func SelectionChange()
    {
        feedDataList=feedDataController.getFeedDataByFavorites()
        self.feedTableView.reloadData()
        
        
        
    }
    
    
    //region SlideMenu
    
    
    //impliment delegate func
    func slideMenuItemSelectedAtIndex(_ index: Int) {
        if(index != -1){
            //siteItemSelected=siteItemList[index]
            //self.searchController.searchBar.placeholder=siteItemSelected.siteItemName
            //SelectionChange(siteItemSelected, autoFreshing: false)
        }
    }
    
    func resizeImage(_ image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        var scaleX:CGFloat=1
        var scaleY:CGFloat=1
        if(image.size.height>maxHeight)
        {
            scaleY=maxHeight/image.size.height
        }
        if(image.size.width>maxWidth)
        {
            scaleX=maxWidth/image.size.width
        }
        var scale:CGFloat = 1
        if(scaleX<scaleY)
        {
            scale=scaleX
        }
        else
        {
            scale=scaleY
        }
        let newWidth = image.size.width*scale
        let newHeight=image.size.height*scale
        
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth,height: newHeight), false, 0.0)
        
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func RBSquareImageTo(_ image: UIImage, size: CGSize) -> UIImage {
        return RBResizeImage(RBSquareImage(image), targetSize: size)
    }
    
    func RBSquareImage(_ image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        
        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        let posX = (originalWidth  - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        let cropSquare = CGRect(x: posX, y: posY, width: edge, height: edge)
        
        let imageRef = image.cgImage?.cropping(to: cropSquare);
        return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
    
    func RBResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //endregion
    
    
    // MARK: - Navigation
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     passOject.setObject(siteSelectedID, forKey: "siteID_key")
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
