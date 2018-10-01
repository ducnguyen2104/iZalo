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
    func hideKeyboard()
    func clearInputTextField()
    func updateSendStatus()
}

class ChatVC: BaseVC {

    @IBOutlet weak var conversationNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    public var viewModel: ChatVM!
    public var conversation: Conversation!
    public var currentUsername: String!
    private let disposeBag = DisposeBag()
    private var items: RxTableViewSectionedReloadDataSource<SectionModel<String, MessageItem>>!
    
    class func instance(conversation: Conversation, currentUsername: String) -> ChatVC {
        return ChatVC(conversation: conversation, currentUsername: currentUsername)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(conversation: Conversation, currentUsername: String) {
        super.init(nibName: "ChatVC", bundle: nil)
        self.conversation = conversation
        self.currentUsername = currentUsername
        self.viewModel = ChatVM(conversation: conversation, currentUsername: currentUsername, displayLogic: self)
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
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "MyMessageCell")
        self.tableView.separatorStyle = .none
        self.items = RxTableViewSectionedReloadDataSource<SectionModel<String, MessageItem>>(configureCell: { (_, tv, ip, item) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "MyMessageCell", for: ip) as! MyMessageCell
            cell.bind(item: item)
            return cell
        })
    }
    
    private func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = ChatVM.Input(trigger: viewWillAppear, backTrigger: self.backButton.rx.tap.asDriver(), textMessage: self.inputTextField.rx.text.orEmpty, sendTrigger: self.sendButton.rx.tap.asDriver())
        let output = self.viewModel.transform(input: input)
        
        output.fetching.drive(onNext: { [unowned self] (show) in
            self.showLoading(withStatus: show)
        }).disposed(by: self.disposeBag)
        
        output.items
            .map { [SectionModel(model: "Items", items: $0)] }
            .drive(self.tableView.rx.items(dataSource: self.items))
            .disposed(by: self.disposeBag)
        
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
    
    func hideKeyboard() {
        self.view.resignFirstResponder()
    }
    
    func clearInputTextField() {
        self.inputTextField.text = ""
    }
    
    func updateSendStatus() {
        
    }
}
