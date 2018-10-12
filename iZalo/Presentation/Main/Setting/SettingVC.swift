//
//  ProfileVC.swift
//  iZalo
//
//  Created by CPU11613 on 9/20/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import RxSwift

protocol SettingDisplayLogic: class {
    func gotoLogin()
}

class SettingVC: BaseVC {
    
    public typealias ViewModelType = SettingVM
    public var viewModel: SettingVM!
    private let disposeBag = DisposeBag()

    private var currentUsername: String!
    @IBOutlet weak var logoutButton: UIButton!
    
    func setCurrentUsername(currentUsername: String) {
        self.currentUsername = currentUsername
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    
    class func instance(currentUsername: String) -> SettingVC {
        return SettingVC(currentUsername: currentUsername)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(currentUsername: String) {
        super.init(nibName: "SettingVC", bundle: nil)
        print("init setting  ")
        self.currentUsername = currentUsername
        self.viewModel = SettingVM(displayLogic: self, currentUsername: self.currentUsername)
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
        self.logoutButton.layer.cornerRadius = 10
    }
    
    private func bindViewModel() {
        let input = SettingVM.Input(logoutTrigger: self.logoutButton.rx.tap.asDriver())
        let output = self.viewModel.transform(input: input)
        output.fetching.drive(onNext: { [unowned self] (show) in
            self.showLoading(withStatus: show)
        }).disposed(by: self.disposeBag)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.showLoading(withStatus: false)
            self.handleError(error: error)
        }).disposed(by: self.disposeBag)
    }
}

extension SettingVC: SettingDisplayLogic {

    func gotoLogin() {
        let vc = UINavigationController(rootViewController: LoginVC.instance())
        vc.setNavigationBarHidden(true, animated: false)
        AppDelegate.sharedInstance.window?.rootViewController = vc
    }
    
}
