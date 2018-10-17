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
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.messageContainer.layer.cornerRadius = 10
        self.messageContainer.layer.borderWidth = 0.1
        self.messageContainer.layer.borderColor = Color.mainBlueColor.cgColor
        // Initialization code
    }
    
    func bind(item: MessageItem) {
        
        let tags = ["<b>", "<i>", "<mark>", "<del>", "<ins>", "<sub>", "<sup>"]
        
        if(tags.contains(where: item.message.content.contains)) { //check if message contains one of these tags
            print("html")
            let htmlString = stringProcessing(rawString: item.message.content)
            self.messageLabel.attributedText = htmlString
        } else {
            print("not html")
            self.messageLabel.text = item.message.content
        }
        if !item.isTimeHidden {
            self.timestampLabel.isHidden = false
            self.timestampLabelHeightConstraint.constant = 20
            self.timestampLabel.text = item.message.timestampInString
        } else {
            self.timestampLabelHeightConstraint.constant = 5
            self.timestampLabel.isHidden = true
        }
    }
    
    func stringProcessing(rawString: String) -> NSMutableAttributedString {
        
        let fontAddedString = "<font face=\"Helvetica Neue\" size=4.5\" \"> \(rawString)</font>"
        
        guard let data = fontAddedString.data(using: String.Encoding.unicode, allowLossyConversion: true) else {
            print("html failed to encode")
            return NSMutableAttributedString(string: rawString, attributes: nil)
        }
        print("html encoded")
        var mutableString: NSMutableAttributedString?
        try? mutableString = NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        
        if mutableString != nil {
            print("process successfully")
            return mutableString!
        } else {
            print("process unsuccessfully")
            return NSMutableAttributedString(string: rawString, attributes: nil)
        }
    }
}
