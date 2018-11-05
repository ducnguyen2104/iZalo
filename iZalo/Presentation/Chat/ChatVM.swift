//
//  ChatVM.swift
//  iZalo
//
//  Created by CPU11613 on 9/27/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

final class ChatVM: ViewModelDelegate {
    
    //    public let items = BehaviorRelay<[MessageItem]>(value: [])
    public let conversation: Conversation
    public let currentUsername: String
    private weak var displayLogic: ChatDisplayLogic?
    private let disposeBag = DisposeBag()
    public let textMessage = BehaviorRelay<String>(value: "")
    private let sendMessageUsecase = SendMessageUsecase()
    private let loadMessageUsecase = LoadMessageUseCase()
    private let persistMessageUseCase = PersistMessageUseCase()
    private let loadAndPlayAudioUseCase = LoadAndPlayAudioUseCase()
    
    let activityIndicator = ActivityIndicator()
    let errorTracker = ErrorTracker()
    var messages: [Message] = []
    
    public let items = BehaviorRelay<[MessageItem]>(value: [])
    
    public let emojiItems = BehaviorRelay<[EmojiItem]>(value: [])
    
    public let emojis: [String] =
        ["😀", "😃", "😄", "😁", "😆", "😅", "😂",
                         "🤣", "☺️", "😊", "😇", "🐶", "🐱", "🐭",
                         "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯",
                         "🦁", "🤲", "👐", "🙌", "👏", "🤝", "👍",
                         "👎", "👊", "✊", "🤞", "✌️"]
    
    init(conversation: Conversation, currentUsername: String, displayLogic: ChatDisplayLogic) {
        self.conversation = conversation
        self.currentUsername = currentUsername
        self.displayLogic = displayLogic
    }
    
    private func addEmoji(emoji: String) {
        
    }
    
    func transform(input: ChatVM.Input) -> ChatVM.Output {
        
        
        (input.textMessage <-> self.textMessage).disposed(by: self.disposeBag)
        
        input.trigger.flatMap{[unowned self] (_) -> Driver<[String]> in
            return Observable.just(self.emojis)
                .do(onNext: {(emojiList) in
                    self.emojiItems.accept(emojiList.map{(emoji) in
                        return EmojiItem(emoji: emoji)
                    })
                })
                .trackActivity(self.activityIndicator)
                .trackError(self.errorTracker)
                .asDriverOnErrorJustComplete()
        }.drive()
        .disposed(by: self.disposeBag)
        
        input.trigger
            .flatMap{[unowned self] (_) -> Driver<[Message]> in
                return self.loadMessageUsecase.execute(request: LoadMessageRequest(conversation: self.conversation, username: self.currentUsername))
                    .do(onNext: { (messages) in
                        self.messages = messages
                        let items = self.messagesToMessageItems(messages: messages)
                        self.items.accept(items)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }.drive()
            .disposed(by: self.disposeBag)
        
        input.backTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
            .disposed(by: self.disposeBag)
        
        input.sendTrigger
            .flatMap { [unowned self] () -> Driver<Bool> in
                self.displayLogic?.hideKeyboard()
                self.displayLogic?.clearInputTextField()
                self.displayLogic?.hideAllExtraViews()
                return Observable.deferred { [unowned self] in
                    guard !self.textMessage.value.isEmpty else {
                        print("null message")
                        return Observable.error(ValidateError(message: "null message"))
                    }
                    
                    let date = Date()
                    let timestamp = Int(date.timeIntervalSince1970)
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minute = calendar.component(.minute, from: date)
                    let timestampInString = minute >= 10 ? "\(hour):\(minute)" : "\(hour):0\(minute)"
                    let message = Message(id: "\(self.currentUsername)\(timestamp)", senderId: self.currentUsername, conversationId: self.conversation.id, content: self.textMessage.value, type: Constant.textMessage, timestamp: timestamp, timestampInString: timestampInString)
                    return Observable.just(message)
                    }
                    .flatMap{ [unowned self] (msg) -> Observable<[Message]> in
                        return self.persistMessageUseCase
                        .execute(request: msg)
                        .do(onNext: { (messages) in
                            self.messages = messages
                            let items = self.messagesToMessageItems(messages:messages)
                            self.items.accept(items)
                        })
                        .trackActivity(self.activityIndicator)
                        .trackError(self.errorTracker)
                    }
                    .flatMap { (msgs) -> Observable<Bool> in
                        return self.sendMessageUsecase
                            .execute(request: SendMessageRequest(message: msgs[0], conversation: self.conversation))
                        
                    }
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        input.showHideTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.showHideButtonContainer()
            })
            .disposed(by: self.disposeBag)
        
        input.emojiButtonTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.showHideEmojiView()
            })
            .disposed(by: self.disposeBag)
        
