//
//  SearchResultController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 9/10/17.
//  Copyright © 2017 admin. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Nuke
class SearchResultController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,UISearchBarDelegate,UISearchResultsUpdating
{
    
    //    fileprivate var feedDataController:FeedDataController!
    
    let realm = try! Realm()
    var notificationToken: NotificationToken?
    var feedDataList = try! Realm().objects(FeedData.self).filter("siteItemID = %@",UUID().uuidString)
    
    var feedTableView: UITableView = UITableView()
    var cellFontSize:CGFloat=13.0
    var cellIPadFontSize:CGFloat=17.0
    var imageSize:CGFloat=75.0
    var isExpandDescription:Bool=false
    let setting = Settings()
    var shouldShowSearchResults = false
    var rightBarItem:UIBarButtonItem=UIBarButtonItem()
    var leftBarItem:UIBarButtonItem=UIBarButtonItem()
    var searchController: UISearchController = ({
        
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.searchBarStyle = .minimal
        controller.searchBar.sizeToFit()
        return controller
    })()
     
    override func viewDidLoad() {
        
        super.viewDidLoad()
        feedDataList = realm.objects(FeedData.self).filter("siteItemID = %@",UUID().uuidString).sorted(by: [SortDescriptor(keyPath: "loadTime",ascending: true),SortDescriptor(keyPath: "timeStamp",ascending: true)])
        // Observe the tasks for changes. Hang on to the returned notification token.
        notificationToken = feedDataList.observe { [weak self] (changes) in
            guard let tableView = self?.feedTableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView.
                tableView.performBatchUpdates({
                    // It's important to be sure to always update a table in this order:
                    // deletions, insertions, then updates. Otherwise, you could be unintentionally
                    // updating at the wrong index!
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .fade)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                        with: .none)
                })
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        cellFontSize=CGFloat(setting.getTextSize())
        cellIPadFontSize = CGFloat(setting.getTextSize())+4
        isExpandDescription=setting.getExpandDescription()
        
        
        
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
            feedTableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
            feedTableView.register(UINib(nibName: "FeedImageViewCell", bundle: nil), forCellReuseIdentifier: "CellNotDesc")
            feedTableView.register(UINib(nibName: "FeedViewCell", bundle: nil), forCellReuseIdentifier: "CellNotImage")
        }
        else
        {
            feedTableView.register(UINib(nibName: "FeedImageViewCellIPad", bundle: nil), forCellReuseIdentifier: "CellNotDescIPad")
            feedTableView.register(UINib(nibName: "FeedViewCellIPad", bundle: nil), forCellReuseIdentifier: "CellNotImageIPad")
        }
        
        self.feedTableView.tableHeaderView=nil
        self.feedTableView.reloadData()
        
        self.view.addSubview(feedTableView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        
        
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
        self.searchController.searchBar.placeholder="Search"
        
        
        
    }
    
    //Begin Search Bar
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        
        
        self.navigationItem.rightBarButtonItem=nil
        self.navigationItem.leftBarButtonItem=nil
        self.navigationItem.backBarButtonItem=nil
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
        
        
        let searchString = searchController.searchBar.text
        
       feedDataList = realm.objects(FeedData.self).filter("title contains %@ or feedDescription contains %@",searchString,searchString).sorted(by: [SortDescriptor(keyPath: "loadTime",ascending: true),SortDescriptor(keyPath: "timeStamp",ascending: true)])
        //feedDataList=feedDataController.getFeedDataByTitleAndDescriptionKeyWord(keyWord: searchString as! NSString, description: searchString as! NSString)
        feedTableView.reloadData()
        
        searchController.searchBar.resignFirstResponder()
    }
    func updateSearchResults(for searchController: UISearchController) {
        /*
         let searchString = searchController.searchBar.text
         
         // Filter the data array and get only those countries that match the search text.
         
         feedDataList = feedDataList.filter() {
         return ($0.title!.lowercased().range(of: (searchString?.lowercased())!) != nil || $0.feedDescription!.lowercased().range(of: (searchString?.lowercased())!) != nil)
         }
         
         // Reload the tableview.
         feedTableView.reloadData()*/
    }
    
    //End Search Bar
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return feedDataList.count
    }
    var btnExpandTapped:Bool=false
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var feedData:FeedData
        feedData=feedDataList[(indexPath as NSIndexPath).row]
        
        if(UIDevice.current.userInterfaceIdiom == .phone)
        {
            if((feedData.linkImage != nil ) && (feedData.linkImage?.count)!>10 && setting.getBlockImage()==true)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath)
                    as! FeedTableViewCell
                if(feedData.imageArray != nil && (feedData.imageArray?.count)!>0)
                {
                    cell.imgFeed.image=UIImage(data: feedData.imageArray! as Data)
                }
                else
                {
                    Nuke.loadImage(with: URL(string: feedData.linkImage ?? ""), into: cell.imgFeed)
                }
                if(feedData.isRead==1)
                {
                    cell.lbTitle.font = UIFont.systemFont(ofSize: cellFontSize)
                }
                else
                {
                    cell.lbTitle.font = UIFont.boldSystemFont(ofSize: cellFontSize)
                }
                cell.lbTitle.text=feedData.title
                cell.lbTitle.numberOfLines=3
                cell.lbDescription.text=feedData.feedDescription
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
                    if(!feedData.isExpand)
                    {
                        try! self.realm.write({
                            feedData.isExpand = true
                        })
                    }
                    else
                    {
                        try! self.realm.write({
                            feedData.isExpand = false
                        })
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
                    cell.btnImportan.setImage(image, for: UIControl.State())
                }
                else
                {
                    let image = UIImage(named: "ic_bookmark_border") as UIImage?
                    cell.btnImportan.setImage(image, for: UIControl.State())
                }
                cell.btnImportanTapped =
                    {
                        if(feedData.isFavorite == 1)
                        {
                            let image = UIImage(named: "ic_bookmark_border") as UIImage?
                            cell.btnImportan.setImage(image, for: UIControl.State())
                            try! self.realm.write({
                                feedData.isFavorite=0
                            })
                        }
                        else
                        {
                            let image = UIImage(named: "ic_bookmark") as UIImage?
                            cell.btnImportan.setImage(image, for: UIControl.State())
                            try! self.realm.write({
                                feedData.isFavorite=1
                            })
                            
                        }
                        
                    }
                
                
                let taplabeTitlelAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labeTitlelAction(sender:)))
                cell.lbTitle.addGestureRecognizer(taplabeTitlelAction)
                cell.lbTitle.tag=(indexPath as NSIndexPath).row
                cell.lbTitle.isUserInteractionEnabled=true
                taplabeTitlelAction.delegate = self // Remember to extend your class with UIGestureRecognizerDelegate
                
                let taplabeDesciptionAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labeTitlelAction(sender:)))
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
                cellNotImage.lbTitle.numberOfLines=3
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
                    self.btnExpandTapped=feedData.isExpand
                    if(!feedData.isExpand)
                    {
                        try! self.realm.write({
                            feedData.isExpand = true
                        })
                       
                    }
                    else
                    {
                        try! self.realm.write({
                            feedData.isExpand = false
                        })
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
                            try! self.realm.write({
                                feedData.isFavorite=0
                            })
                        }
                        else
                        {
                            let image = UIImage(named: "ic_bookmark") as UIImage?
                            cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                            try! self.realm.write({
                                feedData.isFavorite=1
                            })
                        }
                        
                        let indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                        self.feedTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    }
                
                //
                let taplabeTitlelAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labeTitlelAction(sender:)))
                cellNotImage.lbTitle.addGestureRecognizer(taplabeTitlelAction)
                cellNotImage.lbTitle.tag=(indexPath as NSIndexPath).row
                cellNotImage.lbTitle.isUserInteractionEnabled=true
                taplabeTitlelAction.delegate = self // Remember to extend your class with UIGestureRecognizerDelegate
                
                let taplabeDesciptionAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labeTitlelAction(sender:)))
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
                
                
                Nuke.loadImage(with: URL(string: feedData.linkImage ?? ""), into: cell.feedImageCell)
                
                
                if(feedData.isRead==1)
                {
                    
                    cell.lbTitleCell.font = UIFont.systemFont(ofSize: cellIPadFontSize)
                }
                else
                {
                    cell.lbTitleCell.font = UIFont.boldSystemFont(ofSize: cellIPadFontSize)
                }
                cell.lbTitleCell.text=feedData.title
                cell.lbTitleCell.numberOfLines=3
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
                    self.btnExpandTapped=feedData.isExpand
                    if(!feedData.isExpand)
                    {
                        try! self.realm.write({
                            feedData.isExpand = true
                        })
                    }
                    else
                    {
                        try! self.realm.write({
                            feedData.isExpand = false
                        })
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
                            try! self.realm.write({
                                feedData.isFavorite=0
                            })
                        }
                        else
                        {
                            let image = UIImage(named: "ic_bookmark") as UIImage?
                            cell.btImportan.setImage(image, for: UIControl.State())
                            try! self.realm.write({
                                feedData.isFavorite=1
                            })
                        }
                        
                        let indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                        self.feedTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    }
                
                
                let taplabeTitlelAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labeTitlelAction(sender:)))
                cell.lbTitleCell.addGestureRecognizer(taplabeTitlelAction)
                cell.lbTitleCell.tag=(indexPath as NSIndexPath).row
                cell.lbTitleCell.isUserInteractionEnabled=true
                taplabeTitlelAction.delegate = self // Remember to extend your class with UIGestureRecognizerDelegate
                
                let taplabeDesciptionAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labeTitlelAction(sender:)))
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
                cellNotImage.lbTitle.numberOfLines=3
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
                    self.btnExpandTapped=feedData.isExpand
                    if(!feedData.isExpand)
                    {
                        try! self.realm.write({
                            feedData.isExpand = true
                        })
                    }
                    else
                    {
                        try! self.realm.write({
                            feedData.isExpand = false
                        })
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
                            try! self.realm.write({
                                feedData.isFavorite=0
                            })
                        }
                        else
                        {
                            let image = UIImage(named: "ic_bookmark") as UIImage?
                            cellNotImage.btnImportan.setImage(image, for: UIControl.State())
                            try! self.realm.write({
                                feedData.isFavorite=1
                            })
                        }
                         
                    }
                
                //
                let taplabeTitlelAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labeTitlelAction(sender:)))
                cellNotImage.lbTitle.addGestureRecognizer(taplabeTitlelAction)
                cellNotImage.lbTitle.tag=(indexPath as NSIndexPath).row
                cellNotImage.lbTitle.isUserInteractionEnabled=true
                taplabeTitlelAction.delegate = self // Remember to extend your class with UIGestureRecognizerDelegate
                
                let taplabeDesciptionAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labeTitlelAction(sender:)))
                cellNotImage.lbDescription.addGestureRecognizer(taplabeDesciptionAction)
                cellNotImage.lbDescription.tag=(indexPath as NSIndexPath).row
                cellNotImage.lbDescription.isUserInteractionEnabled=true
                taplabeDesciptionAction.delegate = self // Remember to extend your class with UIGestureRecognizerDelegate
                
                
                return cellNotImage
                
                
            }
        }
    }
    @objc func labeTitlelAction(sender:UITapGestureRecognizer)
    {
        
        
        openWebView(sender.view?.tag)
        
    }
    func openWebView(_ tag:Int!)
    {
        var feedData:FeedData
        feedData=feedDataList[tag]
        
        feedData.isRead=1
        
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
    // MARK: - Private instance methods
    
    
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
