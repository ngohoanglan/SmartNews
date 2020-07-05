//
//  BaseViewController.swift
//  VietNamNewspapers
//
//  Created by Ngô Lân on 7/25/17.
//  Copyright © 2017 admin. All rights reserved.
//

import Foundation
import UIKit
class BaseViewController: UIViewController
{
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    override func loadView() {
        super.loadView()
        
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.view.backgroundColor = .white
        self.view.autoresizesSubviews = true
        self.view.autoresizingMask	= [ .flexibleWidth, .flexibleHeight ]
        
        var frame: CGRect = self.view.frame
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        frame.origin.y    += statusBarHeight
        frame.size.height -= statusBarHeight
        
        if let navBarHeight: CGFloat = self.navigationController?.navigationBar.bounds.size.height {
            frame.origin.y    += navBarHeight
            frame.size.height -= navBarHeight
        }
        self.view.frame = frame
    }
    
    func setup() {
        // actual contents of init(). subclass can override this.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
