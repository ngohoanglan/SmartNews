//
//  Utils.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 10/10/16.
//  Copyright © 2016 admin. All rights reserved.
//
import RealmSwift
import Foundation
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
extension UIView {

    func visiblity(gone: Bool, dimension: CGFloat = 0.0, attribute: NSLayoutConstraint.Attribute = .height) -> Void {
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            constraint.constant = gone ? 0.0 : dimension
            self.layoutIfNeeded()
            self.isHidden = gone
        }
    }
}
class Utils
{
   static func checkFeedIsExist( siteItemID:String,link:String) -> Bool {
        let realm = try! Realm()
        let findByIdPredicate =
        NSPredicate(format: "siteItemID = %@ AND link = %@", siteItemID, link)
        let isExist =  ((try! realm.objects(FeedData.self).filter(findByIdPredicate).first) != nil)
        return isExist
       
    }
   static func resizeImage(_ image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        
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
    
   static func RBSquareImageTo(_ image: UIImage, size: CGSize) -> UIImage {
        return RBResizeImage(RBSquareImage(image), targetSize: size)
    }
    
   static func RBSquareImage(_ image: UIImage) -> UIImage {
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
    
   static func RBResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
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
   static func RemoveHTMLTagsAndSymbols(_ htmlString: String) -> String
    {
        
        let result = htmlString.replacingOccurrences(of: "&#34;", with: "\"").replacingOccurrences(of: "\r",with:  "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "&amp;nbsp;", with: "").replacingOccurrences(of: "&#039;", with: "\'").replacingOccurrences(of: "&#8216;", with: "‘").replacingOccurrences(of: "&#034;", with: "\"").replacingOccurrences(of: "&#8217;", with: "’").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">").replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&quot;", with: "\"").replacingOccurrences(of: "&apos;", with: "\"").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&#8211;", with: "–").replacingOccurrences(of: "&#8212;", with: "—").replacingOccurrences(of: "&#8221;", with: "”").replacingOccurrences(of: "&#8220;", with: "“").replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&ldquo;", with: "“").replacingOccurrences(of: "&rdquo;", with: "”").replacingOccurrences(of: "&lsquo;", with: "‘").replacingOccurrences(of: "&rsquo;", with: "’").replacingOccurrences(of: "&apos;", with: "'").replacingOccurrences(of: "type=\"html\"", with: "").replacingOccurrences(of: "type=\"text\"", with: "").replacingOccurrences(of: "&#252;", with: "ü").replacingOccurrences(of: "&#228;", with: "ä").replacingOccurrences(of: "&#246;", with: "ö").replacingOccurrences(of: "&#223;", with: "ß").replacingOccurrences(of: "&#038;", with: "&").replacingOccurrences(of: "&#xf6;", with: "ö").replacingOccurrences(of: "&#xe4;", with: "ä")
            .replacingOccurrences(of: "&#xfc;", with: "ü").replacingOccurrences(of: "&#13;", with: "").replacingOccurrences(of: "&auml;", with: "ä").replacingOccurrences(of: "&#x201e;", with: "„").replacingOccurrences(of: "&ndash;", with: "–").replacingOccurrences(of: "&uuml;", with: "ü").replacingOccurrences(of: "&szlig;", with: "ß").replacingOccurrences(of: "&ouml;", with: "ö").replacingOccurrences(of: "&icirc;", with: "î").replacingOccurrences(of: "&acirc;", with: "â").replacingOccurrences(of: "&#x2013;", with: "–").replacingOccurrences(of: "&#537;", with: "ș").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        
        return result
    }
   static func detectEncodingFormat(_ encodingInputString:String) -> String.Encoding
    {
        var encodingInputString = encodingInputString
        var encoding=String.Encoding.utf8
        encodingInputString=encodingInputString.lowercased()
        if(encodingInputString.contains("utf-8"))
        {
            encoding=String.Encoding.utf8
        }
        else if(encodingInputString.contains("iso"))
        {
            encoding=String.Encoding.isoLatin1
        }
        return encoding
    }
   static func checkUFT8Encoding(_ input:String)->Bool
    {
        let input = input
        if(input.lowercased().contains("utf-8"))
        {
            return true
        }
        return false
    }
  static  func getEncodingNameXML(_ input:String) -> String {
        var input = input
        var encodings:[String]
        input=input.replacingOccurrences(of: "'", with: "\"")
            .replacingOccurrences(of: "\\", with: "")
        
        do {
            let regex = try NSRegularExpression(pattern: "encoding=\"(.[^\"]+)\"", options: [])
            let nsString = input as NSString
            let results = regex.matches(in: input,
                                        options: [], range: NSMakeRange(0, nsString.length))
            encodings = results.map { nsString.substring(with: $0.range)}
            if(encodings.count>0)
            {
                let result = encodings[0]
                return result
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return ""
        }
        return ""
    }
  static  func enCryptString(_ input:String) -> String
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
        for c in input
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
  static  func deCryptString(_ input : String) -> String {
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
        
        for c in input
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
    static  func enCryptString2(_ input:String) -> String
    {
        let input = input
        let utf8str = input.data(using: String.Encoding.utf8)
        
        // Base64 encode UTF 8 string
        // fromRaw(0) is equivalent to objc 'base64EncodedStringWithOptions:0'
        // Notice the unwrapping given the NSData! optional
        // NSString! returned (optional)
        let base64Encoded = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
        
        // println("Encoded:  \(base64Encoded)")
        
        let char = "a"
        let MIN_c = String(char).utf8[String(char).utf8.startIndex]
        
        let char2 = "x"
        let MAX_c = String(char2).utf8[String(char2).utf8.startIndex]
        
        let char3 = "A"
        let MIN_C = String(char3).utf8[String(char3).utf8.startIndex]
        
        let char4 = "R"
        let MAX_C = String(char4).utf8[String(char4).utf8.startIndex]
        
        let char5 = "1"
        let MIN_0 = String(char5).utf8[String(char5).utf8.startIndex]
        
        let char6 = "8"
        let MAX_0 = String(char6).utf8[String(char6).utf8.startIndex]
        
        var result:String=""
        
        
        
        for c in base64Encoded!
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
    static  func deCryptString2(_ input : String) -> String {
        var input = input
        
        let char = "a"
        let MIN_c = String(char).utf8[String(char).utf8.startIndex]
        
        let char2 = "x"
        let MAX_c = String(char2).utf8[String(char2).utf8.startIndex]
        
        let char3 = "A"
        let MIN_C = String(char3).utf8[String(char3).utf8.startIndex]
        
        let char4 = "R"
        let MAX_C = String(char4).utf8[String(char4).utf8.startIndex]
        
        let char5 = "1"
        let MIN_0 = String(char5).utf8[String(char5).utf8.startIndex]
        
        let char6 = "8"
        let MAX_0 = String(char6).utf8[String(char6).utf8.startIndex]
        
        var result:String=""
        input=input.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/").replacingOccurrences(of: ",", with: "=")
        //var lengtStr=input.characters.count
        
        for c in input
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

   
}
