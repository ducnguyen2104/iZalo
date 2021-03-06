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
    @IBOutlet weak var downloadImageView: UIImageView!
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
        
    }
    
    private func setupLayout() {
        self.activityIndicator.isHidden = true
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
        if item.message.content.split(separator: ",")[0] == "url" {
            showIndicator()
        } else {
            hideIndicator()
        }
    }
    
    func showIndicator() {
        self.downloadImageView.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func hideIndicator() {
        self.downloadImageView.isHidden = false
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
