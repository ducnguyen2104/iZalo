//
//  ChatVC.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {

    class func instance(conversationId: String) -> ChatVC {
        return ChatVC(conversationId: conversationId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(conversationId: String) {
        super.init(nibName: "ChatVC", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    

}
