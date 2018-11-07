//
//  MessageRepository.swift
//  iZalo
//
//  Created by CPU11613 on 10/1/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol MessageRepository {
    func loadMessage(conversation: Conversation, username: String) -> Observable<[Message]>
    func sendMessage(request: SendMessageRequest) -> Observable<Bool>
    func uploadFile(request: UploadFileMessageRequest) -> Observable<String>
    func persistMessage(message: Message) -> Observable<[Message]>
    func loadAndPlayAudio(url: String) -> Observable<URL>
}

class MessageRepositoryFactory {
    public static let sharedInstance: MessageRepository = MessageRepositoryImpl(remoteSource: MessageRemoteSourceFactory.sharedInstance, localSource: MessageLocalSourceFactory.sharedInstance, userRepository: UserRepositoryFactory.sharedInstance)
}
