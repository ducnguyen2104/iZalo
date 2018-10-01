//
//  ProfileVC.swift
//  iZalo
//
//  Created by CPU11613 on 9/20/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit

class SettingVC: BaseVC {
    
    private var currentUsername: String!
    
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
        self.currentUsername = currentUsername
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    private func setupLayout() {
        self.navigationController?.isNavigationBarHidden = true;
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Tìm bạn bè, tin nhắn, ...",
                                                                   attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 255, green: 255, blue: 255, alpha: 0.7)])
    }
}
