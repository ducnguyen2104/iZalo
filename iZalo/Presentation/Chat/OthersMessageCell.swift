//
//  OthersMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 9/27/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit

class OthersMessageCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
