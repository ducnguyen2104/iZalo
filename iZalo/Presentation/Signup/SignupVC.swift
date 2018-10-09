//
//  SignupVC.swift
//  iZalo
//
//  Created by CPU11613 on 10/9/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import RxSwift

protocol SignupDisplayLogic: class {
    func gotoLogin()
    func gotoMain(currentUsername: String)
}

class SignupVC: BaseVC {

    class func instance() -> SignupVC {
        return SignupVC()
    }
    
    public typealias ViewModelType = SignupVM
    public var viewModel: SignupVM!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.bindViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.viewModel = SignupVM(displayLogic: self)
    }
    
    init() {
        super.init(nibName: "SignupVC", bundle: nil)
        
        self.viewModel = SignupVM(displayLogic: self)
        
    }

    private func setupLayout() {
        self.signupBtn.layer.cornerRadius = 10
    }

    private func bindViewModel() {
        let input = SignupVM.Input(
            loginTrigger: self.loginBtn.rx.tap.asDriver(),
            signupTrigger: self.signupBtn.rx.tap.asDriver(),
            username: self.usernameTextField.rx.text.orEmpty,
            password: self.passwordTextField.rx.text.orEmpty,
            confirmPassword: self.confirmPasswordTextField.rx.text.orEmpty,
            fullname: self.fullnameTextField.rx.text.orEmpty,
            phoneNumber: self.phoneNumberTextField.rx.text.orEmpty
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

extension SignupVC: SignupDisplayLogic {
    func gotoLogin() {
        self.navigationController?.popViewController(animated: true)
    }
    func gotoMain(currentUsername: String) {
        print( "Go to main: \(self.usernameTextField.text!)")
        let mainVC = MainVC.instance(currentUsername: self.usernameTextField.text!)
        self.navigationController?.setViewControllers([mainVC], animated: true)
    }
}
