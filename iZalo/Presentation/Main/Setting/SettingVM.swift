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
import UIKit

final class SettingVM: ViewModelDelegate {
    private let disposeBag = DisposeBag()
    private let currentUsername: String
    private weak var displayLogic: SettingDisplayLogic?
    private let loadCurrentUserInfoUseCase = LoadCurrentUserInfoUseCase()
    public let items = BehaviorRelay<[SettingItem]>(value: [])
    
    init(displayLogic: SettingDisplayLogic, currentUsername: String) {
        self.displayLogic = displayLogic
        self.currentUsername = currentUsername
    }
    
    func transform(input: SettingVM.Input) -> SettingVM.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        input.trigger.flatMap{[unowned self] (_) -> Driver<User?> in
            return self.loadCurrentUserInfoUseCase.execute(request: self.currentUsername)
                .do(onNext: {(user) in
                    self.displayLogic?.bindUserInfo(user: user)
                })
                .asDriverOnErrorJustComplete()
            }.drive()
            .disposed(by: disposeBag)
        
        input.trigger.flatMap{[unowned self] (_) -> Driver<[Int]> in
            return Observable.just([1,2,3,4])
                .do(onNext: { (numbers) in
                    self.items.accept(numbers.map{(number)
                        in
                        switch number {
                        case 1:
                            return SettingItem(image: "ic_blue_lock", text: "Đổi mật khẩu")
                        case 2:
                            return SettingItem(image: "ic_blue_user", text: "Đổi ảnh đại diện")
                        case 3:
                            return SettingItem(image: "ic_blue_info", text: "Thông tin về iZalo")
                        case 4:
                            return SettingItem(image: "ic_blue_logout", text: "Đăng xuất")
                            
                        default:
                            return SettingItem(image: "ic_blue_smiley_face", text: "Nil")
                        }
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
    
    func saveAvatarImage(path: URL) {
        let changeAvatarUseCase = ChangeAvatarUseCase()
        changeAvatarUseCase.execute(request: ChangeAvatarRequest(currentUsername: self.currentUsername, imagePath: path))
            .do(onNext: { (newURL) in
                self.displayLogic?.updateAvatar(newURL: newURL)
            })
            .asDriverOnErrorJustComplete()
            .drive()
            .disposed(by: disposeBag)
    }
}

extension SettingVM {
    public struct Input {
        let trigger: Driver<Void>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
        let items: Driver<[SettingItem]>
    }
}
