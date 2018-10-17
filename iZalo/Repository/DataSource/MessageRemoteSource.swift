//
//  MessageRemoteSource.swift
//  iZalo
//
//  Created by CPU11613 on 10/1/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol MessageRemoteSource {
    func sendMessage(request: SendMessageRequest) -> Observable<Bool>
    func getMessage(conversation: Conversation, user: User) -> Observable<[Message]>
    func uploadFile(request: UploadFileMessageRequest) -> Observable<String>
}

class MessageRemoteSourceFactory {
    public static let sharedInstance: MessageRemoteSource = MessageFirebaseSource()
}
