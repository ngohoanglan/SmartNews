//
//  KRProgressHUD.swift
//  KRProgressHUD
//
//  Copyright © 2016年 Krimpedance. All rights reserved.
//

import UIKit

/**
 Type of KRProgressHUD's background view.

 - **Clear:** `UIColor.clearColor`.
 - **White:** `UIColor(white: 1, alpho: 0.2)`.
 - **Black:** `UIColor(white: 0, alpho: 0.2)`. Default type.
 */
public enum KRProgressHUDMaskType {
    case clear, white, black,red
}

/**
 Style of KRProgressHUD.

 - **Black:**           HUD's backgroundColor is `.blackColor()`. HUD's text color is `.whiteColor()`.
 - **White:**          HUD's backgroundColor is `.whiteColor()`. HUD's text color is `.blackColor()`. Default style.
 - **BlackColor:**   same `.Black` and confirmation glyphs become original color.
 - **WhiteColor:**  same `.Black` and confirmation glyphs become original color.
 */             
public enum KRProgressHUDStyle {
    case black, white, blackColor, whiteColor,appColor
}

/**
 KRActivityIndicatorView style. (KRProgressHUD uses only large style.)

 - **Black:**   the color is `.blackColor()`. Default style.
 - **White:**  the color is `.blackColor()`.
 - **Color(startColor, endColor):**   the color is a gradation to `endColor` from `startColor`.
 */                                                                          
public enum KRProgressHUDActivityIndicatorStyle {
    case black, white, color(UIColor, UIColor)
}


/**
 *  KRProgressHUD is a beautiful and easy-to-use progress HUD.
 */
public final class KRProgressHUD {
    fileprivate static let view = KRProgressHUD()
    /// Shared instance. KRProgressHUD is created as singleton.
    class func sharedView() -> KRProgressHUD { return view }

    fileprivate let window = UIWindow(frame: UIScreen.main.bounds)
    fileprivate let progressHUDView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    fileprivate let iconView = UIView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
    fileprivate let activityIndicatorView = KRActivityIndicatorView(position: CGPoint.zero, activityIndicatorStyle: .largeBlack)
    fileprivate let drawView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    fileprivate let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
    fileprivate let messageTitle = UILabel(frame: CGRect(x: 50, y: 0, width: 150, height: 20))
    fileprivate var maskType: KRProgressHUDMaskType {
        willSet {
            switch newValue {
            case .clear:  window.rootViewController?.view.backgroundColor = UIColor.clear
            case .white:  window.rootViewController?.view.backgroundColor = UIColor(white: 1, alpha: 0.2)
            case .black:  window.rootViewController?.view.backgroundColor = UIColor(white: 0, alpha: 0.2)
            case .red: window.rootViewController?.view.backgroundColor = UIColor.red
            }
        }
    }

    fileprivate var progressHUDStyle: KRProgressHUDStyle {
        willSet {
            switch newValue {
            case .black, .blackColor: 
                progressHUDView.backgroundColor = UIColor.black
                messageLabel.textColor = UIColor.white
                messageTitle.textColor = UIColor.white
            case .white, .whiteColor: 
                progressHUDView.backgroundColor = UIColor.white
                messageLabel.textColor = UIColor.black
                messageTitle.textColor = UIColor.black
            case .appColor:
                progressHUDView.backgroundColor = UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
                messageLabel.textColor = UIColor.white
                messageTitle.textColor = UIColor.white

            }
        }
    }
    fileprivate var activityIndicatorStyle: KRProgressHUDActivityIndicatorStyle {
        willSet {
            switch newValue {
            case .black:  activityIndicatorView.activityIndicatorViewStyle = .largeBlack
            case .white:  activityIndicatorView.activityIndicatorViewStyle = .largeWhite
            case let .color(sc, ec):  activityIndicatorView.activityIndicatorViewStyle = .largeColor(sc, ec)
            }
        }
    }
    fileprivate var defaultStyle: KRProgressHUDStyle = .white { willSet { progressHUDStyle = newValue } }
    fileprivate var defaultMaskType: KRProgressHUDMaskType = .black { willSet { maskType = newValue } }
    fileprivate var defaultActivityIndicatorStyle: KRProgressHUDActivityIndicatorStyle = .black { willSet { activityIndicatorStyle = newValue } }
    fileprivate var defaultMessageFont = UIFont(name: "HiraginoSans-W3", size: 13) ?? UIFont.systemFont(ofSize: 13) { willSet { messageLabel.font = newValue } }
fileprivate var defaultTitleFont = UIFont(name: "HiraginoSans-W3", size: 10) ?? UIFont.systemFont(ofSize: 10) { willSet { messageLabel.font = newValue } }

