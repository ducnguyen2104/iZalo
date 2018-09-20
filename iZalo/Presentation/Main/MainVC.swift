//
//  MainVC.swift
//  iZalo
//
//  Created by CPU11613 on 9/20/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit

class MainVC: UITabBarController {
    
    class func instance() -> MainVC {
        return MainVC()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    func setupTabs() {
        
        let historyVC = ChatHistoryVC.instance()
        let contactVC = ContactVC.instance()
        let settingVC = SettingVC.instance()
    
        let historyTab = UINavigationController(rootViewController: historyVC)
        let contactTab = UINavigationController(rootViewController: contactVC)
        let settingTab = UINavigationController(rootViewController: settingVC)
        
        historyTab.tabBarItem.image = UIImage(named: "ic_gray_message")?.withRenderingMode(.alwaysOriginal)
        historyTab.tabBarItem.selectedImage = UIImage(named: "ic_black_message")?.withRenderingMode(.alwaysOriginal)
        historyTab.tabBarItem.title = "Tin nhắn"
        
        contactTab.tabBarItem.image = UIImage(named: "ic_gray_contact")?.withRenderingMode(.alwaysOriginal)
        contactTab.tabBarItem.selectedImage = UIImage(named: "ic_black_contact")?.withRenderingMode(.alwaysOriginal)
        contactTab.tabBarItem.title = "Danh bạ"
        
        settingTab.tabBarItem.image = UIImage(named: "ic_gray_setting")?.withRenderingMode(.alwaysOriginal)
        settingTab.tabBarItem.selectedImage = UIImage(named: "ic_black_setting")?.withRenderingMode(.alwaysOriginal)
        settingTab.tabBarItem.title = "Cài đặt"
        
        self.viewControllers = [historyTab, contactTab, settingTab]
        
        for item in self.tabBar.items! {
            let selectedItem = [NSAttributedStringKey.foregroundColor: UIColor.black]
            item.setTitleTextAttributes(selectedItem, for: .selected)
        }
    }

}
