//
//  LoginVM.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


final class LoginVM: ViewModelDelegate {
    public let username = BehaviorRelay<String>(value: "ahihi")
    public let password = BehaviorRelay<String>(value: "ahihi")
    private let loginUseCase = LoginUseCase()
    private weak var displayLogic: LoginDisplayLogic?
    private let disposeBag = DisposeBag()
    
    init(displayLogic: LoginDisplayLogic) {
        self.displayLogic = displayLogic
    }
    
    func transform(input: LoginVM.Input) -> LoginVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        (input.username <-> self.username).disposed(by: self.disposeBag)
        (input.password <-> self.password).disposed(by: self.disposeBag)
        
        input.loginTrigger
            .flatMap { [unowned self] () -> Driver<Bool> in
                self.displayLogic?.hideKeyboard()
                return Observable.deferred { [unowned self] in
                    guard !self.username.value.isEmpty else {
                        return Observable.error(ValidateError(message: "Please input username"))
                    }
                    
                    guard !self.password.value.isEmpty else {
                        return Observable.error(ValidateError(message: "Please input password"))
                    }
                    
                    return Observable.just(LoginRequest(username: self.username.value, password: self.password.value))
                    }
                    .flatMap { [unowned self] (request) -> Observable<Bool> in
                        return self.loginUseCase
                            .execute(request: request)
                            .do(onNext: { [unowned self] (_) in
                                self.displayLogic?.goToMain()
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

extension LoginVM {
    public struct Input {
        let trigger: Driver<Void>
        let loginTrigger: Driver<Void>
        let signupTrigger: Driver<Void>
        let username: ControlProperty<String>
        let password: ControlProperty<String>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
    }
}
