//
//  ContactCell.swift
//  iZalo
//
//  Created by CPU11613 on 9/20/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import Kingfisher

class ContactCell: UITableViewCell {

    @IBOutlet weak var avtImageView: UIImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.avtImageView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(item: ContactItem) {
        let processor = RoundCornerImageProcessor(cornerRadius: 30)
        if (item.contact.avatarURL != nil) {
            avtImageView.kf.setImage(with: URL(string: item.contact.avatarURL), placeholder: nil,  options: [.processor(processor)])
        } else {
            avtImageView.kf.setImage(with: URL(string: Constant.defaultAvatarURL), placeholder: nil,  options: [.processor(processor)])
        }
        contactNameLabel.text = item.contact.name
    }
}
