//
//  SiteListTableViewController.swift
//  VietNamNewspapers
//
//  Created by admin on 2/22/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import MessageUI
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import ImageLoader
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


class SiteListTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate,ENSideMenuDelegate{
    var passOject:UserDefaults!
    let setting = Settings()
    var databaseServerVersion:Int=1
    @IBOutlet weak var tableViewSiteList: UITableView!
    var verticalPostionContent:CGFloat=0
    let admobFromServer:String="http://thealllatestnews.com/api/home"
     let HostingURL = "http://thealllatestnews.com/Resources/CountryList/";
    fileprivate var  siteController=SiteController.shareInstance
    fileprivate var  siteItemController=SiteItemController.shareInstance
    fileprivate var  feedDataController=FeedDataController.shareInstance
    
    fileprivate var siteList:Array<Site>=[]
     var serverDatabaseVersion:Int=0
     var pageMenuController: PMKPageMenuController? = nil
    var currentSiteName :String = ""
    var cellHeight:CGFloat=60.0
    var cellFontSize:CGFloat=25.0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAdmobKeyFromServer(serverURL: admobFromServer)
        tableViewSiteList.estimatedRowHeight = 60
        tableViewSiteList.rowHeight = UITableView.automaticDimension
        passOject=UserDefaults()
        if passOject.bool(forKey: "contentOffsetTableViewSiteList_key")
        {
            verticalPostionContent = passOject.value(forKey: "contentOffsetTableViewSiteList_key") as! CGFloat
        }
        self.navigationItem.title=NSLocalizedString("app_name", comment: "")
        self.tableViewSiteList.delegate=self
        self.tableViewSiteList.dataSource=self
        
