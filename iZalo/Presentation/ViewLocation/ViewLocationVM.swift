//
//  ViewLocationVM.swift
//  iZalo
//
//  Created by CPU11613 on 10/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ViewLocationVM: ViewModelDelegate {
    private let disposeBag = DisposeBag()
    private weak var displayLogic: ViewLocationtDisplayLogic?
    
    init(displayLogic: ViewLocationtDisplayLogic) {
        self.displayLogic = displayLogic
    }
    
    func transform(input: ViewLocationVM.Input) -> ViewLocationVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        input.backTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
            .disposed(by: self.disposeBag)
        input.myLocationTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.pointToMyLocation()
            })
            .disposed(by: self.disposeBag)
        
        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
extension ViewLocationVM {
    
    public struct Input {
        let backTrigger: Driver<Void>
        let myLocationTrigger: Driver<Void>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
    }
}
