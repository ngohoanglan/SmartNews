//
//  StringExtension.swift
//  CoreDataCRUD
//
//  Created by c0d3r on 30/09/15.
//  Copyright © 2015 io pandacode. All rights reserved.
//
import UIKit
import Foundation
extension UIColor {
    public static func color(fromHexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(colorInteger(fromHexString: fromHexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    private static func colorInteger(fromHexString: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: fromHexString)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
    
    var redValue: CGFloat{
        return cgColor.components! [0]
    }
    
    var greenValue: CGFloat{
        return cgColor.components! [1]
    }
    
    var blueValue: CGFloat{
        return cgColor.components! [2]
    }
    
    var alphaValue: CGFloat{
        return cgColor.components! [3]
    }
    
    // credits to @andreaantonioni for this addition
    var isWhiteText: Bool {
        let red = self.redValue * 255
        let green = self.greenValue * 255
        let blue = self.blueValue * 255
        
        // https://en.wikipedia.org/wiki/YIQ
        // https://24ways.org/2010/calculating-color-contrast/
        let yiq = ((red * 299) + (green * 587) + (blue * 114)) / 1000
        return yiq < 192
    }
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
}
extension String {
    
    init?(htmlEncodedString: String) {
        
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        
        let options: [String: Any] = [
            convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.documentType): convertFromNSAttributedStringDocumentType(NSAttributedString.DocumentType.html),
            convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.characterEncoding): String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: convertToNSAttributedStringDocumentReadingOptionKeyDictionary(options), documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString.string)
    }
    /**
     Custom extension method to append Strings
     
     - Parameter str: The string to append to current String
     - Returns: Void
     */
    mutating func append(_ str: String) {
        self = self + str
    }
    
    /**
     Custom extension method to URL encode a String
     
     - Returns: String the URLEncoded String
     */
    mutating func URLEncodedString() -> String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        
        return escapedString
    }
    
    func base64Encoded() -> String {
        let plainData = data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        return base64String!
    }
   
    func indexOfString(_ intput:String)->Int
    {
        let range: Range<String.Index> = self.range(of: intput)!
        let index:Int=self.distance(from: self.startIndex, to: range.lowerBound)
        return index
    }
    
    func subStringFromTwoTag(_ startTag:String, endTag:String)->String
    {
        if(self.contains(startTag) && self.contains(endTag)){
        let startRange: Range<String.Index> = self.range(of: startTag)!
        let endRange: Range<String.Index> = self.range(of: endTag)!
       
           if(startRange.upperBound > endRange.lowerBound)
           {
                let indexOfStart =  self.indexOfString(startTag)
                let temp=self.index(self.startIndex, offsetBy: indexOfStart)..<self.endIndex
                let newString=self[temp]
            if(newString.contains(startTag) && newString.contains(endTag)){
                let newStartRange: Range<String.Index> = newString.range(of: startTag)!
                let newEndRange: Range<String.Index> = newString.range(of: endTag)!
                if(newStartRange.upperBound < newEndRange.lowerBound)
                {
                    return newString.substring(with: (newStartRange.upperBound ..< newEndRange.lowerBound))
                }
            }
            }
            
        return self.substring(with: (startRange.upperBound ..< endRange.lowerBound))
         
        }
        return ""
    }
    
    func matchesForRegexInText(_ regex: String!, text: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
   /* func getLinkImage() -> String {
        let regexStr = "(http://[^\\s]+(.jpg|.png|.gif))"
       // return regex.firstMatchInString(self, options:[],
        //    range: NSMakeRange(0, utf16.count)) != nil
        
    
        let regex = NSRegularExpression(pattern: regexStr, options: NSRegularExpressionOptions.CaseInsensitive)
       
        let results = regex.matchesInString(self,
            options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, utf16.count))
            as! [NSTextCheckingResult]
        return map(results) { self.substringWithRange($0.range)}
        
    }*/
    
   }

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentAttributeKey(_ input: NSAttributedString.DocumentAttributeKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentType(_ input: NSAttributedString.DocumentType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringDocumentReadingOptionKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.DocumentReadingOptionKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.DocumentReadingOptionKey(rawValue: key), value)})
}
