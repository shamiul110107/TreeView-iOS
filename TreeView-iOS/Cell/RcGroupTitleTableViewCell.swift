//
//  customTableViewCell.swift
//  TreeTest
//
//  Created by Sami on 6/11/19.
//  Copyright © 2019 Sami. All rights reserved.
//

import UIKit

class RcGroupTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var containerViewForTitleCell: UIView!
    @IBOutlet weak var titleCellLeadingConstraing: NSLayoutConstraint!
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var gatewayImageView: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
