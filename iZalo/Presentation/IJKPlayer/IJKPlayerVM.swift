//
//  IJKPlayerVM.swift
//  iZalo
//
//  Created by CPU11613 on 11/22/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class IJKPlayerVM: ViewModelDelegate {
    private let disposeBag = DisposeBag()
    private weak var displayLogic: IJKPlayerDisplayLogic?
    
    init(displayLogic: IJKPlayerDisplayLogic) {
        self.displayLogic = displayLogic
    }
    
    func transform(input: IJKPlayerVM.Input) -> IJKPlayerVM.Output {
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        input.backTrigger
            .drive(onNext: { [unowned self] in
                print("backVM")
                self.displayLogic?.goBack()
            })
            .disposed(by: self.disposeBag)
        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

extension IJKPlayerVM {
    public struct Input{
        let backTrigger: Driver<Void>
    }
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
    }
}
