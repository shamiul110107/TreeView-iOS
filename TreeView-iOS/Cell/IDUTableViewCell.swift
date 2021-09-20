//
//  IDUTableViewCell.swift
//  AirCloudProPilot
//
//  Created by Sami on 6/23/19.
//  Copyright © 2019 Sami. All rights reserved.
//

import UIKit

class IDUTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iduContainerView: UIView!
    
    @IBOutlet weak var iduName: UILabel!
    @IBOutlet weak var leadingConstraintForIduCell: NSLayoutConstraint!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var oduCapacityLabel: UILabel!
    @IBOutlet weak var dotedMenuButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
