//
//  FeedDataTableViewCell.swift
//  VietNamNewspapers
//
//  Created by admin on 4/17/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class FeedDataTableViewCell: UITableViewCell {

    @IBAction func btnShare(_ sender: AnyObject) {
        if let btnShareTapped = self.btnShareTapped
        {
            btnShareTapped()
        }
    }
   
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var csHeightDescription: NSLayoutConstraint!
    @IBAction func btnExpand(_ sender: AnyObject) {
        if let btnExpandTapped=self.btnExpandTapped
        {
            btnExpandTapped()
        }
    }
    @IBOutlet weak var btnExpand: UIButton!
   
    @IBAction func btnImportan(_ sender: AnyObject) {
        if let btnImportanTapped=self.btnImportanTapped
        {
            btnImportanTapped()
        }
    }
    var btnShareTapped : (() -> Void)? = nil
    var btnImportanTapped : (() -> Void)? = nil
    var btnExpandTapped : (() -> Void)? = nil
    @IBOutlet weak var btnImportan: UIButton!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbPubDate: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var imgFeed: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // backgroundColor = UIColor.redColor()
        
      

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        // Configure the view for the selected state
    }

}

