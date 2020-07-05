//
//  CountryTableViewCell.swift
//  VietNamNewspapers
//
//  Created by admin on 2/26/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class CountryTableViewCell: UITableViewCell {

    @IBOutlet weak var imgCountryFlag: UIImageView!
    @IBOutlet weak var lbCountryCode: UILabel!
    @IBOutlet weak var lbCountryName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

