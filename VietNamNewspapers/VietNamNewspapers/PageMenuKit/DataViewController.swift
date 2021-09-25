//
//  DataViewController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 7/25/17.
//  Copyright © 2017 admin. All rights reserved.
//
import RealmSwift
import Foundation
import UIKit
import GoogleMobileAds
import Nuke
class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate
{
    public   var _siteItemSelected: SiteItem!
    let realm = try! Realm()
    var notificationToken: NotificationToken?
    var feedDataList = try! Realm().objects(FeedData.self).filter("siteItemID = %@",UUID().uuidString)
   
    let refreshControl = UIRefreshControl()
    var feedTableView: UITableView = UITableView()
    
    fileprivate var siteItemController:SiteItemController!
    //    fileprivate var feedDataController:FeedDataController!
    //fileprivate var feedDataList:Array<FeedData>=[]
    fileprivate var feedDataFilteredList:Array<FeedData>=[]
    fileprivate var siteItemList:Array<SiteItem>=[]
    
    fileprivate var siteItemSelected:SiteItem!
    fileprivate var previousSiteItem:SiteItem!
    let indicator=UIActivityIndicatorView(style: .gray)
    fileprivate var httpClient:HTTPClient!
    let setting = Settings()
    var selectedMenuItem:Int=0
    var cellFontSize:CGFloat=13.0
    var cellIPadFontSize:CGFloat=17.0
    var imageSize:CGFloat=75.0
    
    var isExpandDescription:Bool=false
    
    public private(set) var textLabel: UILabel? = nil
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
        siteItemSelected=_siteItemSelected
        feedDataList = realm.objects(FeedData.self).filter("siteItemID = %@",siteItemSelected.siteItemID!).sorted(by: [SortDescriptor(keyPath: "loadTime",ascending: true),SortDescriptor(keyPath: "timeStamp",ascending: true)])
        self.title = siteItemSelected.siteItemName
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Access all tasks in the realm, sorted by _id so that the ordering is defined.
        feedDataList = realm.objects(FeedData.self).filter("siteItemID = %@",_siteItemSelected.siteItemID!).sorted(by: [SortDescriptor(keyPath: "loadTime",ascending: true),SortDescriptor(keyPath: "timeStamp",ascending: true)])

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
        
