//
//  PickLocationVM.swift
//  iZalo
//
//  Created by CPU11613 on 10/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PickLocationVM: ViewModelDelegate {
    private let disposeBag = DisposeBag()
    private weak var displayLogic: PickLocationtDisplayLogic?
    private let currentUsername: String
    private let conversation: Conversation
    private let sendMessageUsecase = SendMessageUsecase()
    public var lattitude: Double?
    public var longtitude: Double?
    
    init(displayLogic: PickLocationtDisplayLogic, currentUsername: String, conversationId: Conversation) {
        self.displayLogic = displayLogic
        self.currentUsername = currentUsername
        self.conversation = conversationId
    }
    
    func transform(input: PickLocationVM.Input) -> PickLocationVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        input.backTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
            .disposed(by: self.disposeBag)
        
        input.sendTrigger
            .flatMap {[unowned self] () -> Driver<Bool> in
                self.displayLogic?.goBack()
                return Observable.deferred{ [unowned self] in
                    let date = Date()
                    let timestamp = Int(date.timeIntervalSince1970)
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minute = calendar.component(.minute, from: date)
                    let message = Message(id:"\(self.currentUsername)\(timestamp)", senderId: self.currentUsername, conversationId: self.conversation.id, content: "\(self.lattitude ?? 0),\(self.longtitude ?? 0)", type: Constant.locationMessage, timestamp: timestamp, timestampInString: "\(hour):\(minute)")
                    return Observable.just(SendMessageRequest(message: message, conversation: self.conversation))
                }
                    .flatMap{ [unowned self] (request) -> Observable<Bool> in
                        return self.sendMessageUsecase
                            .execute(request: request)
                            .do(onNext: {[unowned self] (_) in
                                self.displayLogic?.goBack()
                                }, onError: {(_) in
                                    print("error!!")
                            })
                    }
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        input.myLocationTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.pointToMyLocation()
            })
            .disposed(by: self.disposeBag)
        
        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
    
    public func updateLatLong(latitude: Double, longtitude: Double) {
        self.lattitude = latitude
        self.longtitude = longtitude
    }
}

extension PickLocationVM {
    
    public struct Input {
        let sendTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let myLocationTrigger: Driver<Void>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
    }
}
