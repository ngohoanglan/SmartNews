//
//  SiteListCell.swift
//  VietNamNewspapers
//
//  Created by Ngo Lan on 7/12/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit

class SiteListCell: UITableViewCell {

    @IBOutlet weak var imgSiteIcon: UIImageView!
    @IBOutlet weak var lbSiteName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
