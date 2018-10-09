//
//  LoginVC.swift
//  iZalo
//
//  Created by CPU11613 on 9/17/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import RxSwift

protocol LoginDisplayLogic : class {
    func hideKeyboard()
    func gotoMain(currentUsername: String)
    func gotoSignup()
}

class LoginVC: BaseVC {
    
    class func instance() -> LoginVC {
        return LoginVC()
    }
    
    public typealias ViewModelType = LoginVM
    public var viewModel: LoginVM!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.viewModel = LoginVM(displayLogic: self)
    }
    
    init() {
        super.init(nibName: "LoginVC", bundle: nil)
        
        self.viewModel = LoginVM(displayLogic: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupLayout() {
        self.usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(usernameFocus)))
        self.passwordLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(passwordFocus)))
        self.loginBtn.layer.cornerRadius = 10
    }
    
    @objc private func usernameFocus() {
        self.usernameTextField.becomeFirstResponder()
    }
    
    @objc private func passwordFocus() {
        self.passwordTextField.becomeFirstResponder()
    }
    
    private func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = LoginVM.Input(
            trigger: viewWillAppear,
            loginTrigger: self.loginBtn.rx.tap.asDriver(), //control event -> driver
            signupTrigger: self.signupBtn.rx.tap.asDriver(),
            username: self.usernameTextField.rx.text.orEmpty,
            password: self.passwordTextField.rx.text.orEmpty
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
extension LoginVC: LoginDisplayLogic {
    func hideKeyboard() {
        self.view.resignFirstResponder()
    }
    
    func gotoMain(currentUsername: String) {
        print( "Go to main: \(self.usernameTextField.text!)")
        let mainVC = MainVC.instance(currentUsername: self.usernameTextField.text!)
        self.navigationController?.setViewControllers([mainVC], animated: true)
    }
    
    func gotoSignup() {
        let signupVC = SignupVC.instance()
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
}