    fileprivate init() {
        maskType = .black
        progressHUDStyle = .white
        activityIndicatorStyle = .black
        
        configureProgressHUDView()
    }

    

    fileprivate func configureProgressHUDView() {
        let rootViewController = KRProgressHUDViewController()
        window.rootViewController = rootViewController
        window.windowLevel = UIWindow.Level.normal
        let screenFrame = UIScreen.main.bounds
        progressHUDView.center = CGPoint(x: screenFrame.width/2, y: screenFrame.height/2-100)
        progressHUDView.backgroundColor = UIColor.white
        progressHUDView.layer.cornerRadius = 5
        progressHUDView.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        window.rootViewController?.view.addSubview(progressHUDView)

        iconView.backgroundColor = UIColor.clear
        iconView.center = CGPoint(x: 50, y: 50)
        progressHUDView.addSubview(iconView)

        activityIndicatorView.isHidden = false
        iconView.addSubview(activityIndicatorView)

        drawView.backgroundColor = UIColor.clear
        drawView.isHidden = true
        iconView.addSubview(drawView)

        messageLabel.center = CGPoint(x: 150/2, y: 90)
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.font = defaultMessageFont
        messageLabel.textAlignment = .center
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.5
        messageLabel.text = nil
        messageLabel.isHidden = true
        progressHUDView.addSubview(messageLabel)
        
        messageTitle.center = CGPoint(x: 150/2, y: 70)
        messageTitle.backgroundColor = UIColor.clear
        messageTitle.font = defaultTitleFont
        messageTitle.textAlignment = .center
        messageTitle.adjustsFontSizeToFitWidth = true
        messageTitle.minimumScaleFactor = 0.5
        messageTitle.text = nil
        messageTitle.isHidden = true
        progressHUDView.addSubview(messageTitle)
        
       
    }
}


/**
 *  KRProgressHUD Setter --------------------------
 */
extension KRProgressHUD {
    /// Set default mask type.
    /// - parameter type: `KRProgressHUDMaskType`
    public class func setDefaultMaskType(type: KRProgressHUDMaskType) {
        KRProgressHUD.sharedView().defaultMaskType = type
    }

    /// Set default HUD style
    /// - parameter style: `KRProgressHUDStyle`
    public class func setDefaultStyle(style: KRProgressHUDStyle) {
        KRProgressHUD.sharedView().defaultStyle = style
    }

    /// Set default KRActivityIndicatorView style.
    /// - parameter style: `KRProgresHUDActivityIndicatorStyle`
    public class func setDefaultActivityIndicatorStyle(style: KRProgressHUDActivityIndicatorStyle) {
        KRProgressHUD.sharedView().defaultActivityIndicatorStyle = style
    }

    /// Set default HUD text font.
    /// - parameter font: text font
    public class func setDefaultFont(font: UIFont) {
        KRProgressHUD.sharedView().defaultMessageFont = font
    }
}


/**
 *  KRProgressHUD Show & Dismiss --------------------------
 */
extension KRProgressHUD {
    /**
     Showing HUD with some args. You can appoint only the args which You want to appoint.
     (Args is reflected only this time.)

     - parameter progressStyle  KRProgressHUDStyle
     - parameter type           KRProgressHUDMaskType
     - parameter indicatorStyle KRProgressHUDActivityIndicatorStyle
     - parameter font           HUD's message font
     - parameter message        HUD's message
     - parameter image          image that Alternative to confirmation glyph.
     */                               
    public class func show(
            progressHUDStyle progressStyle: KRProgressHUDStyle? = nil,
            maskType type:KRProgressHUDMaskType? = nil,
            activityIndicatorStyle indicatorStyle: KRProgressHUDActivityIndicatorStyle? = nil,
            font: UIFont? = nil, message: String? = nil, image: UIImage? = nil) {
        KRProgressHUD.sharedView().updateStyles(progressHUDStyle: progressStyle, maskType: type, activityIndicatorStyle: indicatorStyle)
        KRProgressHUD.sharedView().updateProgressHUDViewText(font: font, message: message)
        KRProgressHUD.sharedView().updateProgressHUDViewIcon(image: image)
        KRProgressHUD.sharedView().show()
        
    }

