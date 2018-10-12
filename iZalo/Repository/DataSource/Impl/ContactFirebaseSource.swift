//
//  ContactFirebaseSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

class ContactFirebaseSource: ContactRemoteSource {
    
    private let ref: DatabaseReference! = Database.database().reference()
    
    func getContact(user: User) -> Observable<[Contact]> {
        return Observable.create{ [unowned self] (observer) in
            self.ref.child("user").child(user.username).child("contacts").observe(.value, with: {(contactsSnapshot) in
                
                var contactObjects: [Contact] = []
                for singleSnapshot in contactsSnapshot.children {
                    let targetUsername = (singleSnapshot as! DataSnapshot).value as! String
                    self.ref.child("user").child(targetUsername).observeSingleEvent(of: .value, with: {(datasnapshot) in
                        if(!(datasnapshot.value is NSNull)) {
                            let value = UserResponse(value: datasnapshot.value as! NSDictionary)
                            let contact = value.convertToContact()
                            contactObjects.append(contact)
                            
                            if(contactObjects.count == contactsSnapshot.childrenCount) { //check for last element
                                if(contactObjects.count > 0) {
                                    observer.onNext(contactObjects)
                                    contactObjects = []
                                    //observer.onCompleted()
                                }
                                else {
                                    observer.onError(ParseDataError(parseClass: "UserResponse", errorMessage: "Danh bạ không tồn tại"))
                                }
                            }
                            
                        }
                    })
                }
                if contactObjects.count == 0 {
                    observer.onNext([])
                }
            })
            return Disposables.create()
        }
    }
    
    func getContactInfo(username: String) -> Observable<Contact> {
        return Observable.create{ [unowned self] (observer) in
            self.ref.child("user").child(username).observeSingleEvent(of: .value, with: {(datasnapshot) in
                if(!(datasnapshot.value is NSNull)) {
                    let value = UserResponse(value: datasnapshot.value as! NSDictionary)
                    let contact = value.convertToContact()
                    observer.onNext(contact)
                    observer.onCompleted()
                }
                else {
                    observer.onError(ParseDataError(parseClass: "UserResponse", errorMessage: "Lỗi khi tải thông tin liên hệ"))
                }
            })
            return Disposables.create()
        }
    }
    
    func searchContact(username: String, currentUsername: String) -> Observable<ContactSearchResult> {
        return Observable.create{ [unowned self] (observer) in
            self.ref.child("user").child(username).observeSingleEvent(of: .value, with: {(datasnapshot) in
                if(!(datasnapshot.value is NSNull)) {
                    let value = UserResponse(value: datasnapshot.value as! NSDictionary)
                    let contact = value.convertToContact()
                    self.ref.child("user").child(currentUsername).child("contacts").child(username).observeSingleEvent(of: .value, with:{ (datasnapshot1) in
                        if datasnapshot1.exists() {
                            observer.onNext(ContactSearchResult(contact: contact, isFriend: true))
                            observer.onCompleted()
                        } else {
                            observer.onNext(ContactSearchResult(contact: contact, isFriend: false))
                            observer.onCompleted()
                        }
                    })
                }
                else {
                    observer.onError(ParseDataError(parseClass: "UserResponse", errorMessage: "Lỗi khi tải thông tin liên hệ"))
                }
            })
            return Disposables.create()
        }
    }
    
    func getAvatarURL(username: String) -> Observable<String> {
        return Observable.create{ [unowned self] (observer) in
            self.ref.child("user").child(username).child("avatarURL").observeSingleEvent(of: .value, with:{(datasnapshot) in
                if datasnapshot.value is NSNull {
                    observer.onNext(Constant.defaultAvatarURL)
                    observer.onCompleted()
                } else  {
                    observer.onNext((datasnapshot.value as! NSString) as String)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
}
