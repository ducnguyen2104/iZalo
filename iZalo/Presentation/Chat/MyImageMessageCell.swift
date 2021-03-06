//
//  MyImageMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 10/17/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit

class MyImageMessageCell: UITableViewCell {

    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendingLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    private func setupLayout() {
        self.messageImageView.kf.indicatorType = .activity
        self.selectionStyle = .none
        self.messageContainerView.layer.cornerRadius = 10
        self.messageContainerView.layer.borderWidth = 0.1
        self.messageContainerView.layer.borderColor = Color.mainBlueColor.cgColor
        self.sendingLabel.isHidden = true
    }

    func bind(item: MessageItem, image: UIImage?) {
        if item.message.content != "url" {
            print("bind by url")
            self.sendingLabel.isHidden = true
            self.sendingLabelHeightConstraint.constant = 0
            self.messageImageView.kf.setImage(with: URL(string: item.message.content))
        }
        else if image != nil {
            print("bind by image")
            self.sendingLabel.isHidden = false
            self.sendingLabelHeightConstraint.constant = 20
            self.messageImageView.image = image!
        }
        if !item.isTimeHidden {
            self.timestampLabel.isHidden = false
            self.timestampLabelHeightConstraint.constant = 20
            self.timestampLabel.text = item.message.timestampInString
        } else {
            self.timestampLabelHeightConstraint.constant = 0
            self.timestampLabel.isHidden = true
        }	
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
