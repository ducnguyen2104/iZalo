//
//  LoadContactUseCase.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class LoadContactUseCase: UseCase {
    
    private let repository: ContactRepository = ContactRepositoryFactory.sharedInstance
    
    public typealias TRequest = Void
    public typealias TResponse = [Contact]
    
    public func execute(request: Void) -> Observable<[Contact]> {
        print("LoadContactUseCase execute")
        return self.repository
            .loadContact()
            .asObservable()
    }
}
