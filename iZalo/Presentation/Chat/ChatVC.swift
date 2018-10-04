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
import ReverseExtension

protocol ChatDisplayLogic: class {
    func goBack()
    func hideKeyboard()
    func clearInputTextField()
    func updateSendStatus()
    func scollTableToBottom(noRows: Int)
}

class ChatVC: BaseVC {

    @IBOutlet weak var conversationNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    private let contactRepository = ContactRepositoryFactory.sharedInstance
    
    public var viewModel: ChatVM!
    public var conversation: Conversation!
    public var currentUsername: String!
    private let disposeBag = DisposeBag()
    private var items: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, MessageItem>>!
    private var contactObservable: Observable<Contact>?
    
    class func instance(conversation: Conversation, currentUsername: String, contactObservable: Observable<Contact>) -> ChatVC {
        return ChatVC(conversation: conversation, currentUsername: currentUsername, contactObservable: contactObservable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(conversation: Conversation, currentUsername: String, contactObservable: Observable<Contact>) {
        self.conversation = conversation
        self.currentUsername = currentUsername
        self.contactObservable = contactObservable
        super.init(nibName: "ChatVC", bundle: nil)
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
        
        self.tableView.re.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "MyMessageCell")
        self.tableView.register(UINib(nibName: "OthersMessageCell", bundle: nil), forCellReuseIdentifier: "OthersMessageCell")
        self.tableView.separatorStyle = .none
        self.items = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, MessageItem>>(configureCell: { (_, tv, ip, item) -> UITableViewCell in
            if(item.message.senderId == self.currentUsername) {
                let cell = tv.dequeueReusableCell(withIdentifier: "MyMessageCell", for: ip) as! MyMessageCell
                cell.bind(item: item)
                return cell
            } else {
                let cell = tv.dequeueReusableCell(withIdentifier: "OthersMessageCell", for: ip) as! OthersMessageCell
                cell.bind(item: item, contactObservable: self.contactObservable!)
                return cell
            }
        })
        contactObservable!.subscribe(onNext: {(contact) in
                self.conversationNameLabel.text = contact.name
            } )
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
            .map { [AnimatableSectionModel(model: "Items", items: $0)] }
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
    
    func scollTableToBottom(noRows: Int) {
        let indexPath = NSIndexPath(item: noRows, section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.bottom, animated: true)
    }
}

extension ChatVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollView.contentOffset.y =", scrollView.contentOffset.y)
    }
}
