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

final class ChatVM: ViewModelDelegate {
    
//    public let items = BehaviorRelay<[MessageItem]>(value: [])
    public let conversation: Conversation
    private weak var displayLogic: ChatDisplayLogic?
    private let disposeBag = DisposeBag()
    public let textMessage = BehaviorRelay<String>(value: "")
    
    init(conversation: Conversation, displayLogic: ChatDisplayLogic) {
        self.conversation = conversation
        self.displayLogic = displayLogic
    }
    
    func transform(input: ChatVM.Input) -> ChatVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        (input.textMessage <-> self.textMessage).disposed(by: self.disposeBag)
        
        input.backTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
            .disposed(by: self.disposeBag)
        
        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

extension ChatVM {
    
    public struct Input {
        let backTrigger: Driver<Void>
        let textMessage: ControlProperty<String>
        let sendTrigger: Driver<Void>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
//        let items: Driver<[Item]>
    }
    
}
