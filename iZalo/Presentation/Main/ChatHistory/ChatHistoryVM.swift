//
//  ChatHistoryVM.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatHistoryVM: ViewModelDelegate {
    
    public let items = BehaviorRelay<[ConversationItem]>(value: [])
    private weak var displayLogic: ChatHistoryDisplayLogic?
    private let loadConversationUseCase = LoadConversationUseCase()
    private let disposeBag = DisposeBag()
    
    init(displayLogic: ChatHistoryDisplayLogic) {
        self.displayLogic = displayLogic
    }
    
    func transform(input: ChatHistoryVM.Input) -> ChatHistoryVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        print("ChatHistoryVM transform")
        input.trigger
            .flatMap{[unowned self] (_) -> Driver<[Conversation]> in
                return self.loadConversationUseCase.execute(request: ())
                    .do(onNext: { (conversations) in
                        self.items.accept(conversations.map { (conversation) in
                            return ConversationItem(conversation: conversation)
                        })
                    })
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }.drive()
            .disposed(by: self.disposeBag)

        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver(),
                      items: self.items.asDriver())
    }
}

extension ChatHistoryVM {
    
    public struct Input {
        let trigger: Driver<Void>
        let selectTrigger: Driver<IndexPath>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
        let items: Driver<[ConversationItem]>
    }
}
