//
//  AppDelegate.swift
//  VietNamNewspapers
//
//  Created by admin on 2/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import UserNotifications
import Firebase

import FirebaseMessaging
import SafariServices
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GADInterstitialDelegate {
    let gcmMessageIDKey = "gcm.message_id"

    var window: UIWindow?
    var gViewController: UIViewController?
    var mInterstitial: GADInterstitial!
    var hasShowAds=false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        
        // Override point for customization after application launch.
        FirebaseApp.initialize()
              FirebaseApp.configure()
              
              // [START set_messaging_delegate]
              Messaging.messaging().delegate = self
              
              // [END set_messaging_delegate]
              // Register for remote notifications. This shows a permission dialog on first run, to
              // show the dialog at a more appropriate time move this registration accordingly.
              // [START register_for_notifications]
              if #available(iOS 10.0, *) {
                  // For iOS 10 display notification (sent via APNS)
                  UNUserNotificationCenter.current().delegate = self
                  
                  let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                  UNUserNotificationCenter.current().requestAuthorization(
                      options: authOptions,
                      completionHandler: {_, _ in })
              } else {
                  let settings: UIUserNotificationSettings =
                      UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                  application.registerUserNotificationSettings(settings)
              }
              
              application.registerForRemoteNotifications()
              
              // [END register_for_notifications]
        
        
        
        
        let setting=Settings()
        setting.setAppLaunchCount(setting.getAppLaunchCount()+1)
        setting.setAdHasShow(false)
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue: UIColor.white])
        
        UINavigationBar.appearance().tintColor=UIColor.white
        UITabBar.appearance().tintColor = UIColor.rgb(70, green: 146, blue: 250)
        
        application.statusBarStyle = .lightContent

        /*
        let themeColor=UIColor.color(fromHexString: "ee8d02")
        
        //UINavigationBar.appearance().barTintColor = UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
        UINavigationBar.appearance().barTintColor = themeColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        UINavigationBar.appearance().tintColor=UIColor.white
        UITabBar.appearance().tintColor = UIColor.rgb(70, green: 146, blue: 250)
        
        application.statusBarStyle = .lightContent
        */
        return true
    }
    
    func sharedInstance() -> AppDelegate {
        
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    lazy var datastoreCoordinator: DatastoreCoordinator = {
        return DatastoreCoordinator()
    }()
    
    lazy var contextManager: ContextManager = {
        return ContextManager()
    }()
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        //Clear images after day
       
        
       
 
       
        print("Disconnected from FCM.")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
          print("Disconnected from FCM.")
    }

    

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "thealllatestnews.VietNamNewspapers" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "VietNamNewspapers", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    func showAdmobInterstitial(kGoogleFullScreenAppUnitID:String)
    {
       // let kGoogleFullScreenAppUnitID = "ca-app-pub-3108267494433171/3375569241";
        self.mInterstitial = GADInterstitial.init(adUnitID:kGoogleFullScreenAppUnitID )
        
        mInterstitial.delegate = self
        let Request  = GADRequest()
       let testDevice = UIDevice.current.identifierForVendor!.uuidString

        Request.testDevices = ["454816DA-6ED2-43D0-8528-029F34B61BF7"]
        mInterstitial.load(Request)
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial!)
    {
        hasShowAds=true
        ad.present(fromRootViewController: self.gViewController!)
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
     
         ActionPushMessage(userInfo as! [String : AnyObject])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        ActionPushMessage(userInfo as! [String : AnyObject])
     
        completionHandler(UIBackgroundFetchResult.newData)
 
    }
    // [END receive_message]
    // [START refresh_token]
    @objc func tokenRefreshNotification(_ notification: Notification) {
        
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    // [START connect_to_fcm]
    func connectToFcm() {
        // Won't connect since there is no token
       
        
       
    }
    // [END connect_to_fcm]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
    }
    
    // [START connect_on_active]
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
    }
    // [END connect_on_active]
    // [START disconnect_from_fcm]
    
    // [END disconnect_from_fcm]
  
    // MARK: Helpers
   //let safari = SFSafariViewController(url: url!)
    func ActionPushMessage(_ notificationDictionary:[String: AnyObject]) -> Void {
        
        let news = notificationDictionary["body"] as? String
        let url_link = notificationDictionary["url"] as? String
        let url = URL(string: url_link!)
       
        DispatchQueue.global().async {
            
            DispatchQueue.main.async {
                UIApplication.shared.openURL(url!)
            }
        }
        /*
            let news = notificationDictionary["body"] as? String
            let url_link = notificationDictionary["url"] as? String
            let url = URL(string: url_link!)
            let safari = SFSafariViewController(url: url!)
            safari.dismiss(animated: true, completion: nil)
            window?.rootViewController?.present(safari, animated: true, completion: nil)
            safari.dismiss(animated: true, completion: nil)
        */
    }
    
}
// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
     //   ActionPushMessage(userInfo as! [String : AnyObject])
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
         ActionPushMessage(userInfo as! [String : AnyObject])
        completionHandler()
    }
}
// [END ios_10_message_handling]
// [START ios_10_data_message_handling]
extension AppDelegate : MessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
       // print(remoteMessage.appData)
    }
}
// [END ios_10_data_message_handling]

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
