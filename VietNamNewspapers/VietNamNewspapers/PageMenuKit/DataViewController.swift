//
//  DataViewController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 7/25/17.
//  Copyright © 2017 admin. All rights reserved.
//
import ImageLoader
import Foundation
import UIKit
import GoogleMobileAds
//import ImageLoader
class DataViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate
{
    /*
    var shouldShowSearchResults = false
    var searchController: UISearchController = ({
        
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.searchBarStyle = .minimal
        controller.searchBar.sizeToFit()
        return controller
    })()
    */
  let refreshControl = UIRefreshControl()
    var feedTableView: UITableView = UITableView()
  
    fileprivate var siteItemController:SiteItemController!
    fileprivate var feedDataController:FeedDataController!
    fileprivate var feedDataList:Array<FeedData>=[]
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
   /*
    
   var rowHeightImage:CGFloat=175.0
    var rowHeightNotImage:CGFloat=100.0
    var cellHeight:CGFloat=60.0
    var cellFontSize:CGFloat=13.0
    */
    var isExpandDescription:Bool=false
    
    public private(set) var textLabel: UILabel? = nil
    public   var _siteItemSelected: SiteItem!
    
    //Ads
    var adsToLoad = [GADNativeExpressAdView]()
    let adsInterval=8
    let adsViewHeight=175
    let adsViewWidth=370
    //
    
    override func setup() {
        super.setup()
      
        siteItemController=SiteItemController.shareInstance
        feedDataController=FeedDataController.shareInstance
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
         siteItemSelected=_siteItemSelected
         self.title = siteItemSelected.siteItemName
       
    }
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        isExpandDescription=setting.getExpandDescription()
       
        cellFontSize=CGFloat(setting.getTextSize())
        cellIPadFontSize = CGFloat(setting.getTextSize())+4
        /*
        cellHeight=60 + (60*percentAdd)/100
        cellFontSize=13 + (13*percentAdd)/100
        imageSize=75.0 + (75.0*percentAdd)/100
        rowHeightImage=175.0+(175.0*percentAdd)/100*2
         rowHeightNotImage=75.0+(75*percentAdd)/100*2
        */
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
        refreshControl.addTarget(self, action: #selector(SiteDetailTableViewController.refreshControlAction(_:)), for: UIControl.Event.valueChanged)
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
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        SelectionChange(siteItemSelected, autoFreshing: true)
        
    }
    
    func AddNativeExpressAds()
    {
        var index=4
        let size=GADAdSizeFromCGSize(CGSize(width: adsViewWidth, height: adsViewHeight))
        while index<feedDataList.count{
            let adView=GADNativeExpressAdView(adSize: size)
            adView?.adUnitID="ca-app-pub-3108267494433171/3899687304"
            adView?.rootViewController=self
            feedTableView.insertSubview(adView!, at: index)
            index+=adsInterval
        }
    
    }
    fileprivate func SelectionChange(_ siteItem:SiteItem, autoFreshing:Bool)
    {
        if(siteItem.siteItemURL?.contains("http"))!
        {
            siteItem.siteItemURL=Utils.enCryptString2(siteItem.siteItemURL!)
        }
        
        self.feedTableView.tableHeaderView=nil
        feedDataList=feedDataController.getFeedDataBySiteItemId(siteItem.siteItemID! as NSString)
        //
        self.feedTableView.reloadData()
        
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
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    
                    do {
                        var result=""
                        let HostingDataSourceURL="http://thealllatestnews.com/api/FeedDatas/"+siteItem.siteItemURL!
                        let urlFeed = URL(string: HostingDataSourceURL)
                        
                        try result = String(contentsOf: urlFeed!)
                        //let rootItem=Mapper<Feeds>().map(JSONString: result as! String)
                        let feeds:[FeedJson]=[]//(rootItem.feedsJson)!
                        for feed in feeds
                        {
                            if(!(feed.Title?.isEmpty)! && !(feed.Link?.isEmpty)!)
                            {
                                let feedIsExist=self.feedDataController.getFeedDataBySiteItemIdAndLink(self.siteItemSelected.siteItemID! as NSString, link: feed.Link as! NSString )
                                if(feedIsExist.count==0 )
                                {
                                    var fieldDetails=[String:NSObject]()
                                    let feedID:String=UUID().uuidString
                                    fieldDetails[FeedDataAttributes.feedID.rawValue]=feedID as NSObject?
                                    fieldDetails[FeedDataAttributes.timeStamp.rawValue]=Date().timeIntervalSince1970 as NSObject?
                                    fieldDetails[FeedDataAttributes.siteID.rawValue]=self.siteItemSelected.siteID as NSObject?
                                    fieldDetails[FeedDataAttributes.siteItemID.rawValue]=self.siteItemSelected.siteItemID as NSObject?
                                    fieldDetails[FeedDataAttributes.loadTime.rawValue]=currentTime as NSObject?
                                    fieldDetails[FeedDataAttributes.title.rawValue]=feed.Title as NSObject?
                                    fieldDetails[FeedDataAttributes.pubDateString.rawValue]=feed.PubDate as NSObject?
                                    fieldDetails[FeedDataAttributes.link.rawValue]=feed.Link as NSObject?
                                    fieldDetails[FeedDataAttributes.feedDescription.rawValue]=feed.Description as NSObject?
                                    fieldDetails[FeedDataAttributes.linkImage.rawValue]=feed.ImgLink as NSObject?
                                    
                                    self.feedDataController.saveFeedData(fieldDetails)
                                }
                                
                            }
                        }
                    } catch {
                        print("Failed")
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.stopDownloadFeed(autoFreshing)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    })
                }
                
                
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
                                                    var mediaContent=content.subStringFromTwoTag("<media:content", endTag: "</media:content>")
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
        self.feedDataList=self.feedDataController.getFeedDataBySiteItemId(self.siteItemSelected.siteItemID! as NSString)
        
        self.feedTableView.reloadData()
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
        if(!btnExpandTapped)
        {
            feedData.isExpand=isExpandDescription
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
