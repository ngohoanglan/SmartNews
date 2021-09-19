//
//  SelectNewspapersViewController.swift
//  VietNamNewspapers
//
//  Created by admin on 3/30/16.
//  Copyright © 2016 admin. All rights reserved.
//
import ObjectMapper
import Nuke
import FirebaseMessaging
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


class SelectNewspapersViewController: UIViewController, UITableViewDelegate,
UITableViewDataSource, DownloadDelegate {
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    
    @IBOutlet weak var btImportNewspapers: UIButton!
    var passOject:UserDefaults!
    fileprivate var httpClient:HTTPClient!
    var country_code_selected:String!
    let HostingURL = "http://thealllatestnews.com/Resources/CountryList/";
    @IBOutlet weak var tableViewNewspapers: UITableView!
    let indicator=UIActivityIndicatorView(style: .gray)
    var newspapersList:Array<SiteSource>=[]
    var serverDatabaseVersion:Int=0
    var setting=Settings()
    var currentSiteName :String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title=NSLocalizedString("select_newspapers", comment: "")
        btImportNewspapers.configure(color:  .white,
                                  font:  UIFont.systemFont(ofSize: 16),
                                  cornerRadius: 8,
                                  borderColor:  UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1),
                                  backgroundColor:  UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1),
                                  borderWidth: 2.0)
        passOject=UserDefaults()
        
        btImportNewspapers.setTitle(NSLocalizedString("import_newspapers", comment: ""), for: UIControl.State())
        country_code_selected=passOject.object(forKey: "country_code_key") as! String
        let  HostingDataSourceURL=HostingURL+country_code_selected+"/database.txt"
        self.tableViewNewspapers.delegate=self
        self.tableViewNewspapers.dataSource=self
        self.tableViewNewspapers.allowsSelection = false
        self.tableViewNewspapers.separatorStyle = .singleLine
        self.tableViewNewspapers.register(UINib(nibName: "SelectNewspaperTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectNewspaperCell")
        indicator.center=view.center
        indicator.hidesWhenStopped=true
        indicator.startAnimating()
        view.addSubview(indicator)
        
        if let URL = URL(string: HostingDataSourceURL) {
            do {
                let result = try String(contentsOf: URL)
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    
                    
                    let resultXML=Utils.deCryptString(result) as Any
                    let rootItem=Mapper<SitesSource>().map(JSONString: resultXML as! String)
                    let newspapers=(rootItem?.siteSource)!
                    
                    for site in newspapers
                    {
                        if site.m != nil && site.m == 2 {
                            //Site was deleted
                        }
                        else
                        {
                            self.newspapersList.append(site)
                        }
                    }
                    if(rootItem?.version==nil)
                    {
                        self.serverDatabaseVersion=1
                    }
                    else
                    {
                        self.serverDatabaseVersion=(rootItem?.version)!
                    }
                    DispatchQueue.main.async {
                        //  self.tableView.reloadData()
                        self.tableViewNewspapers.reloadData()
                        self.indicator.stopAnimating()
                    }
                    
                }
                //)
                
            }
            catch
            {
                let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("error_message", comment: ""), preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true, completion:nil)
            }
        }
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newspapersList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectNewspaperCell", for: indexPath)
            as! SelectNewspaperTableViewCell
        //as! UITableViewCell
        let newspaper=newspapersList[(indexPath as NSIndexPath).row]
        let iconURL="http://www.google.com/s2/favicons?domain_url="+newspaper.url!
        
        //add button event clicked
        /*
         cell.btnCheckBox.addTarget(self, action: #selector(SelectNewspapersViewController.buttonClicked(_:)), for: UIControl.Event.touchUpInside)
         */
        cell.switchSelect.tag=(indexPath as NSIndexPath).row
        cell.switchSelect.isOn=newspaper.isCheck
        //cell.imgNewspaper.load(iconURL)
        cell.lbName.text=newspaper.name
        Nuke.loadImage(with: URL(string: iconURL), into: cell.imgIcon)
        
        /*
         let myCompletionHandler: (URL?, UIImage?, NSError?,CacheType?) -> Void = { (data, response, error,cachtype) in
         // this is where the completion handler code goes
         if response != nil
         {
         
         self.newspapersList[(indexPath as NSIndexPath).row].iconArray=UIImagePNGRepresentation(response!)
         }
         }
         
         cell.imgNewspaper.load(iconURL, placeholder: cell.imgNewspaper.image, completionHandler: myCompletionHandler)*/
        return cell
    }
    
    //hander button event click
    @objc func buttonClicked(_ sender:CheckBox) {
        newspapersList[sender.tag].isCheck=sender.isChecked
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
    }
    
    
    @IBAction func btImportNewspaper(_ sender: AnyObject) {
        
        var siteController:SiteController
        siteController=SiteController.shareInstance
        var siteItemController:SiteItemController
        siteItemController=SiteItemController.shareInstance
        Messaging.messaging().unsubscribe(fromTopic: "/topics/"+self.setting.getCountryCodeSelectedKey())
        
        
        do {
            
            KRProgressHUD.show(progressHUDStyle: KRProgressHUDStyle.appColor, maskType: nil, activityIndicatorStyle: KRProgressHUDActivityIndicatorStyle.white, font: nil, message: "", image: nil)
            
            DispatchQueue.global(qos: .userInitiated).async(execute: {
                
                for site in self.newspapersList
                {
                    if(site.isCheck){
                        self.totalItemsChecked += 1
                    }
                }
                var siteAddDefault=1
                let siteList=siteController.getAllSitesByCountry(self.country_code_selected)
                if(siteList.count==0)
                {
                    siteAddDefault=1
                }
                else
                {
                    siteAddDefault=0
                }
                if(self.totalItemsChecked>0)
                {
                    
                    self.setting.setDatabaseVersion(self.serverDatabaseVersion)
                    self.setting.setCountryCodeSelectedKey(self.country_code_selected)
                    
                }
                
                var position:Int=siteController.getSiteMaxPosition()+1
                for site in self.newspapersList
                {
                    if(site.isCheck){
                        
                        DispatchQueue.main.async(execute: {
                            self.counter += 1
                            self.currentSiteName=site.name!
                            return
                        })
                        
                        
                        var fieldDetails=[String:NSObject]()
                        let siteID:String=UUID().uuidString
                        fieldDetails[SiteAttributes.isDefault.rawValue]=siteAddDefault as NSObject?
                        fieldDetails[SiteAttributes.siteID.rawValue]=siteID as NSObject?
                        fieldDetails[SiteAttributes.siteName.rawValue]=site.name as NSObject?
                        fieldDetails[SiteAttributes.siteURL.rawValue]=site.url as NSObject?
                        fieldDetails[SiteAttributes.countryCode.rawValue]=self.country_code_selected as NSObject?
                        fieldDetails[SiteAttributes.modify.rawValue]=site.m as NSObject?
                        fieldDetails[SiteAttributes.position.rawValue]=position as NSObject?
                        let IconUrl="http://www.google.com/s2/favicons?domain_url="+site.url!
                        fieldDetails[SiteAttributes.siteIconPath.rawValue]=IconUrl as NSObject?
                        if(site.iconArray?.count>0)
                        {
                            fieldDetails[SiteAttributes.iconArray.rawValue]=site.iconArray as NSObject?
                        }
                        else
                        {
                        }
                        if(siteController.IsSiteExist(site.url!, name: site.name!) == false)
                        {
                            DispatchQueue.main.sync(execute: {
                                siteController.saveSite(fieldDetails)
                            })
                            
                        }
                        position += 1
                        if(site.leaf==1)
                        {
                            var siteItemFields=[String:NSObject]()
                            siteItemFields[SiteItemAttributes.siteItemID.rawValue] = UUID().uuidString as NSObject?
                            siteItemFields[SiteItemAttributes.siteID.rawValue]=siteID as NSObject?
                            siteItemFields[SiteItemAttributes.siteItemName.rawValue]=site.name as NSObject?
                            siteItemFields[SiteItemAttributes.isFavorite.rawValue]=site.direct as NSObject?
                            siteItemFields[SiteItemAttributes.position.rawValue]=0 as NSObject?
                            siteItemFields[SiteItemAttributes.encoding.rawValue]=site.encoding as NSObject?
                            siteItemFields[SiteItemAttributes.isDefault.rawValue]=site._default as NSObject?
                            siteItemFields[SiteItemAttributes.siteItemNameBackup.rawValue]=site.name as NSObject?
                            let urlSiteItem=site.url as NSObject?
                            let urlEncoded=Utils.enCryptString2(urlSiteItem as! String)
                            siteItemFields[SiteItemAttributes.siteItemURL.rawValue]=urlEncoded as NSObject?
                            siteItemFields[SiteItemAttributes.siteItemURLBackup.rawValue]=urlEncoded as NSObject?
                            siteItemFields[SiteItemAttributes.position.rawValue]=0 as NSObject?
                            
                            if(siteItemController.IsSiteItemExist(site.url!) == false)
                            {
                                
                                DispatchQueue.main.sync(execute: {
                                    siteItemController.saveSiteItem(siteItemFields)
                                })
                            }
                        }
                        else
                        {
                            var siteItemPosition:Int=0
                            for siteItem in site.siteItemSource!
                            {
                                var siteItemFields=[String:NSObject]()
                                siteItemFields[SiteItemAttributes.siteItemID.rawValue] = UUID().uuidString as NSObject?
                                siteItemFields[SiteItemAttributes.siteID.rawValue]=siteID as NSObject?
                                siteItemFields[SiteItemAttributes.siteItemName.rawValue]=siteItem.name as NSObject?
                                siteItemFields[SiteItemAttributes.isFavorite.rawValue]=siteItem.direct as NSObject?
                                siteItemFields[SiteItemAttributes.position.rawValue]=siteItemPosition as NSObject?
                                siteItemFields[SiteItemAttributes.encoding.rawValue]=siteItem.encoding as NSObject?
                                siteItemFields[SiteItemAttributes.isDefault.rawValue]=siteItem._default as NSObject?
                                siteItemFields[SiteItemAttributes.siteItemNameBackup.rawValue]=siteItem.name as NSObject?
                                let urlSiteItem=siteItem.url as NSObject?
                                let urlEncoded=Utils.enCryptString2(urlSiteItem as! String)
                                siteItemFields[SiteItemAttributes.siteItemURL.rawValue]=urlEncoded as NSObject?
                                siteItemFields[SiteItemAttributes.siteItemURLBackup.rawValue]=urlEncoded as NSObject?
                                siteItemFields[SiteItemAttributes.position.rawValue]=siteItemPosition as NSObject?
                                
                                if(siteItemController.IsSiteItemExist(siteItem.url!) == false)
                                {
                                    DispatchQueue.main.sync(execute: {
                                        siteItemController.saveSiteItem(siteItemFields)
                                    })
                                    
                                }
                                siteItemPosition += 1
                                
                            }
                        }
                    }
                }
                
                
                // Post notification to update datasource of a given ViewController/UITableView
                DispatchQueue.main.sync {
                    KRProgressHUD.dismiss()
                    
                    let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "SiteListStoryBoard") as? SiteListTableViewController
                    self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
                }
            }
            )
            
            
            
        }
        catch
        {
            let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("error_message", comment: ""), preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
            
            
        }
        
        
        
    }
    
    func addProgressControls() {
        
        // Create Progress View Control
        
        progressView = UIProgressView(progressViewStyle: UIProgressView.Style.default)
        progressView?.center = self.view.center
        progressView!.setProgress(0, animated: true)
        view.addSubview(progressView!)
        
        // Add Label
        
        progressLabel = UILabel()
        let frame = CGRect(x: view.center.x-50, y: view.center.y - 50, width: 300, height: 50)
        progressLabel?.frame = frame
        
        view.addSubview(progressLabel!)
        
    }
    
    var totalItemsChecked:Int=0
    var counter:Int = 0 {
        didSet {
            
            let fractionalProgress = 100 * (counter)/(totalItemsChecked)
            let animated = counter != 0
            KRProgressHUD.updateLabel(("\(counter)/\(totalItemsChecked)        \(fractionalProgress)%"), title: currentSiteName)
            
            
        }
    }
    //implement delegate
    func processingWasFinished()
    {
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    /*
     func enCryptString(_ input:String) -> String
     {
     var input = input
     
     let char = "d"
     let MIN_c = String(char).utf8[String(char).utf8.startIndex]
     
     let char2 = "v"
     let MAX_c = String(char2).utf8[String(char2).utf8.startIndex]
     
     let char3 = "n"
     let MIN_C = String(char3).utf8[String(char3).utf8.startIndex]
     
     let char4 = "m"
     let MAX_C = String(char4).utf8[String(char4).utf8.startIndex]
     
     let char5 = "3"
     let MIN_0 = String(char5).utf8[String(char5).utf8.startIndex]
     
     let char6 = "6"
     let MAX_0 = String(char6).utf8[String(char6).utf8.startIndex]
     
     var result:String=""
     input=input.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/").replacingOccurrences(of: ",", with: "=")
     let encodeData=Data(base64Encoded: input, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
     for c in input.characters
     {
     
     let c_int=String(c).utf8[String(c).utf8.startIndex]
     
     if(c_int>=MIN_0&&c_int<=MAX_0)
     {
     
     let e=MAX_0+MIN_0-c_int
     let cc:String = String(UnicodeScalar(e))
     result=result+cc
     }
     else if(c_int >= MIN_C && c_int <= MAX_C)
     {
     let e = MAX_C + MIN_C - c_int
     let cc:String = String(UnicodeScalar(e))
     result=result+cc
     }
     else if (c_int >= MIN_c && c_int <= MAX_c) {
     let e = MAX_c + MIN_c - c_int
     let cc:String = String(UnicodeScalar(e))
     result=result+cc
     }
     else
     {
     result.append(c)
     }
     }
     
     return result
     }
     func deCryptString(_ input : String) -> String {
     var input = input
     
     let char = "d"
     let MIN_c = String(char).utf8[String(char).utf8.startIndex]
     
     let char2 = "v"
     let MAX_c = String(char2).utf8[String(char2).utf8.startIndex]
     
     let char3 = "n"
     let MIN_C = String(char3).utf8[String(char3).utf8.startIndex]
     
     let char4 = "m"
     let MAX_C = String(char4).utf8[String(char4).utf8.startIndex]
     
     let char5 = "3"
     let MIN_0 = String(char5).utf8[String(char5).utf8.startIndex]
     
     let char6 = "6"
     let MAX_0 = String(char6).utf8[String(char6).utf8.startIndex]
     
     var result:String=""
     input=input.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/").replacingOccurrences(of: ",", with: "=")
     //var lengtStr=input.characters.count
     
     for c in input.characters
     {
     
     let c_int=String(c).utf8[String(c).utf8.startIndex]
     
     if(c_int>=MIN_0&&c_int<=MAX_0)
     {
     
     let e=MAX_0+MIN_0-c_int
     let cc:String = String(UnicodeScalar(e))
     result=result+cc
     }
     else if(c_int >= MIN_C && c_int <= MAX_C)
     {
     let e = MAX_C + MIN_C - c_int
     let cc:String = String(UnicodeScalar(e))
     result=result+cc
     }
     else if (c_int >= MIN_c && c_int <= MAX_c) {
     let e = MAX_c + MIN_c - c_int
     let cc:String = String(UnicodeScalar(e))
     result=result+cc
     }
     else
     {
     result.append(c)
     }
     }
     
     
     
     let decodedData = Data(base64Encoded: result, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
     let decodedString = NSString(data: decodedData!, encoding: String.Encoding.utf8.rawValue) as! String
     return decodedString
     }
     */
}