    /**
     Showing HUD with success glyph. the HUD dismiss after 1 secound.
     You can appoint only the args which You want to appoint.
     (Args is reflected only this time.)

     - parameter progressStyle  KRProgressHUDStyle
     - parameter type           KRProgressHUDMaskType
     - parameter indicatorStyle KRProgressHUDActivityIndicatorStyle
     - parameter font           HUD's message font
     - parameter message        HUD's message
     */
    public class func showSuccess(
            progressHUDStyle progressStyle: KRProgressHUDStyle? = nil,
            maskType type:KRProgressHUDMaskType? = nil,
            activityIndicatorStyle indicatorStyle: KRProgressHUDActivityIndicatorStyle? = nil,
            font: UIFont? = nil, message: String? = nil) {
        KRProgressHUD.sharedView().updateStyles(progressHUDStyle: progressStyle, maskType: type, activityIndicatorStyle: indicatorStyle)
        KRProgressHUD.sharedView().updateProgressHUDViewText(font: font, message: message)
        KRProgressHUD.sharedView().updateProgressHUDViewIcon(iconType: .Success)
        KRProgressHUD.sharedView().show()

        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            sleep(1)
            KRProgressHUD.dismiss()
        }
    }

    /**
     Showing HUD with information glyph. the HUD dismiss after 1 secound.
     You can appoint only the args which You want to appoint.
     (Args is reflected only this time.)

     - parameter progressStyle  KRProgressHUDStyle
     - parameter type           KRProgressHUDMaskType
     - parameter indicatorStyle KRProgressHUDActivityIndicatorStyle
     - parameter font           HUD's message font
     - parameter message        HUD's message
     */
    public class func showInfo(
            progressHUDStyle progressStyle: KRProgressHUDStyle? = nil,
            maskType type:KRProgressHUDMaskType? = nil,
            activityIndicatorStyle indicatorStyle: KRProgressHUDActivityIndicatorStyle? = nil,
            font: UIFont? = nil, message: String? = nil) {
        KRProgressHUD.sharedView().updateStyles(progressHUDStyle: progressStyle, maskType: type, activityIndicatorStyle: indicatorStyle)
        KRProgressHUD.sharedView().updateProgressHUDViewText(font: font, message: message)
        KRProgressHUD.sharedView().updateProgressHUDViewIcon(iconType: .Info)
        KRProgressHUD.sharedView().show()
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            sleep(1)
            KRProgressHUD.dismiss()
        }
    }

    /**
     Showing HUD with warning glyph. the HUD dismiss after 1 secound.
     You can appoint only the args which You want to appoint.
     (Args is reflected only this time.)

     - parameter progressStyle  KRProgressHUDStyle
     - parameter type           KRProgressHUDMaskType
     - parameter indicatorStyle KRProgressHUDActivityIndicatorStyle
     - parameter font           HUD's message font
     - parameter message        HUD's message
     */
    public class func showWarning(
            progressHUDStyle progressStyle: KRProgressHUDStyle? = nil,
            maskType type:KRProgressHUDMaskType? = nil,
            activityIndicatorStyle indicatorStyle: KRProgressHUDActivityIndicatorStyle? = nil,
            font: UIFont? = nil, message: String? = nil) {
        KRProgressHUD.sharedView().updateStyles(progressHUDStyle: progressStyle, maskType: type, activityIndicatorStyle: indicatorStyle)
        KRProgressHUD.sharedView().updateProgressHUDViewText(font: font, message: message)
        KRProgressHUD.sharedView().updateProgressHUDViewIcon(iconType: .Warning)
        KRProgressHUD.sharedView().show()
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            sleep(1)
            KRProgressHUD.dismiss()
        }
    }

    /**
     Showing HUD with error glyph. the HUD dismiss after 1 secound.
     You can appoint only the args which You want to appoint.
     (Args is reflected only this time.)

     - parameter progressStyle  KRProgressHUDStyle
     - parameter type           KRProgressHUDMaskType
     - parameter indicatorStyle KRProgressHUDActivityIndicatorStyle
     - parameter font           HUD's message font
     - parameter message        HUD's message
     */
    public class func showError(
            progressHUDStyle progressStyle: KRProgressHUDStyle? = nil,
            maskType type:KRProgressHUDMaskType? = nil,
            activityIndicatorStyle indicatorStyle: KRProgressHUDActivityIndicatorStyle? = nil,
            font: UIFont? = nil, message: String? = nil) {
        KRProgressHUD.sharedView().updateStyles(progressHUDStyle: progressStyle, maskType: type, activityIndicatorStyle: indicatorStyle)
        KRProgressHUD.sharedView().updateProgressHUDViewText(font: font, message: message)
        KRProgressHUD.sharedView().updateProgressHUDViewIcon(iconType: .Error)
        KRProgressHUD.sharedView().show()

        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            sleep(1)
            KRProgressHUD.dismiss()
        }
    }

    /**
     Dismissing HUD.
    */
    public class func dismiss() {
        DispatchQueue.main.async { () -> Void in
            UIView.animate(withDuration: 0.5, animations: {
                KRProgressHUD.sharedView().window.alpha = 0
            }, completion: { _ in
                KRProgressHUD.sharedView().window.isHidden = true
                KRProgressHUD.sharedView().activityIndicatorView.stopAnimating()

                KRProgressHUD.sharedView().progressHUDStyle = KRProgressHUD.sharedView().defaultStyle
                KRProgressHUD.sharedView().maskType = KRProgressHUD.sharedView().defaultMaskType
                KRProgressHUD.sharedView().activityIndicatorStyle = KRProgressHUD.sharedView().defaultActivityIndicatorStyle
                KRProgressHUD.sharedView().messageLabel.font = KRProgressHUD.sharedView().defaultMessageFont
                KRProgressHUD.sharedView().messageTitle.font = KRProgressHUD.sharedView().defaultTitleFont
            }) 
        }
    }
}


