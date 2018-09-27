//
//  ChatHistoryVC.swift
//  iZalo
//
//  Created by CPU11613 on 9/20/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

protocol ChatHistoryDisplayLogic: class {
    func gotoChat()
}

class ChatHistoryVC: BaseVC {
    
    public typealias ViewModelType = ChatHistoryVM
    public var viewModel: ChatHistoryVM!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    private var items: RxTableViewSectionedReloadDataSource<SectionModel<String, ConversationItem>>!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: "ChatHistoryVC", bundle: nil)

        self.viewModel = ChatHistoryVM(displayLogic: self)
    }
    
    class func instance() -> ChatHistoryVC {
        return ChatHistoryVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.bindViewModel()
    }
    
    private func setupLayout() {
        self.navigationController?.isNavigationBarHidden = true;
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Tìm bạn bè, tin nhắn, ...",
                                                                   attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)])
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        self.items = RxTableViewSectionedReloadDataSource<SectionModel<String, ConversationItem>>(configureCell: { (_, tv, ip, item) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "ConversationCell", for: ip) as! ConversationCell
            cell.bind(item: item)
            return cell
        })
        self.tableView.rx.itemSelected.asDriver()
            .drive(onNext: {(ip) in
                self.tableView.deselectRow(at: ip, animated: false)
                let item = self.items.sectionModels[0].items[ip.row]
                let vc = ChatVC.instance(conversation: item.conversation)
                self.navigationController?.pushViewController(vc, animated: true)
                self.navigationController?.tabBarController?.tabBar.isHidden = true
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindViewModel() {
        print("ChatHistoryVC bindVM")
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = ChatHistoryVM.Input(
            trigger: viewWillAppear,
            selectTrigger: self.tableView.rx.itemSelected.asDriver()
        )
        let output = self.viewModel.transform(input: input)
        
        output.fetching.drive(onNext: { [unowned self] (show) in
            self.showLoading(withStatus: show)
        }).disposed(by: self.disposeBag)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.showLoading(withStatus: false)
            self.handleError(error: error)
        }).disposed(by: self.disposeBag)
        
        output.items
            .map { [SectionModel(model: "Items", items: $0)] }
            .drive(self.tableView.rx.items(dataSource: self.items))
            .disposed(by: self.disposeBag)
    }
    
}

extension ChatHistoryVC: ChatHistoryDisplayLogic {
    
    func gotoChat() {
        
    }
    
}
