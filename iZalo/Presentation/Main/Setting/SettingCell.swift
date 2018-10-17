//
//  SettingCell.swift
//  iZalo
//
//  Created by CPU11613 on 10/15/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {

    @IBOutlet weak var settingImageView: UIImageView!
    @IBOutlet weak var settingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(item: SettingItem) {
        self.settingImageView.image = UIImage(named: item.image)
        self.settingLabel.text = item.text
    }
}
