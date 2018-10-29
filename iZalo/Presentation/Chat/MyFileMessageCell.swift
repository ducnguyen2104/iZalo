//
//  MyFileMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 10/29/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit

class MyFileMessageCell: UITableViewCell {
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
        
    }
    
    private func setupLayout() {
        self.selectionStyle = .none
        self.messageContainerView.layer.cornerRadius = 10
        self.messageContainerView.layer.borderWidth = 0.1
        self.messageContainerView.layer.borderColor = Color.mainBlueColor.cgColor
    }
    
    func bind(item: MessageItem) {
        if !item.isTimeHidden {
            self.timestampLabel.isHidden = false
            self.timestampLabelHeightConstraint.constant = 20
            self.timestampLabel.text = item.message.timestampInString
        } else {
            self.timestampLabelHeightConstraint.constant = 0
            self.timestampLabel.isHidden = true
        }
        let fileName = item.message.content.split(separator: ",")[1]
        let underlineAttriString = NSAttributedString(string: String(fileName), attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        self.fileNameLabel.attributedText = underlineAttriString
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
