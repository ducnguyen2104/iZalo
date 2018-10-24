//
//  ConversationCell.swift
//  iZalo
//
//  Created by CPU11613 on 9/20/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import Kingfisher

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
        timestampLabel.text = self.calculateTime(timestamp: item.conversation.lastMessage.timestamp)
        var sender = item.conversation.lastMessage.senderId == item.currentUsername ? "Bạn" : item.conversation.lastMessage.senderId
        switch item.conversation.lastMessage.type {
        case Constant.textMessage:
            lastMessageLabel.text = """
            \(sender): \(item.conversation.lastMessage.content
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "<i>", with: "")
            .replacingOccurrences(of: "<mark>", with: "")
            .replacingOccurrences(of: "<del>", with: "")
            .replacingOccurrences(of: "<ins>", with: "")
            .replacingOccurrences(of: "<sub>", with: "")
            .replacingOccurrences(of: "<sup>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
            .replacingOccurrences(of: "</i>", with: "")
            .replacingOccurrences(of: "</mark>", with: "")
            .replacingOccurrences(of: "</del>", with: "")
            .replacingOccurrences(of: "</ins>", with: "")
            .replacingOccurrences(of: "</sub>", with: "")
            .replacingOccurrences(of: "</sup>", with: ""))
            """
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
            self.avtImageView.kf.setImage(with: URL(string: contact.avatarURL), placeholder: nil,  options: [.processor(Constant.avatarImageProcessor)])
            self.conversationNameLabel.text = contact.name
            sender = item.conversation.lastMessage.senderId == item.currentUsername ? "Bạn" : contact.name
            switch item.conversation.lastMessage.type {
            case Constant.textMessage:
                self.lastMessageLabel.text = """
                \(sender): \(item.conversation.lastMessage.content
                .replacingOccurrences(of: "<b>", with: "")
                .replacingOccurrences(of: "<i>", with: "")
                .replacingOccurrences(of: "<mark>", with: "")
                .replacingOccurrences(of: "<del>", with: "")
                .replacingOccurrences(of: "<ins>", with: "")
                .replacingOccurrences(of: "<sub>", with: "")
                .replacingOccurrences(of: "<sup>", with: "")
                .replacingOccurrences(of: "</b>", with: "")
                .replacingOccurrences(of: "</i>", with: "")
                .replacingOccurrences(of: "</mark>", with: "")
                .replacingOccurrences(of: "</del>", with: "")
                .replacingOccurrences(of: "</ins>", with: "")
                .replacingOccurrences(of: "</sub>", with: "")
                .replacingOccurrences(of: "</sup>", with: ""))
                """
            case Constant.imageMessage:
                self.lastMessageLabel.text = "\(sender): [Ảnh]"
            case Constant.voiceMessage:
                self.lastMessageLabel.text = "\(sender): [Audio]"
            case Constant.videoMessage:
                self.lastMessageLabel.text = "\(sender): [Video]"
            case Constant.nameCardMessage:
                self.lastMessageLabel.text = "\(sender): [Danh thiếp]"
            case Constant.locationMessage:
                self.lastMessageLabel.text = "\(sender): [Vị trí]"
            default:
                self.lastMessageLabel.text = item.conversation.lastMessage.content
            }
        })
        
    }
    func calculateTime(timestamp: Int) -> String {
        var returnString = ""
        let date = Date()
        let currentTimestamp = Int(date.timeIntervalSince1970)
        let diffTimestamp = (currentTimestamp - timestamp)
        if (diffTimestamp < 60) {
            returnString = "\(diffTimestamp) giây"
        } else if (diffTimestamp < 60*60) {
            returnString = "\(Int(diffTimestamp/60)) phút"
        } else if (diffTimestamp < 60*60*24) {
            returnString = "\(Int(diffTimestamp/(60*60))) giờ"
        } else if (diffTimestamp < 60*60*24*7) {
            returnString = "\(Int(diffTimestamp/(60*60*24))) ngày"
        } else if (diffTimestamp < 60*60*24*30) {
            returnString = "\(Int(diffTimestamp/(60*60*24*7))) tuần"
        } else if (diffTimestamp < 60*60*24*30*12) {
            returnString = "\(Int(diffTimestamp/(60*60*24*30))) tháng"
        } else {
            returnString = "\(Int(diffTimestamp/(60*60*24*30*12))) năm"
        }
        return returnString
    }
}
