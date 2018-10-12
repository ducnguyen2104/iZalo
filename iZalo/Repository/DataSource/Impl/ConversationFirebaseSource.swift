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
        return Observable.create { [unowned self] (observer) in
            self.ref.child("user").child(user.username).child("conversations").observe(.value, with: {(conversationsSnapshot) in
                
                var conversationObjects: [Conversation] = []
                for singleSnapshot in conversationsSnapshot.children {
                    let conversationId = (singleSnapshot as! DataSnapshot).value as! String
                    self.ref.child("conversation").child(conversationId).observeSingleEvent(of: .value, with: {(datasnapshot) in
                        if(!(datasnapshot.value is NSNull)) {
                            let value = ConversationResponse(value: datasnapshot.value as! NSDictionary)
                            let conversation = value.convert(currentUsername: user.username)
                            conversationObjects.append(conversation)
                            if(conversationObjects.count == conversationsSnapshot.childrenCount) { //check for last element
                                if(conversationObjects.count > 0) {
                                    observer.onNext(conversationObjects)
                                    conversationObjects = []
//                                    observer.onCompleted()
                                    
                                } else {
                                    observer.onError(ParseDataError(parseClass: "ConversationResponse", errorMessage: "Lịch sử tin nhắn không tồn tại"))
                                }
                            }
                        }
                    })
                }
                if conversationsSnapshot.childrenCount == 0 {
                    observer.onNext([])
                }
            })
            
            
            return Disposables.create()
        }
    }
}
