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
    
    func signup(request: SignUpRequest) -> Observable<User> {
        return Observable<User>.just(User(username: "ahihi", password: "ahihi", name: "a hi hi", phone: "123456", avatarURL: nil, conversations: [], contacts: []))
    }
    
}
