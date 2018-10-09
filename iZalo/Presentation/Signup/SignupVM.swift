//
//  SignupVM.swift
//  iZalo
//
//  Created by CPU11613 on 10/9/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class SignupVM: ViewModelDelegate {
    public let username = BehaviorRelay<String>(value: "")
    public let password = BehaviorRelay<String>(value: "")
    public let confirmPassword = BehaviorRelay<String>(value: "")
    public let fullname = BehaviorRelay<String>(value: "")
    public let phoneNumber = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()
    private weak var displayLogic: SignupDisplayLogic?
    private let signupUsecase = SignupUseCase()
    
    init(displayLogic: SignupDisplayLogic) {
        self.displayLogic = displayLogic
    }
    
    func transform(input: SignupVM.Input) -> SignupVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        (input.username <-> self.username).disposed(by: self.disposeBag)
        (input.password <-> self.password).disposed(by: self.disposeBag)
        (input.confirmPassword <-> self.confirmPassword).disposed(by: self.disposeBag)
        (input.fullname <-> self.fullname).disposed(by: self.disposeBag)
        (input.phoneNumber <-> self.phoneNumber).disposed(by: self.disposeBag)
        
        input.loginTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.gotoLogin()
            })
            .disposed(by: self.disposeBag)
        
        input.signupTrigger
            .flatMap { [unowned self] (_)  -> Driver<User> in
                return Observable.deferred{ [unowned self] in
                    guard !self.username.value.isEmpty else {
                        return Observable.error(ValidateError(message: "Tên đăng nhập không được để trống"))
                    }
                    
                    guard !self.password.value.isEmpty else {
                        return Observable.error(ValidateError(message: "Mật khẩu không được để trống"))
                    }
                    
                    guard !self.password.value.isEmpty else {
                        return Observable.error(ValidateError(message: "Xác nhận mật khẩu không được để trống"))
                    }
                    
                    guard !self.password.value.isEmpty else {
                        return Observable.error(ValidateError(message: "Họ và tên không được để trống"))
                    }
                    
                    guard !self.password.value.isEmpty else {
                        return Observable.error(ValidateError(message: "Số điện thoại không được để trống"))
                    }
                    
                    guard self.password.value == self.confirmPassword.value else {
                        return Observable.error(ValidateError(message: "Xác nhận mật khẩu không khớp"))
                    }
                    
                    return Observable.just(SignupRequest(username: self.username.value, password: self.password.value, name: self.fullname.value, phone: self.phoneNumber.value))
                }
                .flatMap{ [unowned self] (request) -> Observable<User> in
                    return self.signupUsecase.execute(request: request)
                        .do(onNext: {[unowned self] (user) in
                            self.displayLogic?.gotoMain(currentUsername: user.username)
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

extension SignupVM {
    public struct Input{
        let loginTrigger: Driver<Void>
        let signupTrigger: Driver<Void>
        let username: ControlProperty<String>
        let password: ControlProperty<String>
        let confirmPassword: ControlProperty<String>
        let fullname: ControlProperty<String>
        let phoneNumber: ControlProperty<String>
    }
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
    }
}