        self.tableViewSiteList.setContentOffset(CGPoint(x: 0, y: verticalPostionContent), animated: false)
        self.sideMenuController()?.sideMenu?.delegate = self
        if(setting.getAppLaunchCount()>5 && setting.getRateApp()==false)
        {
            showRateMe()
        }
        cellHeight=60 + (60*setting.getPercentAddCellHeightBaseOnDevice())/100
        cellFontSize=25 + (25*setting.getPercentAddCellHeightBaseOnDevice())/100
        var backBarButton:UIBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem=backBarButton
     
       
    }
    override func viewWillAppear(_ animated: Bool) {
        let token = FIRInstanceID.instanceID().token()
        if(token != nil)
        {
            print("InstanceID token: \(token!)")
        }
        FIRMessaging.messaging().subscribe(toTopic: "/topics/"+self.setting.getCountryCodeSelectedKey())
       print("Subscribed to "+setting.getCountryCodeSelectedKey()+" topic")

        self.siteList=siteController.getAllSitesByCountry(self.setting.getCountryCodeSelectedKey())
        if(siteList.count>0 && setting.getAppLaunchCount()>1)
        {
            checkUpdateDB()
        }
        if(siteList.count==0)
        {
            let menuVC : CountryComboBoxListViewController = self.storyboard!.instantiateViewController(withIdentifier: "CountryListStoryBoard") as! CountryComboBoxListViewController
            
            // self.tableView.separatorStyle=UITableViewCellSeparatorStyle.None
            
            self.view.addSubview(menuVC.view)
            self.addChild(menuVC)
            menuVC.view.layoutIfNeeded()
            
            
            menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
                
            }, completion:nil)
            
            
        }

        /*
        if(siteList.count==0)
        {
            
            var siteController:SiteController
            siteController=SiteController.shareInstance
            var siteItemController:SiteItemController
            siteItemController=SiteItemController.shareInstance
           
            let  HostingDataSourceURL=HostingURL+setting.getCountryCodeSelectedKey()+"/database.txt"
           
            
            do {
                
                KRProgressHUD.show(progressHUDStyle: KRProgressHUDStyle.appColor, maskType: nil, activityIndicatorStyle: KRProgressHUDActivityIndicatorStyle.white, font: nil, message: "Data Processing", image: nil)
                
                DispatchQueue.global(qos: .userInitiated).async(execute: {
                    
                    
                    
                    if let URL = URL(string: HostingDataSourceURL) {
                        do {
                            let result = try String(contentsOf: URL)
                            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                                     
                                let resultXML=Utils.deCryptString(result) as Any
                                let rootItem=Mapper<SitesSource>().map(JSONString: resultXML as! String)
                                let newspapers=(rootItem?.siteSource)!
                                var position:Int=siteController.getSiteMaxPosition()+1
                                
                                if(rootItem?.version==nil)
                                {
                                    self.serverDatabaseVersion=1
                                }
                                else
                                {
                                    self.serverDatabaseVersion=(rootItem?.version)!
                                }
                                self.setting.setDatabaseVersion(self.serverDatabaseVersion)
                                for site in newspapers
                                {
                                    if(site.m != nil && site.m != 2){
                                        self.totalItemsChecked += 1
                                    }
                                }
                                for site in newspapers
                                {
                                    DispatchQueue.main.async(execute: {
                                        self.counter += 1
                                        self.currentSiteName=site.name!
                                        return
                                    })
                                    if site.m != nil && site.m == 2 {
                                        //Site was deleted
                                    }
                                    else
                                    {
                                        var fieldDetails=[String:NSObject]()
                                        let siteID:String=UUID().uuidString
                                        fieldDetails[SiteAttributes.isDefault.rawValue]=1 as NSObject
                                        fieldDetails[SiteAttributes.siteID.rawValue]=siteID as NSObject?
                                        fieldDetails[SiteAttributes.siteName.rawValue]=site.name as NSObject?
                                        fieldDetails[SiteAttributes.siteURL.rawValue]=site.url as NSObject?
                                        fieldDetails[SiteAttributes.countryCode.rawValue]=self.setting.getCountryCodeSelectedKey() as NSObject?
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
                                if(rootItem?.version==nil)
                                {
                                    self.serverDatabaseVersion=1
                                }
                                else
                                {
                                    self.serverDatabaseVersion=(rootItem?.version)!
                                }
                                DispatchQueue.main.async {
                                   KRProgressHUD.dismiss()
                                    self.siteList=siteController.getAllSitesByCountry(self.setting.getCountryCodeSelectedKey())
                                    self.tableViewSiteList.reloadData()
                                 
                                }
                                
                            }
                            //)
                            
                        }
                        catch
                        {
                            KRProgressHUD.dismiss()
                            let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("error_message", comment: ""), preferredStyle: .alert)
                            
                            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                                
                            }
                            alertController.addAction(OKAction)
                            
                            self.present(alertController, animated: true, completion:nil)
                        }
                    }
                    
                    
                 
                }
                )}
            
        }
        */
    }
    
    @IBAction func buttonShowMenu(_ sender: UIButton) {
        toggleSideMenuView()
    }
    
    
    @IBAction func btnEdit(_ sender: AnyObject) {
        self.tableViewSiteList.isEditing = !self.tableViewSiteList.isEditing
    }
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        // print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        //print("sideMenuWillClose")
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
        switch(index){
            
        case 0:
            let mapViewControllerObj = self.storyboard!.instantiateViewController(withIdentifier: "CountryListStoryBoard") as! CountryComboBoxListViewController
            self.navigationController?.pushViewController(mapViewControllerObj, animated: true)
          
            
            break
        case 1:
            var favoriteController = FavoriteArticleViewController()
            self.navigationController?.pushViewController(favoriteController, animated: true)
            
            break
        case 2:
            shareApp()
            break
        case 3:
            rateApp()
            break
        case 4:
            contactUs()
            break
        default:
            print("default\n", terminator: "")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newViewController = FeedsViewController()
        passOject.set(siteList[indexPath.row].siteID, forKey: "siteID_key")
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return siteList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!
        SiteListTableViewCell
        
        let site=siteList[(indexPath as NSIndexPath).row]
        // Configure the cell...
        if(site.iconArray?.count>0)
        {
            cell.imgIcon.image=UIImage(data: site.iconArray! as Data)
        }
        else
        {
            
            cell.imgIcon.load.request(with: site.siteIconPath!, onCompletion: { image, error, operation in
               
                if operation == .network {
                  
                    let transition = CATransition()
                    transition.duration = 0.5
                    transition.type = CATransitionType.fade
                    cell.imgIcon.layer.add(transition, forKey: nil)
                    cell.imgIcon.image = image
                    
                    site.iconArray=image!.pngData()
                    let newSiteUpdate:Dictionary<String,AnyObject> = [SiteAttributes.iconArray.rawValue : site.iconArray! as AnyObject]
                    self.siteController.updateSite(site, newSiteDetails: newSiteUpdate)
                }
            })

            /*
            let myCompletionHandler: (URL?, UIImage?, NSError?,CacheType?) -> Void = { (data, response, error,cachtype) in
                // this is where the completion handler code goes
                if response != nil{
                    site.iconArray=UIImagePNGRepresentation(response!)!
                    let newSiteUpdate:Dictionary<String,AnyObject> = [SiteAttributes.iconArray.rawValue : site.iconArray! as AnyObject]
                    self.siteController.updateSite(site, newSiteDetails: newSiteUpdate)
                }
            }
            cell.imgIcon.load(site.siteIconPath!, placeholder: cell.imgIcon.image, completionHandler: myCompletionHandler)
            */
        }
        cell.lbSiteName.text=site.siteName
        cell.lbSiteName.font=UIFont(name: cell.lbSiteName.font.fontName, size: cellFontSize)
        return cell
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let source=siteList[(sourceIndexPath as NSIndexPath).row]
        
        siteList.remove(at: (sourceIndexPath as NSIndexPath).row)
        siteList.insert(source, at: (destinationIndexPath as NSIndexPath).row)
        var index:Int=0
        for site in siteList
            
        {
            let newValueUpdate:Dictionary<String,AnyObject> = [SiteAttributes.position.rawValue : index as AnyObject]
            self.siteController.updateSite(site, newSiteDetails: newValueUpdate)
            index=index+1
        }
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let siteDelete=siteList[(indexPath as NSIndexPath).row]
            let mess=String.localizedStringWithFormat(NSLocalizedString("confirm_delete_newspaper", comment: ""), siteDelete.siteName! )
            let alert = UIAlertController(title: NSLocalizedString("delete_newspaper", comment: ""), message: mess, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
                
                //Delete to Database
                let feedDataController=FeedDataController.shareInstance
                let siteItemController=SiteItemController.shareInstance
                
                feedDataController.deleteFeedDataBySiteID(siteDelete.siteID! as NSString)
                siteItemController.deleteSiteItemsBySiteID(siteDelete.siteID! as NSString)
                self.siteController.deleteSite(siteDelete)
                
                self.siteList.remove(at: (indexPath as NSIndexPath).row)
                self.tableViewSiteList.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }))
            
            
            
            
        }
        
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        verticalPostionContent=tableViewSiteList.contentOffset.y
        if( segue.identifier=="sitelist_sitedetail")
        {
            let selectedIndex=((self.tableViewSiteList.indexPath(for: sender as! SiteListTableViewCell) as NSIndexPath?)?.row)! as Int
            passOject.set(siteList[selectedIndex].siteID, forKey: "siteID_key")
        }
        
        passOject.set(tableViewSiteList.contentOffset.y, forKey: "contentOffsetTableViewSiteList_key")
        
        
    }
    
    
    //Send Email function
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        let appVersion = Bundle.main .object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let appName = NSLocalizedString("app_name", comment: "")
        
        mailComposerVC.setToRecipients(["developer.seasoft@gmail.com"])
        mailComposerVC.setSubject("[ \(appName)- \(appVersion)] Send feedback")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    func rateApp(){
        
        let app_id=NSLocalizedString("app_id", comment: "") as String?
        
        // let url=URL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(app_id)")!
        let url=URL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id="+app_id!)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    func shareApp() {
        if let name = URL(string: "https://itunes.apple.com/us/app/myapp/\(NSLocalizedString("app_id", comment: ""))?ls=1&mt=8") {
            let objectsToShare = [name]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
            {
                if ( activityVC.responds(to: #selector(getter: UIViewController.popoverPresentationController)) ) {
                    activityVC.popoverPresentationController?.sourceView = view
                }
            }
            self.present(activityVC, animated: true, completion: nil)
        }
        else
        {
            // show alert for not available
        }
    }
    func contactUs()
    {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
    }
    func showRateMe() {
        
        
        let app_id=NSLocalizedString("app_id", comment: "") as String?
        let app_name=NSLocalizedString("app_name", comment: "") as String?
        let rateTitle=NSLocalizedString("rate_app", comment: "") as String?
        let rateMassage = String.localizedStringWithFormat(NSLocalizedString("rate_message", comment: ""), app_name! )
        
        let rateNow=NSLocalizedString("rate_now", comment: "") as String?
        let noThanks=NSLocalizedString("no_thanks", comment: "") as String?
        let later=NSLocalizedString("late", comment: "") as String?
        
        let urlRating=URL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id="+app_id!)!
        
        
        let alert = UIAlertController(title: rateTitle, message: rateMassage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: rateNow, style: UIAlertAction.Style.default, handler: { alertAction in
            UIApplication.shared.openURL(urlRating)
            alert.dismiss(animated: true, completion: nil)
            self.setting.setRateApp(true)
        }))
        alert.addAction(UIAlertAction(title: noThanks, style: UIAlertAction.Style.default, handler: { alertAction in
            //NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")
            alert.dismiss(animated: true, completion: nil)
            self.setting.setRateApp(true)
        }))
        alert.addAction(UIAlertAction(title: later, style: UIAlertAction.Style.default, handler: { alertAction in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    var countryCode:String!
   
    func checkUpdateDB()
    {
        var debug=false
        let current=Date()
        let currentSetting=setting.getCheckUpdateDB()
        if(setting.getCheckUpdateDB()<Date() || debug)
        {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                
                //Clear old data
                let feedController=FeedDataController.shareInstance
                feedController.updateClearAllImage(3)
                feedController.deleteFeedDataAfterDay(7)
                //End old data
                
                self.countryCode=self.setting.getCountryCodeSelectedKey()
                let  HostingDataSourceURL=self.HostingURL+self.countryCode+"/database.txt"
                let  httpClient:HTTPClient=HTTPClient()
                let request:URLRequest = URLRequest(url: URL(string: HostingDataSourceURL)!)
                
                do {
                    
                    
                    try  httpClient.doGet(request) { (data, error, httpStatusCode) -> Void in
                        
                        if (httpStatusCode == nil || httpStatusCode!.rawValue != HTTPStatusCode.ok.rawValue)
                        {
                            
                        }
                        else
                        {
                            let result=NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                            //let selectNewspapers : SelectNewspapersViewController=SelectNewspapersViewController()
                            let resultXML=Utils.deCryptString(result)
                            let rootItem=Mapper<SitesSource>().map(JSONString: resultXML)
                            self.setting.setCheckUpdateDB(Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
                            
                            if(rootItem?.version==nil)
                            {
                                self.databaseServerVersion=1
                            }
                            else
                            {
                                self.databaseServerVersion=(rootItem?.version)!
                                
                            }
                            
                            var databaseLocalVersion=self.setting.getDatabaseVersion()
                            if(self.databaseServerVersion>databaseLocalVersion || debug)
                            {
                                let current=self.setting.getdatabaseVersionIgnoreKey()
                                let local=self.setting.getDatabaseVersion()
                                
                                if(self.setting.getdatabaseVersionIgnoreKey()<self.databaseServerVersion || debug)
                                {
                                    var siteAdd:String=""
                                    var siteUpdate:String=""
                                    var siteDelete:String=""
                                    
                                    var newspapersList:Array<SiteSource>=[]
                                    var newspapersDeleteList:Array<SiteSource>=[]
                                    var newspapersLocalDeleteList:Array<Site>=[]
                                    var newspapers=(rootItem?.siteSource)!
                                    
                                    for site in newspapers
                                    {
                                        if site.m != nil && site.m == 2 {
                                            if(self.siteController.IsSiteExist(site.url!, name: site.name!))
                                            {
                                                siteDelete=siteDelete+site.name!+","
                                                newspapersDeleteList.append(site)
                                            }
                                        }
                                        else
                                        {
                                            newspapersList.append(site)
                                        }
                                    }
                                    let siteLocalList=self.siteController.getAllSitesByCountry(self.setting.getCountryCodeSelectedKey())
                                    for siteLocal in siteLocalList
                                    {
                                        var isLocal=false
                                        for site in newspapers
                                        {
                                            if(siteLocal.siteURL==site.url)
                                            {
                                                isLocal=true
                                            }
                                        }
                                        if(isLocal==false && siteLocal.isDefault==1)
                                        {
                                           siteDelete=siteDelete+siteLocal.siteName!+","
                                            newspapersLocalDeleteList.append(siteLocal)
                                        }
                                    }
                                    
                                    
                                    for site in newspapersList
                                    {
                                        if(site.m == 0 && self.siteController.IsSiteExist(site.url!, name: site.name!) == false){
                                            siteAdd=siteAdd+site.name!+","
                                            
                                        }
                                        else if(site.m==1)
                                        {
                                            siteUpdate=siteUpdate+site.name!+","
                                        }
                                        else if(site.m==2)
                                        {
                                            siteDelete=siteDelete+site.name!+","
                                        }
                                    }
                                    
                                    
                                    
                                    
                                    let updateTitle=NSLocalizedString("update_database", comment: "") as String?
                                    let updateMassage = NSLocalizedString("update_message", comment: "")as String?
                                    let update_details_message="Details:\nNew: "+siteAdd+"\n"+"Updated: "+siteUpdate+"\n"+"Deleted: "+siteDelete
                                    let updateMassageFinal=updateMassage!+"\n"+update_details_message
                                    let updateNow=NSLocalizedString("update_now", comment: "") as String?
                                    let noThanks=NSLocalizedString("no_thanks", comment: "") as String?
                                    let later=NSLocalizedString("late", comment: "") as String?
                                    
                                    var alert = UIAlertController(title: updateTitle, message: updateMassageFinal, preferredStyle: UIAlertController.Style.alert)
                                    
                                    
                                    
                                    
                                    alert.addAction(UIAlertAction(title: updateNow, style: UIAlertAction.Style.default, handler: { alertAction in
                                        
                                        alert.dismiss(animated: true, completion: nil)
                                        // self.setting.setCheckUpdateDB(Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
                                        
                                        self.UpdateDatabase(newspapersList,newspapersDeleteList: newspapersDeleteList,newspapersLocalDeleteList: newspapersLocalDeleteList)
                                        self.setting.setDatabaseVersion(self.databaseServerVersion)
                                        
                                    }))
                                    alert.addAction(UIAlertAction(title: noThanks, style: UIAlertAction.Style.default, handler: { alertAction in
                                        
                                        alert.dismiss(animated: true, completion: nil)
                                        // self.setting.setCheckUpdateDB(Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
                                        self.setting.setdatabaseVersionIgnoreKey(self.databaseServerVersion)
                                    }))
                                    alert.addAction(UIAlertAction(title: later, style: UIAlertAction.Style.default, handler: { alertAction in
                                        alert.dismiss(animated: true, completion: nil)
                                        self.setting.setCheckUpdateDB(Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }
                            }
                        }
                        
                    }
                } catch let fetchError as NSError  {
                    
                    print("retrieveById error: \(fetchError.localizedDescription)")
                }
            }
            //)
        }
    }
    var totalItemsChecked:Int=0
    var counter:Int = 0 {
        didSet {
            
            let fractionalProgress = 100 * (counter)/(totalItemsChecked)
           
            KRProgressHUD.updateLabel(("\(counter)/\(totalItemsChecked)        \(fractionalProgress)%"), title: currentSiteName)
        }
    }
    
    
    func UpdateDatabase(_ newspapersList:Array<SiteSource>, newspapersDeleteList:Array<SiteSource>,newspapersLocalDeleteList:Array<Site>)
    {
        let newspapersList = newspapersList
        
        KRProgressHUD.show(progressHUDStyle: KRProgressHUDStyle.appColor, maskType: nil, activityIndicatorStyle: KRProgressHUDActivityIndicatorStyle.white, font: nil, message: "", image: nil)
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            
            for site in newspapersDeleteList
            {
                let siteDelete=self.siteController.getSiteByURL(site.url!)
                self.feedDataController.deleteFeedDataBySiteID(siteDelete.siteID! as NSString)
                self.siteItemController.deleteSiteItemsBySiteID(siteDelete.siteID! as NSString)
                self.siteController.deleteSite(siteDelete)
                
            }
            for siteLocal in newspapersLocalDeleteList
            {
                self.feedDataController.deleteFeedDataBySiteID(siteLocal.siteID! as NSString)
                self.siteItemController.deleteSiteItemsBySiteID(siteLocal.siteID! as NSString)                
                self.siteController.deleteSite(siteLocal)
            }
            for site in newspapersList
            {
                if(site.isCheck){
                    self.totalItemsChecked += 1
                }
            }
            var position:Int=self.siteController.getSiteMaxPosition()+1
            for site in newspapersList
            {
                if(site.isCheck){
                    
                    DispatchQueue.main.async(execute: {
                        self.counter += 1
                        return
                    })
                    
                    if(site.m==1)
                    {
                        let siteDelete=self.siteController.getSiteByURL(site.url!)
                        self.feedDataController.deleteFeedDataBySiteID(siteDelete.siteID! as NSString)
                        self.siteItemController.deleteSiteItemsBySiteID(siteDelete.siteID! as NSString)
                        self.siteController.deleteSite(siteDelete)
                        
                        
                    }
                    
                    var fieldDetails=[String:NSObject]()
                    let siteID:String=UUID().uuidString
                    fieldDetails[SiteAttributes.siteID.rawValue]=siteID as NSObject?
                    fieldDetails[SiteAttributes.siteName.rawValue]=site.name as NSObject?
                    fieldDetails[SiteAttributes.siteURL.rawValue]=site.url as NSObject?
                    fieldDetails[SiteAttributes.isDefault.rawValue]=site._default as NSObject?
                    fieldDetails[SiteAttributes.modify.rawValue]=site.m as NSObject?
                    fieldDetails[SiteAttributes.position.rawValue]=position as NSObject?
                    let iconPath="http://www.google.com/s2/favicons?domain_url="+site.url!
                    fieldDetails[SiteAttributes.siteIconPath.rawValue]=iconPath as NSObject?
                    if(site.iconArray?.count>0)
                    {
                        fieldDetails[SiteAttributes.iconArray.rawValue]=site.iconArray as NSObject?
                    }
                    else
                    {
                        
                    }
                    if(self.siteController.IsSiteExist(site.url!, name: site.name!) == false)
                    {
                        DispatchQueue.main.sync(execute: {
                          self.siteController.saveSite(fieldDetails)
                        })
                        
                    }
                    position += 1
                    
                    if(site.leaf==1)
                    {
                        var siteItemFields=[String:NSObject]()
                        siteItemFields[SiteItemAttributes.siteItemID.rawValue] = UUID().uuidString as NSObject?
                        siteItemFields[SiteItemAttributes.siteID.rawValue]=siteID as NSObject?
                        siteItemFields[SiteItemAttributes.siteItemName.rawValue]=site.name as NSObject?
                        siteItemFields[SiteItemAttributes.position.rawValue]=0 as NSObject?
                        siteItemFields[SiteItemAttributes.encoding.rawValue]=site.encoding as NSObject?
                        siteItemFields[SiteItemAttributes.isDefault.rawValue]=site._default as NSObject?
                        siteItemFields[SiteItemAttributes.siteItemNameBackup.rawValue]=site.name as NSObject?
                        siteItemFields[SiteItemAttributes.isFavorite.rawValue]=site.direct as NSObject?
                        let urlSiteItem=site.url as NSObject?
                        let urlEncoded=Utils.enCryptString2(urlSiteItem as! String)
                        siteItemFields[SiteItemAttributes.siteItemURL.rawValue]=urlEncoded as NSObject?
                        siteItemFields[SiteItemAttributes.siteItemURLBackup.rawValue]=urlEncoded as NSObject?
                        siteItemFields[SiteItemAttributes.position.rawValue]=0 as NSObject?
                        
                        if(self.siteItemController.IsSiteItemExist(site.url!) == false)
                        {
                            DispatchQueue.main.sync(execute: {
                                self.siteItemController.saveSiteItem(siteItemFields)
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
                            
                            siteItemFields[SiteItemAttributes.position.rawValue]=siteItemPosition as NSObject?
                            siteItemFields[SiteItemAttributes.encoding.rawValue]=siteItem.encoding as NSObject?
                            
                            siteItemFields[SiteItemAttributes.isDefault.rawValue]=siteItem._default as NSObject?
                            siteItemFields[SiteItemAttributes.siteItemNameBackup.rawValue]=siteItem.name as NSObject?
                            siteItemFields[SiteItemAttributes.isFavorite.rawValue]=siteItem.direct as NSObject?
                            let urlSiteItem=siteItem.url as NSObject?
                            let urlEncoded=Utils.enCryptString2(urlSiteItem as! String)
                            siteItemFields[SiteItemAttributes.siteItemURLBackup.rawValue]=urlEncoded as NSObject?
                            siteItemFields[SiteItemAttributes.siteItemURL.rawValue]=urlEncoded as NSObject?
                            siteItemFields[SiteItemAttributes.position.rawValue]=siteItemPosition as NSObject?
                            
                            if(self.siteItemController.IsSiteItemExist(siteItem.url!) == false)
                            {
                                DispatchQueue.main.sync(execute: {
                                    self.siteItemController.saveSiteItem(siteItemFields)
                                })
                                
                            }
                            siteItemPosition += 1
                            
                        }
                    }
                }
            }
            
            // Post notification to update datasource of a given ViewController/UITableView
            DispatchQueue.main.async {
                KRProgressHUD.dismiss()
                
                let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "SiteListStoryBoard") as? SiteListTableViewController
                self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
            }
        }
        )
        
        
    }
    
    func getAdmobKeyFromServer(serverURL:String)
    {
        if(setting.getAppLaunchCount()>2 && setting.getCheckUpdateDB()<Date())
        {
        if let url = URL(string: admobFromServer) {
            
            
             DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            do {
                        let result = try String(contentsOf: url)
                        let admobArray=result.components(separatedBy: ";")
                        self.setting.setAdsType(Int.init(admobArray[0])!)
                        self.setting.setAdmobKey(admobArray[1])
                    } catch {
                        // contents could not be loaded
                    }
                    
            }
           // )
            /*
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: {
                do {
                    let result = try String(contentsOf: url)
                    let admobArray=result.components(separatedBy: ";")
                    self.setting.setAdsType(Int.init(admobArray[0])!)
                    self.setting.setAdmobKey(admobArray[1])
                } catch {
                    // contents could not be loaded
                }
                
            })*/
            
        } else {
            // the URL was bad!
        }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
