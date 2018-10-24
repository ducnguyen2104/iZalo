//
//  Constant.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import Kingfisher

struct Constant {
    
    static let textMessage = "text"
    static let imageMessage = "image"
    static let voiceMessage = "voice"
    static let videoMessage = "video"
    static let nameCardMessage = "nameCard"
    static let locationMessage = "location"
    static let defaultAvatarURL = "https://firebasestorage.googleapis.com/v0/b/izalo-ac522.appspot.com/o/avatar%2Fcontact512.png?alt=media&token=c8b0d4df-c4c9-4db8-9a0c-57b878f20245"
    static let avatarImageProcessor = ResizingImageProcessor(referenceSize: CGSize(width: 60, height: 60)) >> RoundCornerImageProcessor(cornerRadius: 30)
    static let dummyMessage = Message(id: "dummy", senderId: "dummy", conversationId: "dummy", content: "", type: Constant.textMessage, timestamp: 0000, timestampInString: "dummy")
}
