//
//  ChatVC.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

protocol ChatDisplayLogic: class {
    func goBack()
}

class ChatVC: BaseVC {

    @IBOutlet weak var conversationNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendButton: UIImageView!
    @IBOutlet weak var inputTextField: UITextField!
    
    public var viewModel: ChatVM!
    public var conversation: Conversation!
    private let disposeBag = DisposeBag()
    
    class func instance(conversation: Conversation) -> ChatVC {
        return ChatVC(conversation: conversation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(conversation: Conversation) {
        super.init(nibName: "ChatVC", bundle: nil)
        self.conversation = conversation
        self.viewModel = ChatVM(conversation: conversation, displayLogic: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindViewModel()
        // Do any additional setup after loading the view.
    }

    private func setupLayout() {
        switch conversation.members.count {
        case 2: //2 members conversation
            conversationNameLabel.text = self.conversation.name
            statusLabel.text = "Vừa mới truy cập"
            
        default: //group chat
            conversationNameLabel.text = self.conversation.name
            statusLabel.text = "\(self.conversation.members.count) thành viên"
        }
    }
    
    private func bindViewModel() {
        let input = ChatVM.Input(backTrigger: self.backButton.rx.tap.asDriver())
        let output = self.viewModel.transform(input: input)
        output.fetching.drive(onNext: { [unowned self] (show) in
            self.showLoading(withStatus: show)
        }).disposed(by: self.disposeBag)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.handleError(error: error)
        }).disposed(by: self.disposeBag)
    }

}

extension ChatVC: ChatDisplayLogic {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
    }
}
