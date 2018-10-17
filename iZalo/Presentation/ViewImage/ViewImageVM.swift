//
//  ViewImageVM.swift
//  iZalo
//
//  Created by CPU11613 on 10/17/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ViewImageVM: ViewModelDelegate {
    private let disposeBag = DisposeBag()
    private weak var displayLogic: ViewImageDisplayLogic?
    
    init(displayLogic: ViewImageDisplayLogic) {
        self.displayLogic = displayLogic
    }
    
    func transform(input: ViewImageVM.Input) -> ViewImageVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        input.backTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
            .disposed(by: self.disposeBag)
        
        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

extension ViewImageVM {
    public struct Input{
        let backTrigger: Driver<Void>
    }
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
    }
}
