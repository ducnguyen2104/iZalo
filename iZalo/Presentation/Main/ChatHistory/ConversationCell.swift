//
//  ConversationCell.swift
//  iZalo
//
//  Created by CPU11613 on 9/20/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var avtImageView: UIImageView!
    @IBOutlet weak var conversationNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.avtImageView.layer.cornerRadius = 20
    }
    
    func bind(item: ConversationItem) {
        conversationNameLabel.text = item.conversation.name
        timestampLabel.text = item.conversation.lastMessage.timestampInString
        var sender = item.conversation.lastMessage.senderId == item.currentUsername ? "Bạn" : item.conversation.lastMessage.senderId
        switch item.conversation.lastMessage.type {
        case Constant.textMessage:
            lastMessageLabel.text = "\(sender): \(item.conversation.lastMessage.content)"
        case Constant.imageMessage:
            lastMessageLabel.text = " \(sender) đã gửi một ảnh"
        case Constant.voiceMessage:
            lastMessageLabel.text = " \(sender) đã gửi một đoạn ghi âm"
        case Constant.videoMessage:
            lastMessageLabel.text = " \(sender) đã gửi một video"
        default:
            lastMessageLabel.text = item.conversation.lastMessage.content
        }
        item.contactObservable.subscribe(onNext: { (contact) in
            self.avtImageView.kf.setImage(with: URL(string: contact.avatarURL))
            self.conversationNameLabel.text = contact.name
            sender = item.conversation.lastMessage.senderId == item.currentUsername ? "Bạn" : contact.name
            switch item.conversation.lastMessage.type {
            case Constant.textMessage:
                self.lastMessageLabel.text = "\(sender): \(item.conversation.lastMessage.content)"
            case Constant.imageMessage:
                self.lastMessageLabel.text = " \(sender) đã gửi một ảnh"
            case Constant.voiceMessage:
                self.lastMessageLabel.text = " \(sender) đã gửi một đoạn ghi âm"
            case Constant.videoMessage:
                self.lastMessageLabel.text = " \(sender) đã gửi một video"
            default:
                self.lastMessageLabel.text = item.conversation.lastMessage.content
            }
        })
        
    }
    
}
