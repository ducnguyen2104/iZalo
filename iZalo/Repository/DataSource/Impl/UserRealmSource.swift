//
//  UserRealmSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class UserRealmSource: UserLocalSource {
    
    func getUser() -> Observable<User?> {
        return Observable<User?>.just(nil)
    }
    
    func persistUser(user: User) -> Observable<Bool> {
//        return Observable.deferred {
//            let realm = try Realm()
//            try realm.write {
//                realm.add(UserRealm.from(user: user), update: true)
//            }
//            return Observable.just(true)
//        }
        return Observable<Bool>.just(true)
    }
}
