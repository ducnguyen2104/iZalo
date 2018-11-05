//
//  MessageRealmSource.swift
//  iZalo
//
//  Created by CPU11613 on 10/1/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class MessageRealmSource: MessageLocalSource {
    
    func loadMessage() -> Observable<[Message]> {
        return Observable.deferred {
            let realm = try Realm()
            let messages: [Message] = realm.objects(MessageRealm.self).map { (messageRealm) -> Message in
                return messageRealm.convert()
            }
            return Observable.just(messages)
        }
    }
    
    func persistMessages(messages: [Message]) -> Observable<[Message]> {
        return Observable.deferred {
            let realm = try Realm()
            try realm.write {
                realm.add(messages.map { MessageRealm.from(message: $0) }, update: true)
            }
            return Observable.just(messages.sorted(by: { $0.timestamp > $1.timestamp }))
        }
    }
    
    func persistMessage(message: Message) -> Observable<[Message]> {
        return Observable.deferred {
            let realm = try Realm()
            try realm.write {
                realm.add( MessageRealm.from(message: message) , update: true)
            }
            let realmMessages = realm.objects(MessageRealm.self).filter("conversationId = '\(message.conversationId)'")
            var messages: [Message] = []
            for messageRealm in realmMessages {
                messages.append(messageRealm.convert())
            }
            
            return Observable.just(messages.sorted(by: { $0.timestamp > $1.timestamp }))
        }
    }
}
