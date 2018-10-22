//
//  PickContactVM.swift
//  iZalo
//
//  Created by CPU11613 on 10/22/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PickContactVM: ViewModelDelegate {
    
    public let items = BehaviorRelay<[ContactItem]>(value: [])
    private let disposeBag = DisposeBag()
    private weak var displayLogic: PickContactDisplayLogic?
    private let loadContactUseCase = LoadContactUseCase()
    private let currentUsername: String
    private let conversation: Conversation
    private let sendMessageUsecase = SendMessageUsecase()
    
    init(displayLogic: PickContactDisplayLogic, currentUsername: String, conversationId: Conversation) {
        self.displayLogic = displayLogic
        self.currentUsername = currentUsername
        self.conversation = conversationId
    }
    
    func transform(input: PickContactVM.Input) -> PickContactVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
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
        
        input.selectTrigger
            .flatMap { (ip) -> Driver<Bool> in
                return Observable.deferred {
                    let item = self.items.value[ip.row]
                    let date = Date()
                    let timestamp = Int(date.timeIntervalSince1970)
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minute = calendar.component(.minute, from: date)
                    return Observable.just(SendMessageRequest(message: Message(id: "\(self.currentUsername)\(timestamp)", senderId: self.currentUsername, conversationId: self.conversation.id, content: item.contact.username, type: Constant.nameCardMessage, timestamp: timestamp, timestampInString: "\(hour):\(minute)"), conversation: self.conversation))
                    }
                    .flatMap{ [unowned self] (request) -> Observable<Bool> in
                        return self.sendMessageUsecase
                            .execute(request: request)
                            .do(onNext: {[unowned self] (_) in
                                self.displayLogic?.updateSendStatus()
                                self.displayLogic?.goBack()
                                }, onError: {(_) in
                                    print("error!!")
                            })
                    }
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        input.backTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
            .disposed(by: self.disposeBag)
        
        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver(),
                      items: self.items.asDriver())
    }
}

extension PickContactVM {
    
    public struct Input {
        let trigger: Driver<Void>
        let selectTrigger: Driver<IndexPath>
        let backTrigger: Driver<Void>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
        let items: Driver<[ContactItem]>
    }
}
