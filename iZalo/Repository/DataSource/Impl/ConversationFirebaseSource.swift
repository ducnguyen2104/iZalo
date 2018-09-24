//
//  ConversationFirebaseSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

class ConversationFirebaseSource: ConversationRemoteSource {
    
    private let ref: DatabaseReference! = Database.database().reference()
    
    func getConversation(user: User) -> Observable<[Conversation]> {
        print("Conversation Firebase Source, get conversation of username: \(user.username)")
        return Observable.create { [unowned self] (observer) in
            if user.conversations.count == 0 {
                observer.onCompleted()
            }
            var conversationObjects: [Conversation] = []
            for id in user.conversations {
                self.ref.child("conversation").child(id).observeSingleEvent(of: .value, with: {(datasnapshot) in
                    if(!(datasnapshot.value is NSNull)) {
                        let value = ConversationResponse(value: datasnapshot.value as! NSDictionary)
                        let conversation = value.convert()
                        conversationObjects.append(conversation)
                        print(conversationObjects.count)
                        if(user.conversations.firstIndex(of: id) == user.conversations.count - 1) { //check for last element
                            if(conversationObjects.count > 0) {
                                observer.onNext(conversationObjects)
                                observer.onCompleted()
                            } else {
                                observer.onError(ParseDataError(parseClass: "ConversationResponse", errorMessage: "Các cuộc hội thoại không tồn tại"))
                            }
                        }
                    }
                })
                
            }
            print(conversationObjects.count)
            
            return Disposables.create()
        }
    }
}
