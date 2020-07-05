//
//  SelectNewspaperTableViewCell.swift
//  VietNamNewspapers
//
//  Created by Ngo Lan on 7/5/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit

class SelectNewspaperTableViewCell: UITableViewCell {

    @IBOutlet weak var switchSelect: UISwitch!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
