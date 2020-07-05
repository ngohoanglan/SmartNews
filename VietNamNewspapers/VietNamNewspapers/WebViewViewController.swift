//
//  WebViewViewController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 6/25/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class WebViewViewController: UIViewController ,UIWebViewDelegate{
    @IBOutlet weak var webView: UIWebView!
var passOject:UserDefaults!
     let indicator=UIActivityIndicatorView(style: .gray)
    var feed_url:String=""
    @IBAction func btActionShare(_ sender: AnyObject) {
        
        if let name = URL(string: feed_url) {
            let objectsToShare = [name]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    @IBAction func btRefresh(_ sender: AnyObject) {
        
        let url = URL(string: feed_url)
        let request = URLRequest(url: url!)
        
        webView.delegate = self
        indicator.center=view.center
        indicator.hidesWhenStopped=true
        indicator.startAnimating()
        view.addSubview(indicator)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        webView.loadRequest(request)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuController()?.sideMenu?.menuWidth=0.0
        sideMenuController()?.sideMenu?.allowLeftSwipe=false
        sideMenuController()?.sideMenu?.allowRightSwipe=false
        sideMenuController()?.sideMenu?.allowPanGesture=false
        passOject=UserDefaults()
        feed_url=passOject.value(forKey: "feed_url_key") as! String
        
        var  siteItemName=""
        if passOject.string(forKey: "siteItemName_key") != nil
        {
          siteItemName =  passOject.value(forKey: "siteItemName_key") as! String
        }
        self.navigationItem.leftBarButtonItem=UIBarButtonItem(image: UIImage(named: "back_44"), style: .plain, target: self, action: #selector(WebViewViewController.goBack))
   
        self.navigationItem.title=siteItemName
        let url = URL(string: feed_url)
        let request = URLRequest(url: url!)
        
        webView.delegate = self
        indicator.center=view.center
        indicator.hidesWhenStopped=true
        indicator.startAnimating()
        view.addSubview(indicator)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        webView.loadRequest(request)

    }
    @objc func goBack()
    {
        sideMenuController()?.sideMenu?.menuWidth=250.0
        self.navigationController?.popViewController(animated: true)

    }
    
    func leftNavButtonClick(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        indicator.stopAnimating()
    }
    
   
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let aaa=segue.identifier
    }
    

}
