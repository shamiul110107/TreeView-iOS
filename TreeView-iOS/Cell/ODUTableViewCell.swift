//
//  ODUTableViewCell.swift
//  AirCloudProPilot
//
//  Created by Sami on 6/20/19.
//  Copyright © 2019 Sami. All rights reserved.
//

import UIKit

class ODUTableViewCell: UITableViewCell {

    @IBOutlet weak var containerViewLeadingConstant: NSLayoutConstraint!
    @IBOutlet weak var oduTitle: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
