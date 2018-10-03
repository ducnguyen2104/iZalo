//
//  OthersMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 9/27/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import Kingfisher

class OthersMessageCell: BaseMessageCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var messageContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageContainer.layer.cornerRadius = 10
        
        self.messageContainer.layer.borderWidth = 0.1
        self.messageContainer.layer.borderColor = UIColor.gray.cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(item: MessageItem) {
        messageLabel.text = item.message.content
        timestampLabel.text = item.message.timestampInString
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        avatarImageView.kf.setImage(with: URL(string: Constant.defaultAvatarURL), placeholder: nil,  options: [.processor(processor)])
    }
}
