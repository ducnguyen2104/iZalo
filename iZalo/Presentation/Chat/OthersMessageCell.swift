//
//  OthersMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 9/27/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class OthersMessageCell: BaseMessageCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageContainer.layer.cornerRadius = 10
        
        self.messageContainer.layer.borderWidth = 0.1
        self.messageContainer.layer.borderColor = UIColor.gray.cgColor
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.height/2
        self.avatarImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(item: MessageItem, contactObservable: Observable<Contact>) {
        let tags = ["<b>", "<i>", "<mark>", "<del>", "<ins>", "<sub>", "<sup>"]
        
        if(tags.contains(where: item.message.content.contains)) { //check if message contains one of these tags
            let htmlString = stringProcessing(rawString: item.message.content)
            messageLabel.attributedText = htmlString
        } else {
            messageLabel.text = item.message.content
        }
        if !item.isTimeHidden {
            self.timestampLabel.isHidden = false
            self.timestampLabelHeightConstraint.constant = 20
            self.timestampLabel.text = item.message.timestampInString
        } else {
            self.timestampLabelHeightConstraint.constant = 5
            self.timestampLabel.isHidden = true
        }
        if !item.isAvatarHidden {
            self.avatarImageView.isHidden = false
            let _ = contactObservable.subscribe(onNext: {(contact) in
                self.avatarImageView.kf.setImage(with: URL(string: contact.avatarURL), placeholder: nil,  options: [.processor(Constant.avatarImageProcessor)])
            })
        } else {
            self.avatarImageView.isHidden = true
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
            print("process successfully")
            return NSMutableAttributedString(string: rawString, attributes: nil)
        }
    }
}
