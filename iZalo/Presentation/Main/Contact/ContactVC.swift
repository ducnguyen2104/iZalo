//
//  ContactVC.swift
//  iZalo
//
//  Created by CPU11613 on 9/20/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

protocol ContactDisplayLogic: class {
    func gotoChat()
}

class ContactVC: BaseVC {
    
    public var currentUsername: String!
    
    public typealias ViewModelType = ContactVM
    public var viewModel: ContactVM!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addContactImageView: UIImageView!
    
    private let disposeBag = DisposeBag()
    private var items: RxTableViewSectionedReloadDataSource<SectionModel<String, ContactItem>>!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(currentUsername: String) {
        super.init(nibName: "ChatHistoryVC", bundle: nil)
        self.currentUsername = currentUsername
        self.viewModel = ContactVM(displayLogic: self, currentUsername: currentUsername)
    }
    
    class func instance(currentUsername: String) -> ContactVC {
        return ContactVC(currentUsername: currentUsername)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindViewModel()
    }
    
    private func setupLayout() {
        self.navigationController?.isNavigationBarHidden = true;
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Tìm bạn bè, tin nhắn, ...",
                                                                   attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 255, green: 255, blue: 255, alpha: 0.7)])
       
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
    
    private func bindViewModel() {
        print("ContactVC bindVM")
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = ContactVM.Input(
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

extension ContactVC: ContactDisplayLogic {
    
    func gotoChat() {
    
    }
}
