//
//  MessageLocalSource.swift
//  iZalo
//
//  Created by CPU11613 on 10/1/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol MessageLocalSource {
    func loadMessage() -> Observable<[Message]>
    func persistMessage(messages: [Message]) -> Observable<Bool>
}

class MessageLocalSourceFactory {
    static let sharedInstance: MessageLocalSource = MessageRealmSource()
}
