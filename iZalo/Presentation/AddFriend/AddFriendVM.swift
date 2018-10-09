//
//  AddFriendVM.swift
//  iZalo
//
//  Created by CPU11613 on 10/9/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class AddFriendVM: ViewModelDelegate {
    public let searchText = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()
    private weak var displayLogic: AddFriendDisplayLogic?
    private let searchUsernameUseCase = SearchUsernameUseCase()
    private let currentUsername: String
    
    init(displayLogic: AddFriendDisplayLogic, currentUsername: String) {
        self.displayLogic = displayLogic
        self.currentUsername = currentUsername
    }
    
    func transform(input: AddFriendVM.Input) -> AddFriendVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        (input.searchText <-> self.searchText).disposed(by: self.disposeBag)
        
        input.backTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
            .disposed(by: self.disposeBag)
        
        input.searchTrigger
            .flatMap{ [unowned self] (_) -> Driver<ContactSearchResult> in
                return Observable.deferred {[unowned self] in
                    guard !self.searchText.value.isEmpty else {
                        return Observable.error(ValidateError(message: "Nội dung tìm kiếm không được để trống"))
                    }
                    return Observable.just(SearchUsernameRequest(username: self.searchText.value, currentUsername: self.currentUsername))
                    }
                    .flatMap{ [unowned self] (request) -> Observable<ContactSearchResult> in
                        return self.searchUsernameUseCase
                            .execute(request: request)
                            .do(onNext: {[unowned self] (result) in
                                self.displayLogic?.showResult(result: result)
                            })
                    }
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
    
}

extension AddFriendVM {
    public struct Input {
        let backTrigger: Driver<Void>
        let searchText: ControlProperty<String>
        let searchTrigger: Driver<Void>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
    }
}
