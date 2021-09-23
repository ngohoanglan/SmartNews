//
//  FeedTableViewCell.swift
//  VietNamNewspapers
//
//  Created by Ngo Lan on 23/09/2021.
//  Copyright © 2021 admin. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnImportan: UIButton!
    
    @IBOutlet weak var lbPubdate: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var imgFeed: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func btnExandClicked(_ sender: Any) {
        if let btnExpandTapped=self.btnExpandTapped
        {
            btnExpandTapped()
        }
    }
    @IBAction func btnShareClicked(_ sender: Any) {
        if let btnShareTapped = self.btnShareTapped
        {
            btnShareTapped()
        }
    }
    @IBAction func btnImportanClicked(_ sender: Any) {
        if let btnImportanTapped=self.btnImportanTapped
        {
            btnImportanTapped()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var btnShareTapped : (() -> Void)? = nil
    var btnImportanTapped : (() -> Void)? = nil
    var btnExpandTapped : (() -> Void)? = nil
}
