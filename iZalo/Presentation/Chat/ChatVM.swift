//
//  ChatVM.swift
//  iZalo
//
//  Created by CPU11613 on 9/27/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

final class ChatVM: ViewModelDelegate {
    
    //    public let items = BehaviorRelay<[MessageItem]>(value: [])
    public let conversation: Conversation
    public let currentUsername: String
    private weak var displayLogic: ChatDisplayLogic?
    private let disposeBag = DisposeBag()
    public let textMessage = BehaviorRelay<String>(value: "")
    private let sendMessageUsecase = SendMessageUsecase()
    private let loadMessageUsecase = LoadMessageUseCase()
    private let ref: DatabaseReference! = Database.database().reference()
    
    public let items = BehaviorRelay<[MessageItem]>(value: [])
    
    init(conversation: Conversation, currentUsername: String, displayLogic: ChatDisplayLogic) {
        self.conversation = conversation
        self.currentUsername = currentUsername
        self.displayLogic = displayLogic
    }
    
    func transform(input: ChatVM.Input) -> ChatVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        (input.textMessage <-> self.textMessage).disposed(by: self.disposeBag)
        
        input.trigger
        .flatMap{[unowned self] (_) -> Driver<[Message]> in
            return self.loadMessageUsecase.execute(request: LoadMessageRequest(conversation: self.conversation))
            .do(onNext: { (messages) in
                print("load message, next \(messages.count)")
                self.items.accept(messages.map { (message) in
                    return MessageItem(message: message, currentUsername: self.currentUsername)
                })
            })
            .trackActivity(activityIndicator)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
        }.drive()
        .disposed(by: self.disposeBag)
        
        input.backTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
            .disposed(by: self.disposeBag)
        
        input.sendTrigger
            .flatMap { [unowned self] () -> Driver<Bool> in
                self.displayLogic?.hideKeyboard()
                self.displayLogic?.clearInputTextField()
                return Observable.deferred { [unowned self] in
                    guard !self.textMessage.value.isEmpty else {
                        return Observable.error(ValidateError(message: "null message"))
                    }
                    
                    let date = Date()
                    let timestamp = Int(date.timeIntervalSince1970)
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minute = calendar.component(.minute, from: date)
                    return Observable.just(SendMessageRequest(message: Message(id: "\(self.currentUsername)\(timestamp)", senderId: self.currentUsername, conversationId: self.conversation.id, content: self.textMessage.value, type: Constant.textMessage, timestamp: timestamp, timestampInString: "\(hour):\(minute)")))
                    }
                    .flatMap{ [unowned self] (request) -> Observable<Bool> in
                        return self.sendMessageUsecase
                            .execute(request: request)
                            .do(onNext: {[unowned self] (_) in
                                self.displayLogic?.updateSendStatus()
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
        
        
        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver(),
                      items: self.items.asDriver())
    }
}

extension ChatVM {
    
    public struct Input {
        let trigger: Driver<Void>
        let backTrigger: Driver<Void>
        let textMessage: ControlProperty<String>
        let sendTrigger: Driver<Void>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
        let items: Driver<[MessageItem]>
    }
    
}
