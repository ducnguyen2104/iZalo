//
//  ViewLocationGGMapsVM.swift
//  iZalo
//
//  Created by CPU11613 on 10/25/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ViewLocationGGMapsVM: ViewModelDelegate {
    private let disposeBag = DisposeBag()
    private weak var displayLogic: ViewLocationtGGMapsDisplayLogic?
    
    init(displayLogic: ViewLocationtGGMapsDisplayLogic) {
        self.displayLogic = displayLogic
    }
    func transform(input: ViewLocationGGMapsVM.Input) -> ViewLocationGGMapsVM.Output {
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
extension ViewLocationGGMapsVM {
    
    public struct Input {
        let backTrigger: Driver<Void>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
    }
}
