//
//  MessageFirebaseSource.swift
//  iZalo
//
//  Created by CPU11613 on 10/1/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

class MessageFirebaseSource: MessageRemoteSource {
    
    private let ref: DatabaseReference! = Database.database().reference()
    
    func sendMessage(request: SendMessageRequest) -> Observable<Bool> {
        return Observable.create { [unowned self] (observer) in
            self.ref.child("message").child(request.message.conversationId).child(request.message.id).setValue(request.toDictionary())
            let childUpdates = ["/message/\(request.message.conversationId)/\(request.message.id)" : request.toDictionary(),
                                "conversation/\(request.message.conversationId)/lastMessage" : request.toDictionary()]
                self.ref.updateChildValues(childUpdates)
            {
                (error:Error?, ref:DatabaseReference) in
                if error != nil {
                    observer.onNext(false)
                } else {
                    observer.onNext(true)
                }
            }
            return Disposables.create()
        }
    }
    
    func getMessage(conversation: Conversation, user: User) -> Observable<[Message]> {
        return Observable.create { [unowned self] (observer) in
            var messageObjects: [Message] = []
            self.ref.child("message").child(conversation.id).queryOrdered(byChild: "timestamp").observe(.value, with: { (datasnapshot) in
                if(!(datasnapshot.value is NSNull)) {
                    for data in ((datasnapshot.children.allObjects as? [DataSnapshot])!) {
                        let value = MessageResponse(value: data.value as! NSDictionary)
                        let message = value.convert()
                        messageObjects.append(message)
                        if (messageObjects.count == datasnapshot.childrenCount) { //check for last message
                            if(messageObjects.count > 0) {
                                print("load message: \(messageObjects.count)")
                                observer.onNext(messageObjects.reversed())
                                messageObjects = []
                                //observer.onCompleted()
                            } else {
                                observer.onError(ParseDataError(parseClass: "MessageResponse", errorMessage: "Cuộc hội thoại không tồn tại"))
                            }
                        }
                    }
                }
            })
            return Disposables.create()
        }
    }
}
