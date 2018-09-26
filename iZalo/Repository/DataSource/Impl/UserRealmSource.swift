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
        return Observable.deferred {
            let realm = try Realm()
            return Observable.just(realm.objects(UserRealm.self).first?.convert())
        }
    }
    
    func persistUser(user: User) -> Observable<Bool> {
        print("UserRealmSource persistUser")
        return Observable.deferred {
            do {
                let realm = try Realm()
                do {
                    try realm.write {
                        realm.add(UserRealm.from(user: user), update: true)
                    }
                }
                catch {
                    fatalError("failed to write")
                }
            }
            catch {
                fatalError("failed to create Realm instance")
            }
            
            
            return Observable.just(true)
        }
    }
}
