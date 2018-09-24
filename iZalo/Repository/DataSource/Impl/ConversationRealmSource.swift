//
//  ConversationRealmSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class ConversationRealmSource: ConversationLocalSource {
    
    func loadConversation() -> Observable<[Conversation]> {
        return Observable.deferred {
            let realm = try Realm()
            let conversations: [Conversation] = realm.objects(ConversationRealm.self).map { (conversationRealm) -> Conversation in
                return conversationRealm.convert()
            }
            return Observable.just(conversations)
        }
    }
    
    func persistConversation(conversations: [Conversation]) -> Observable<Bool> {
        return Observable.deferred {
            let realm = try Realm()
            try realm.write {
                realm.add(conversations.map { ConversationRealm.from(conversation: $0) }, update: true)
            }
            return Observable.just(true)
        }
    }
    
}
