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
        print("Contact Firebase Source, get contacts of username: \(user.username)")
        return Observable.create{ [unowned self] (observer) in
            if user.contacts.count == 0 {
                observer.onCompleted()
            }
            var contactObjects: [Contact] = []
            for id in user.contacts {
                self.ref.child("user").child(id).observeSingleEvent(of: .value, with: {(datasnapshot) in
                    if(!(datasnapshot.value is NSNull)) {
                        let value = UserResponse(value: datasnapshot.value as! NSDictionary)
                        let contact = value.convertToContact()
                        contactObjects.append(contact)
                        if(user.contacts.firstIndex(of: id) == user.contacts.count - 1) { //check for last element
                            if(contactObjects.count > 0) {
                                observer.onNext(contactObjects)
                                observer.onCompleted()
                            }
                            else {
                                observer.onError(ParseDataError(parseClass: "UserResponse", errorMessage: "Danh bạ không tồn tại"))
                            }
                        }
                        
                    }
                })
            }
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
