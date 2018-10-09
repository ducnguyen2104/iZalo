//
//  AddFriendVC.swift
//  iZalo
//
//  Created by CPU11613 on 10/9/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

protocol AddFriendDisplayLogic: class {
    func goBack()
    func showResult(result: ContactSearchResult)
}
class AddFriendVC: BaseVC {
    
    class func instance(currentUsername: String) -> AddFriendVC {
        return AddFriendVC(currentUsername: currentUsername)
    }
    
    
    public typealias ViewModelType = AddFriendVM
    public var viewModel: AddFriendVM!

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resultAvatarImageView: UIImageView!
    @IBOutlet weak var resultName: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    private var currentUsername: String?
    
    private let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(currentUsername: String) {
        self.currentUsername = currentUsername
        super.init(nibName: "AddFriendVC", bundle: nil)
        self.viewModel = AddFriendVM(displayLogic: self, currentUsername: self.currentUsername!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindViewModel()
    }

    private func setupLayout() {
        self.searchButton.layer.cornerRadius = 10
        self.resultAvatarImageView.isHidden = true
        self.resultName.isHidden = true
        self.addFriendButton.isHidden = true
    }
    
    private func bindViewModel() {
        let input = AddFriendVM.Input(
            backTrigger: self.backButton.rx.tap.asDriver(),
            searchText: self.searchTextField.rx.text.orEmpty,
            searchTrigger: self.searchButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)
        
        output.fetching.drive(onNext: { [unowned self] (show) in
            self.showLoading(withStatus: show)
        }).disposed(by: self.disposeBag)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.handleError(error: error)
        }).disposed(by: self.disposeBag)
    }
}

extension AddFriendVC: AddFriendDisplayLogic {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showResult(result: ContactSearchResult) {
        self.resultAvatarImageView.kf.setImage(with: URL(string: result.contact.avatarURL))
        self.resultName.text = result.contact.name
        self.resultAvatarImageView.isHidden = false
        self.resultName.isHidden = false
        if !result.isFriend {
            self.addFriendButton.isHidden = false
        }
    }
}
