//
//  UserFirebaseSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import Firebase
import ObjectMapper

class UserFirebaseSource: UserRemoteSource {
    
    private let ref: DatabaseReference! = Database.database().reference()
    
    func login(request: LoginRequest) -> Observable<User> {
        //        print("Request login: \(request.username)")
        return Observable.create { [unowned self] (observer) in
            self.ref.child("user").child(request.username)
                .observeSingleEvent(of: .value, with: {(datasnapshot) in
                    if(!(datasnapshot.value is NSNull)){
                        let value = UserResponse(value: datasnapshot.value as! NSDictionary)
                        let user = value.convert()
                        if(user.password == request.password){
                            observer.onNext(user)
                            print("Login success: \(user.username)")
                            observer.onCompleted()
                        }
                        else {
                            observer.onError(ParseDataError(parseClass: "LoginResponse", errorMessage: "Sai mật khẩu"))
                        }
                    } else {
                        print("Null value")
                        observer.onError(ParseDataError(parseClass: "LoginResponse", errorMessage: "Người dùng không tồn tại"))
                    }
                }, withCancel: { (error) in
                    observer.onError(error)
                })
            return Disposables.create()
        }
    }
    
    func signup(request: SignupRequest) -> Observable<User> {
        return Observable.create { [unowned self] (observer) in
            self.ref.child("user").child(request.username).observeSingleEvent(of: .value, with: { (datasnapshot) in
                if datasnapshot.exists() {
                    observer.onError(ParseDataError(parseClass: "UserResponse", errorMessage: "Username đã tồn tại, vui lòng chọn username khác"))
                } else {
                    self.ref.child("user").child(request.username).setValue(request.toDictionary()) {
                        (error:Error?, ref:DatabaseReference) in
                        if error != nil {
                            observer.onError(ParseDataError(parseClass: "UserResponse", errorMessage: "Lỗi, vui lòng thử lại"))
                        } else {
                            observer.onNext(request.makeUser())
                            observer.onCompleted()
                        }
                    }
                }
            })
            return Disposables.create()
        }
    }
    
    func getAvatarURL(username: String) -> Observable<String> {
        return Observable.create { [unowned self] (observer) in
            self.ref.child("user").child(username).child("avatarURL")
                .observeSingleEvent(of: .value, with: { (datasnapshot) in
                    if(!(datasnapshot.value is NSNull)){
                        observer.onNext(datasnapshot.value as! String)
                        observer.onCompleted()
                    }
                    else {
                        observer.onNext(Constant.defaultAvatarURL)
                        observer.onCompleted()
                    }
                })
            return Disposables.create()
        }
    }
    
    func addContact(request: AddContactRequest) -> Observable<Bool> {
        return Observable.create { [unowned self] (observer) in
            self.ref.child("user").child(request.currentUsername).child("contacts").child(request.targetUsername).setValue(request.targetUsername)
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
}