        input.sendImageTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.setSendImage()
                self.displayLogic?.gotoLibrary()
                self.displayLogic?.showHideButtonContainer()
            })
            .disposed(by: self.disposeBag)
        
        input.sendNameCardTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.openPickContactVC()
                self.displayLogic?.showHideButtonContainer()
            })
            .disposed(by: self.disposeBag)
        
        input.sendLocationMKTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.openPickLocationVC()
                self.displayLogic?.showHideButtonContainer()
            })
            .disposed(by: self.disposeBag)
        
        input.sendLocationGGTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.openPlacePicker()
                self.displayLogic?.showHideButtonContainer()
            })
            .disposed(by: self.disposeBag)
        
        input.sendFileTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.setSendFile()
                self.displayLogic?.gotoLibrary()
                self.displayLogic?.showHideButtonContainer()
            })
            .disposed(by: self.disposeBag)
        
        return Output(fetching: activityIndicator.asDriver(),
                      error: errorTracker.asDriver(),
                      items: self.items.asDriver(),
                      emojiItems: self.emojiItems.asDriver())
    }
    
    
    func sendImageMessage(url: URL) {
        let date = Date()
        let timestamp = Int(date.timeIntervalSince1970)
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let timestampInString = minute >= 10 ? "\(hour):\(minute)" : "\(hour):0\(minute)"
        let uploadFileMessageUseCase = UploadFileMessageUseCase()
        sendMessageUsecase.execute(request: SendMessageRequest(message: Message(id: "\(self.currentUsername)\(timestamp)", senderId: self.currentUsername, conversationId: self.conversation.id, content: "url", type: Constant.imageMessage, timestamp: timestamp, timestampInString: timestampInString), conversation:
            self.conversation))
            .asDriverOnErrorJustComplete()
            .drive()
            .disposed(by: self.disposeBag)
        uploadFileMessageUseCase.execute(request: UploadFileMessageRequest(url: url, type: Constant.imageMessage))
            .do(onNext: {(newUrl) in
                print("newUrl: \(newUrl)")
                self.sendMessageUsecase
                    .execute(request: SendMessageRequest(message: Message(id: "\(self.currentUsername)\(timestamp)", senderId: self.currentUsername, conversationId: self.conversation.id, content: newUrl, type: Constant.imageMessage, timestamp: timestamp, timestampInString: "\(hour):\(minute)"), conversation:
                        self.conversation))
                    .asDriverOnErrorJustComplete()
                    .drive()
                    .disposed(by: self.disposeBag)
            })
            .asDriverOnErrorJustComplete()
            .drive()
            .disposed(by: self.disposeBag)
        }
    
    func sendLocationMessage(lat: Double, long: Double) {
        let date = Date()
        let timestamp = Int(date.timeIntervalSince1970)
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let timestampInString = minute >= 10 ? "\(hour):\(minute)" : "\(hour):0\(minute)"
        let message = Message(id:"\(self.currentUsername)\(timestamp)", senderId: self.currentUsername, conversationId: self.conversation.id, content: "\(lat),\(long)", type: Constant.locationMessage, timestamp: timestamp, timestampInString: timestampInString)
        let sendMessageUseCase = SendMessageUsecase()
        sendMessageUseCase
            .execute(request: SendMessageRequest(message: message, conversation: self.conversation))
            .asDriverOnErrorJustComplete()
            .drive()
            .disposed(by: self.disposeBag)
    }
    
    func sendFileMessage(url: URL) {
        let date = Date()
        let timestamp = Int(date.timeIntervalSince1970)
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let timestampInString = minute >= 10 ? "\(hour):\(minute)" : "\(hour):0\(minute)"
        let uploadFileMessageUseCase = UploadFileMessageUseCase()
        let fileName = url.lastPathComponent
        print("file name: \(fileName)")
    
        sendMessageUsecase.execute(request: SendMessageRequest(message: Message(id: "\(self.currentUsername)\(timestamp)", senderId: self.currentUsername, conversationId: self.conversation.id, content: "url,\(fileName)", type: Constant.fileMessage, timestamp: timestamp, timestampInString: timestampInString), conversation:
            self.conversation))
        .asDriverOnErrorJustComplete()
        .drive()
        .disposed(by: self.disposeBag)
        
        uploadFileMessageUseCase.execute(request: UploadFileMessageRequest(url: url, type: Constant.fileMessage))
            .do(onNext: {(newUrl) in
                print("newUrl: \(newUrl)")
                self.sendMessageUsecase
                    .execute(request: SendMessageRequest(message: Message(id: "\(self.currentUsername)\(timestamp)", senderId: self.currentUsername, conversationId: self.conversation.id, content: "\(newUrl),\(fileName)", type: Constant.fileMessage, timestamp: timestamp, timestampInString: "\(hour):\(minute)"), conversation:
                        self.conversation))
                    .asDriverOnErrorJustComplete()
                    .drive()
                    .disposed(by: self.disposeBag)
            })
            .asDriverOnErrorJustComplete()
            .drive()
            .disposed(by: self.disposeBag)
    }
    
    func loadAndPlayAudio(path: String, ip: IndexPath) {
        return loadAndPlayAudioUseCase.execute(request: path)
            .do(onNext: {(time) in
                print(time)
                self.displayLogic?.countDown(ip: ip, time: Int(time))
            })
        .asDriverOnErrorJustComplete()
        .drive()
        .disposed(by: self.disposeBag)
    }
    
    private func messagesToMessageItems(messages: [Message]) -> [MessageItem] {
        var items: [MessageItem] = []
        guard messages.count > 0 else {
            return []
        }
        switch messages.count {
        case 1:
            items.append(MessageItem(message: messages[0], currentUsername: self.currentUsername, isTimeHidden: false, isAvatarHidden: false))
        case 2:
            if(messages[0].senderId == messages[1].senderId) { //same user
                items.append(MessageItem(message: messages[0], currentUsername: self.currentUsername, isTimeHidden: false, isAvatarHidden: true))
                items.append(MessageItem(message: messages[1], currentUsername: self.currentUsername, isTimeHidden: true, isAvatarHidden: false))
            } else { //different user
                items.append(MessageItem(message: messages[0], currentUsername: self.currentUsername, isTimeHidden: false, isAvatarHidden: false))
                items.append(MessageItem(message: messages[1], currentUsername: self.currentUsername, isTimeHidden: false, isAvatarHidden: false))
            }
        default:
            for i in 0...messages.count - 1 {
                if i == 0 { //last message
                    let isAvatarHidden = messages[0].senderId == messages[1].senderId
                    items.append(MessageItem(message: messages[i], currentUsername: self.currentUsername, isTimeHidden: false, isAvatarHidden: isAvatarHidden))
                }
                else if i == messages.count - 1 { //first message
                    if messages[messages.count - 2].senderId == messages[messages.count - 1].senderId {
                        items.append(MessageItem(message: messages[i], currentUsername: self.currentUsername, isTimeHidden: true, isAvatarHidden: false))
                    }
                    
                } else {
                    let isTimeHidden = messages[i].senderId == messages[i-1].senderId
                    let isAvatarHidden = messages[i].senderId == messages[i+1].senderId
                    items.append(MessageItem(message: messages[i], currentUsername: self.currentUsername, isTimeHidden: isTimeHidden, isAvatarHidden: isAvatarHidden))
                }
            }
        }
        return items
    }
}

extension ChatVM {
    
    public struct Input {
        let trigger: Driver<Void>
        let backTrigger: Driver<Void>
        let textMessage: ControlProperty<String>
        let sendTrigger: Driver<Void>
        let showHideTrigger: Driver<Void>
        let emojiButtonTrigger: Driver<Void>
        let sendImageTrigger: Driver<Void>
        let sendNameCardTrigger: Driver<Void>
        let sendLocationMKTrigger: Driver<Void>
        let sendLocationGGTrigger: Driver<Void>
        let sendFileTrigger: Driver<Void>
    }
    
    public struct Output {
        let fetching: Driver<Bool>
        let error: Driver<Error>
        let items: Driver<[MessageItem]>
        let emojiItems: Driver<[EmojiItem]>
    }
    
}
