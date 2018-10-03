//
//  MyMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 9/27/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit

class MyMessageCell: BaseMessageCell {

    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var messageContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.messageContainer.layer.cornerRadius = 10
        self.messageContainer.layer.borderWidth = 0.1
        self.messageContainer.layer.borderColor = Color.mainBlueColor.cgColor
        // Initialization code
    }

    func bind(item: MessageItem) {
        messageLabel.text = item.message.content
        timestampLabel.text = item.message.timestampInString
    }
    
}
