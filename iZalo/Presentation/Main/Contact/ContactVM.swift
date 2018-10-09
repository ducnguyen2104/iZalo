//
//  ContactVM.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ContactVM: ViewModelDelegate {
    
    public let items = BehaviorRelay<[ContactItem]>(value: [])
    private weak var displayLogic: ContactDisplayLogic?
    private let loadContactUseCase = LoadContactUseCase()
    private let disposeBag = DisposeBag()
    private let currentUsername: String
    
    init(displayLogic: ContactDisplayLogic, currentUsername: String) {
        self.displayLogic = displayLogic
        self.currentUsername = currentUsername
    }
    
    func transform(input: ContactVM.Input) -> ContactVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        print("ContactVM transform")
        input.trigger
            .flatMap{[unowned self] (_) -> Driver<[Contact]> in
                return self.loadContactUseCase.execute(request: LoadConversationAndContactRequest(username: self.currentUsername))
                    .do(onNext: { (contacts) in
                        self.items.accept(contacts.map { (contact) in
                            return ContactItem(contact: contact)
                        })
                    })
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }.drive()
            .disposed(by: self.disposeBag)
        
        input.addFriendTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.gotoAddFriend()
            })
            .disposed(by: self.disposeBag)
        
        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver(),
                      items: self.items.asDriver())
    }

}

extension ContactVM {

    public struct Input {
        let trigger: Driver<Void>
        let selectTrigger: Driver<IndexPath>
        let addFriendTrigger: Driver<Void>
    }
    
    public struct Output {
    let fetching: Driver<Bool>
    let error: Driver<Error>
    let items: Driver<[ContactItem]>
    }
}
