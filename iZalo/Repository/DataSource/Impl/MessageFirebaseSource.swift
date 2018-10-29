//
//  MessageFirebaseSource.swift
//  iZalo
//
//  Created by CPU11613 on 10/1/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import FirebaseDatabase
import RxSwift
import FirebaseStorage

class MessageFirebaseSource: MessageRemoteSource {
    
    private let ref: DatabaseReference! = Database.database().reference()
    private let storageRef: StorageReference! = Storage.storage().reference()
    
    func sendMessage(request: SendMessageRequest) -> Observable<Bool> {
        
        return Observable.create { [unowned self] (observer) in
            self.ref.child("message").child(request.message.conversationId).child(request.message.id).setValue(request.messageToDictionary())
            var childUpdates:[String : Any] = [
                "/message/\(request.message.conversationId)/\(request.message.id)" : request.messageToDictionary(),
                "conversation/\(request.message.conversationId)" : request.conversationToDictionary(),
                                ]
            for user in request.conversation.members {
                childUpdates["user/\(user)/conversations/\(request.conversation.id)"] = request.conversation.id
            }
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
            self.ref.child("message").child(conversation.id)
                .queryOrdered(byChild: "timestamp")
                .queryLimited(toLast: 15)
                .observe(.value, with: { (datasnapshot) in
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
                else {
                    observer.onNext([])
                }
            })
            return Disposables.create()
        }
    }
    
    func uploadFile(request: UploadFileMessageRequest) -> Observable<String> {
        return Observable.create{[unowned self] (observer) in
            switch request.type{
            case Constant.imageMessage:
                let fileRef = self.storageRef.child("image/\(request.url.lastPathComponent)")
                fileRef.putFile(from: request.url, metadata: nil)
                { metadata, error in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    // Metadata contains file metadata such as size, content-type.
                    let size = metadata.size
                    // You can also access to download URL after upload.
                    fileRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        observer.onNext(downloadURL.absoluteString)
                        observer.onCompleted()
                    }
                }
            case Constant.fileMessage:
                let fileRef = self.storageRef.child(" /\(request.url.lastPathComponent)")
                fileRef.putFile(from: request.url, metadata: nil)
                { metadata, error in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    // Metadata contains file metadata such as size, content-type.
                    let size = metadata.size
                    // You can also access to download URL after upload.
                    fileRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        observer.onNext(downloadURL.absoluteString)
                        observer.onCompleted()
                    }
                }
            default:
                observer.onCompleted()
            }
            
            
            return Disposables.create()
        }
    }
}