/**
 *  KRProgressHUD update during show --------------------------
 */
extension KRProgressHUD {
    public class func updateLabel(_ text: String,title : String) {
        sharedView().messageLabel.text = text
        sharedView().messageTitle.text=title
    }
}


/**
 *  KRProgressHUD update style method --------------------------
 */
private extension KRProgressHUD {
    func show() {
        DispatchQueue.main.async { () -> Void in
            self.window.alpha = 0
            self.window.makeKeyAndVisible()
            
            UIView.animate(withDuration: 0.5, animations: {
                KRProgressHUD.sharedView().window.alpha = 1
            }) 
        }
    }

    func updateStyles(progressHUDStyle progressStyle: KRProgressHUDStyle?, maskType type:KRProgressHUDMaskType?, activityIndicatorStyle indicatorStyle: KRProgressHUDActivityIndicatorStyle?) {
        if let style = progressStyle {
            KRProgressHUD.sharedView().progressHUDStyle = style
        }
        if let type = type {
            KRProgressHUD.sharedView().maskType = type
        }
        if let style = indicatorStyle {
            KRProgressHUD.sharedView().activityIndicatorStyle = style
        }
    }

    func updateProgressHUDViewText(font: UIFont?, message: String?) {
        if let text = message {
            let center = progressHUDView.center
            var frame = progressHUDView.frame
            frame.size = CGSize(width: 150, height: 110)
            progressHUDView.frame = frame
            progressHUDView.center = center

            iconView.center = CGPoint(x: 150/2, y: 40)

            messageLabel.isHidden = false
            messageLabel.text = text
            messageLabel.font = font ?? defaultMessageFont
            
            messageTitle.isHidden = false
            messageTitle.text = text
            messageTitle.font = font ?? defaultMessageFont
        } else {
            let center = progressHUDView.center
            var frame = progressHUDView.frame
            frame.size = CGSize(width: 100, height: 100)
            progressHUDView.frame = frame
            progressHUDView.center = center

            iconView.center = CGPoint(x: 50, y: 50)

            messageLabel.isHidden = true
            messageTitle.isHidden = true
        }
    }

    func updateProgressHUDViewIcon(iconType: KRProgressHUDIconType? = nil, image: UIImage? = nil) {
        drawView.subviews.forEach{ $0.removeFromSuperview() }
        drawView.layer.sublayers?.forEach{ $0.removeFromSuperlayer() }

        switch (iconType, image) {
        case (nil, nil): 
            drawView.isHidden = true
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()

        case let (nil, image): 
            activityIndicatorView.isHidden = true
            activityIndicatorView.stopAnimating()
            drawView.isHidden = false

            let imageView = UIImageView(image: image)
            imageView.frame = KRProgressHUD.sharedView().drawView.bounds
            imageView.contentMode = .scaleAspectFit
            drawView.addSubview(imageView)

        case let (type, _): 
            drawView.isHidden = false
            activityIndicatorView.isHidden = true
            activityIndicatorView.stopAnimating()

            let pathLayer = CAShapeLayer()
            pathLayer.frame = drawView.layer.bounds
            pathLayer.lineWidth = 0
            pathLayer.path = type!.getPath()

            switch progressHUDStyle {
            case .black:  pathLayer.fillColor = UIColor.white.cgColor
            case .white:  pathLayer.fillColor = UIColor.black.cgColor
            default:  pathLayer.fillColor = type!.getColor()
            }

            drawView.layer.addSublayer(pathLayer)
        }
    }
}