        siteItemController=SiteItemController.shareInstance
        isExpandDescription=setting.getExpandDescription()
        
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
            feedTableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
            feedTableView.register(UINib(nibName: "FeedImageViewCell", bundle: nil), forCellReuseIdentifier: "CellNotDesc")
            feedTableView.register(UINib(nibName: "FeedViewCell", bundle: nil), forCellReuseIdentifier: "CellNotImage")
        }
        else
        {
            feedTableView.register(UINib(nibName: "FeedImageViewCellIPad", bundle: nil), forCellReuseIdentifier: "CellNotDescIPad")
            feedTableView.register(UINib(nibName: "FeedViewCellIPad", bundle: nil), forCellReuseIdentifier: "CellNotImageIPad")
        }
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControl.Event.valueChanged)
        self.feedTableView.insertSubview(refreshControl, at: 0)
        
        
        
        
        self.view.addSubview(feedTableView)
        
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
        
        
        self.textLabel?.text = siteItemSelected.siteItemName
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SelectionChange(siteItemSelected, autoFreshing: false)
        
        //self.navigationController?.navigationBar.isHidden = true
        //AddNativeExpressAds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        SelectionChange(siteItemSelected, autoFreshing: true)
        
    }
    
     
    fileprivate func SelectionChange(_ siteItem:SiteItem, autoFreshing:Bool)
    {
        if(siteItem.siteItemURL?.contains("http"))!
        {
            siteItem.siteItemURL=Utils.enCryptString2(siteItem.siteItemURL!)
        }
        self.feedTableView.tableHeaderView=nil
        //self.feedDataList = realm.objects(FeedData.self).filter("siteItemID = %@",siteItemSelected.siteItemID).sorted(by: [SortDescriptor(keyPath: "loadTime",ascending: true),SortDescriptor(keyPath: "timeStamp",ascending: true)])
        //self.feedTableView.reloadData()
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
            if(2==3)//Download feed from theallatest's server
            {
            }
            else
            {
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
                if(siteItem.isFavorite==1)
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
                do{
                    self.httpClient.doGet(request) { (data, error, httpStatusCode) -> Void in
                        if (httpStatusCode == nil || httpStatusCode!.rawValue != HTTPStatusCode.ok.rawValue)
                        {
                            self.DownloadError(autoFreshing)
                        }
                        
                        else {
                            //Read JSON response in seperate thread
                             
                                
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
                                            let matched=feedLink.matchesForRegexInText("href=\"([^']*)\"", text: content)
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
                                                let imgLinks = feedDescription.matchesForRegexInText("(http://[^\\s]+(.jpg|.png))", text: feedDescription)
                                                if(imgLinks.count>0)
                                                {
                                                    imgFeed=imgLinks[0]
                                                }
                                            }
                                            
                                            feedDescription=feedDescription.subStringFromTwoTag("[CDATA[", endTag: "]]")
                                        }
                                        if(imgFeed=="" || imgFeed.contains("http")==false)
                                        {
                                            let imgLinks = feedDescription.matchesForRegexInText("(http://[^\\s]+(.jpg|.png))", text: content)
                                            if(imgLinks.count>0)
                                            {
                                                imgFeed=imgLinks[0]
                                            }
                                            else
                                            {
                                                
                                                let imgLinks = feedDescription.matchesForRegexInText("\\s*(?i)src\\s*=\\s*(\"([^\"]*\")|'[^']*'|([^'\">\\s]+))", text: content)
                                                if(imgLinks.count>0)
                                                {
                                                    imgFeed=imgLinks[0]
                                                    imgFeed=imgFeed.replacingOccurrences(of: "src=", with: "").replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
                                                }
                                                
                                                else if(content.contains("media:content type=\"image/jpeg\""))
                                                {
                                                    let mediaContent=content.subStringFromTwoTag("<media:content", endTag: "</media:content>")
                                                    let imgLinks = feedDescription.matchesForRegexInText("\\s*(?i)url\\s*=\\s*(\"([^\"]*\")|'[^']*'|([^'\">\\s]+))", text: content)
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
                                        feedDescription=String(htmlEncodedString: feedDescription) ?? ""
                                        feedTitle=String(htmlEncodedString: feedTitle) ?? ""
                                        let feedIsExist=Utils.checkFeedIsExist(siteItemID: self.siteItemSelected.siteItemID ?? "", link: self.getFullURL(url: feedLink, domainURL: siteItem.siteItemURL!) )
                                        if(!feedIsExist)
                                        {
                                            
                                             
                                            let mFeed=FeedData()
                                                
                                                mFeed.timeStamp=Int(Date().timeIntervalSince1970)
                                                mFeed.siteItemID=self.siteItemSelected.siteItemID
                                                mFeed.siteID=self.siteItemSelected.siteID
                                                mFeed.loadTime=currentTime
                                                mFeed.title=feedTitle
                                                mFeed.pubDateString=pubDateString
                                                mFeed.link=self.getFullURL(url: feedLink, domainURL: siteItem.siteItemURL!)
                                                mFeed.feedDescription=feedDescription
                                                mFeed.linkImage=imgFeed
                                                let mRealm =  try! Realm()
                                            try! mRealm.write({
                                                mRealm.add(mFeed)
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
                                        let matched=feedLink.matchesForRegexInText("href=\"([^']*)\"", text: feedLink)
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
                                            let imgLinks = feedDescription.matchesForRegexInText("(http://[^\\s]+(.jpg|.png))", text: content)
                                            if(imgLinks.count>0)
                                            {
                                                imgFeed=imgLinks[0]
                                            }
                                        }
                                        
                                        if(imgFeed=="" || imgFeed.contains("http")==false)
                                        {
                                            let imgLinks = feedDescription.matchesForRegexInText("(http://[^\\s]+(.jpg|.png))", text: content)
                                            if(imgLinks.count>0)
                                            {
                                                imgFeed=imgLinks[0]
                                            }
                                            else
                                            {
                                                
                                                let imgLinks = feedDescription.matchesForRegexInText("\\s*(?i)src\\s*=\\s*(\"([^\"]*\")|'[^']*'|([^'\">\\s]+))", text: content)
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
                                        let feedIsExist=Utils.checkFeedIsExist(siteItemID: self.siteItemSelected.siteItemID ?? "", link: self.getFullURL(url: feedLink, domainURL: siteItem.siteItemURL!) )
                                        if(!feedIsExist)
                                        {
                                            try! self.realm.write
                                            {
                                                let mFeed=FeedData()
                                                mFeed.timeStamp=Int(Date().timeIntervalSince1970)
                                                mFeed.siteItemID=self.siteItemSelected.siteID
                                                mFeed.siteID=self.siteItemSelected.siteID
                                                mFeed.loadTime=currentTime
                                                mFeed.title=feedTitle
                                                mFeed.pubDateString=pubDateString
                                                mFeed.link=self.getFullURL(url: feedLink, domainURL: siteItem.siteItemURL!)
                                                mFeed.feedDescription=feedDescription
                                                mFeed.linkImage=imgFeed
                                                self.realm.add(mFeed)
                                               
                                            }
                                        }
                                        feedXML=feedXML.replacingOccurrences(of: "<entry>"+content+"</entry>", with: "")
                                        
                                    }
                                    
                                }
                                // Post notification to update datasource of a given ViewController/UITableView
                                DispatchQueue.main.async {
                                    self.stopDownloadFeed(autoFreshing)
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                }
                            
                            
                        }
                    }
                }
                catch
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    DownloadError(autoFreshing)
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
            self.feedTableView.tableHeaderView=lb
            self.feedTableView.reloadData()
            self.stopDownloadFeed(autoFreshing)
            
            
        }
        
        
    }
    fileprivate func stopDownloadFeed(_ autoFreshing:Bool)
    {
        self.sideMenuController()?.sideMenu?.menuViewController.viewDidLoad()
        let mRealm =  try! Realm()
        //self.feedDataList = mRealm.objects(FeedData.self).filter("siteItemID = %@",siteItemSelected.siteItemID).sorted(by: [SortDescriptor(keyPath: "loadTime",ascending: true),SortDescriptor(keyPath: "timeStamp",ascending: true)])
        print(self.feedDataList.count)
        //self.feedTableView.reloadData()
        self.indicator.stopAnimating()
        if(autoFreshing)
        {
            self.refreshControl.endRefreshing()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return feedDataList.count
    }
    /* func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     var feedData:FeedData
     feedData=feedDataList[(indexPath as NSIndexPath).row]
     if(feedData.linkImage != nil )
     {
     return rowHeightImage
     }
     else
     {
     return rowHeightNotImage
     }
     }*/
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
                    /*
                    let indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                    self.feedTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    */
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
    }
    @objc func labeTitlelAction(sender:UITapGestureRecognizer)
    {
        
        
        openWebView(sender.view?.tag)
        
    }
    func openWebView(_ tag:Int!)
    {
        var feedData:FeedData
        feedData=feedDataList[tag]
        try! realm.write({
            feedData.isRead=1
        })
        
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
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
