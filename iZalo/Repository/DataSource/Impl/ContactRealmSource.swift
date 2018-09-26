//
//  ContactRealmSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class ContactRealmSource: ContactLocalSource {
    
    func loadContact() -> Observable<[Contact]> {
        return Observable.deferred {
            let realm = try Realm()
            let contacts: [Contact] = realm.objects(ContactRealm.self).map { (contactRealm) -> Contact in
                return contactRealm.convert()
            }
            return Observable.just(contacts)
        }
    }
    
    func persistContact(contacts: [Contact]) -> Observable<Bool> {
        return Observable.deferred {
            let realm = try Realm()
            try realm.write {
                realm.add(contacts.map { ContactRealm.from(contact: $0) }, update: true)
            }
            return Observable.just(true)
        }
    }
}
