//
//  CountryComboBoxListViewController.swift
//  VietNamNewspapers
//
//  Created by admin on 3/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import FirebaseMessaging
import ImageLoader
class CountryComboBoxListViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate{
     private let textFieldFont = UIFont.systemFont(ofSize: 16)
    @IBOutlet weak var pickerCountryList: UIPickerView!
    var passOject:UserDefaults!
    let url:String="http://thealllatestnews.com/Resources/CountryList/list.txt"
    let indicator=UIActivityIndicatorView(style: .gray)
    fileprivate var importData:ImportDataController!
    var countryList:Array<SWCountry>=[]
    fileprivate var httpClient:HTTPClient!
    //var country_code:String!="US"
    var country_code_selected:String!="US"
    var country_name_selected:String!
    @IBOutlet weak var lbSelectCountry: UILabel!
    // @IBOutlet weak var viewContainer: UIView!
    var setting=Settings()
    @IBOutlet weak var btImportNewspapers: UIButton!
    @IBAction func buttonImportNewspapers(_ sender: AnyObject) {
        var index=pickerCountryList.selectedRow(inComponent: 0)
        country_code_selected=countryList[index].code
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerCountryList.dataSource = self;
        self.pickerCountryList.delegate = self;
        btImportNewspapers.backgroundColor=UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
        
        
        btImportNewspapers.configure(color:  .white,
                           font:  UIFont.systemFont(ofSize: 16),
                           cornerRadius: 8,
                           borderColor:  UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1),
                           backgroundColor:  UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1),
                           borderWidth: 2.0)

        passOject=UserDefaults()
        
        if(setting.getCountryCodeSelectedKey()=="")
        {
            country_code_selected=NSLocale.current.regionCode
            if(country_code_selected=="GB")
            {
                country_code_selected="UK"
            }
        }
        else
        {
            country_code_selected = setting.getCountryCodeSelectedKey()
            Messaging.messaging().unsubscribe(fromTopic: "/topics/"+setting.getCountryCodeSelectedKey()+"")
            print("UnSubscribed to "+setting.getCountryCodeSelectedKey()+" topic")
            
        }
        btImportNewspapers.setTitle(NSLocalizedString("next", comment: ""), for: UIControl.State())
        lbSelectCountry.text=NSLocalizedString("select_country", comment: "")
        indicator.center=view.center
        indicator.hidesWhenStopped=true
        indicator.startAnimating()
        view.addSubview(indicator)
        
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList.count;
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width - 30, height: 50))
        
        let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        //myImageView.load(countryList[row].imagePath)
        
        myImageView.load.request(with: countryList[row].imagePath)
        
        let myLabel = UILabel(frame: CGRect(x: 60, y: 0, width: pickerView.bounds.width - 90, height: 50 ))
        
        myLabel.text = countryList[row].name
        
        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        
        return myView
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        country_code_selected=countryList[row].code
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let URL = URL(string: url) {
            do {
                let result = try String(contentsOf: URL)
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    
                    
                    let countriesArray=result.components(separatedBy: ";")
                    for item in countriesArray
                    {
                        var country:SWCountry!
                        let countryDetail=item.components(separatedBy: "-")
                        if  countryDetail.count==2
                        {
                            
                            country=SWCountry()
                            country.code=countryDetail[0]
                            country.name=countryDetail[1]
                            country.imagePath="http://thealllatestnews.com/Resources/CountryList/"+countryDetail[0]+"/"+countryDetail[0]+".png"
                            
                            self.countryList.append(country)
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.pickerCountryList.reloadAllComponents()
                    self.pickerCountryList.selectRow(self.getIndexfromList(self.country_code_selected, arrayCountry: self.countryList), inComponent: 0, animated: true)
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
            
            
            
        } else {
            // the URL was bad!
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getIndexfromList(_ country_code:String, arrayCountry:Array<SWCountry>)->Int
    {
        var index:Int!=0
        if(arrayCountry.count<1){
            index=0;
        }
        else
        {
            for  c in arrayCountry
            {
                if(c.code==self.country_code_selected)
                {
                    country_name_selected=c.name
                    index=arrayCountry.firstIndex(of: c)
                    break
                }
            }
        }
        return index
        
    }
    func getCountryCodefromList(_ country_name:String, arrayCountry:Array<SWCountry>)->String
    {
        var code:String!
        
        
        for  c in arrayCountry
        {
            if(c.name==country_name)
            {
                code=c.code
                break
            }
        }
        
        return code
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //country_code_selected=getCountryCodefromList(country_name_selected, arrayCountry: countryList)
        passOject.set(country_code_selected, forKey: "country_code_key")
    }
    
}
class SWCountry:NSObject {
    var name:String!
    var code:String!
    var imagePath:String!
}

