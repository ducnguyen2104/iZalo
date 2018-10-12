//
//  SettingVM.swift
//  iZalo
//
//  Created by CPU11613 on 10/11/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class SettingVM: ViewModelDelegate {
    private let disposeBag = DisposeBag()
    private let currentUsername: String
    private weak var displayLogic: SettingDisplayLogic?
    
    init(displayLogic: SettingDisplayLogic, currentUsername: String) {
        self.displayLogic = displayLogic
        self.currentUsername = currentUsername
    }
    
    func transform(input: SettingVM.Input) -> SettingVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        input.logoutTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.gotoLogin()
            })
            .disposed(by: self.disposeBag)
        
        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

extension SettingVM {
    public struct Input {
        let logoutTrigger: Driver<Void>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
    }
}
