//
//  PickContactVC.swift
//  iZalo
//
//  Created by CPU11613 on 10/22/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

protocol PickContactDisplayLogic: class {
    func goBack()
    func updateSendStatus()
}
class PickContactVC: BaseVC {
    
    
    public typealias ViewModelType = PickContactVM
    public var viewModel: PickContactVM!
    
    class func instance(currentUsername: String, conversation: Conversation) -> PickContactVC {
        return PickContactVC(currentUsername: currentUsername, conversation: conversation)
    }

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchVỉew: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()

    private var items: RxTableViewSectionedReloadDataSource<SectionModel<String, ContactItem>>!
    
    private var currentUsername: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(currentUsername: String, conversation: Conversation) {
        super.init(nibName: "PickContactVC", bundle: nil)
        self.currentUsername = currentUsername
        self.viewModel = PickContactVM(displayLogic: self, currentUsername: currentUsername, conversationId: conversation)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindViewModel()
    }

    func setupLayout(){
        self.searchVỉew.layer.cornerRadius = 5
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        self.items = RxTableViewSectionedReloadDataSource<SectionModel<String, ContactItem>>(configureCell: { (_, tv, ip, item) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "ContactCell", for: ip) as! ContactCell
            cell.bind(item: item)
            return cell
        })
    }
    
    func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = PickContactVM.Input(
            trigger: viewWillAppear,
            selectTrigger: self.tableView.rx.itemSelected.asDriver(),
            backTrigger: self.backButton.rx.tap.asDriver())
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

extension PickContactVC: PickContactDisplayLogic {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    func updateSendStatus() {
        
    }
}
