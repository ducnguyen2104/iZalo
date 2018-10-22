//
//  MyNameCardMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 10/22/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import Kingfisher

class MyNameCardMessageCell: UITableViewCell {

    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    
    private let searchUsernameUseCase = SearchUsernameUseCase()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }

    func bind(item: MessageItem) {
        self.usernameLabel.text = item.message.content
        if (!item.isTimeHidden) {
            self.timestampLabel.text = item.message.timestampInString
            self.timestampLabelHeightConstraint.constant = 20
            self.timestampLabel.isHidden = false
        } else {
            self.timestampLabelHeightConstraint.constant = 0
            self.timestampLabel.isHidden = true
        }
        self.searchUsernameUseCase.execute(request: SearchUsernameRequest(username: item.message.content, currentUsername: item.currentUsername))
            .subscribe(onNext: { (result) in
                print("result: \(result)")
                self.avatarImage.kf.setImage(with: URL(string: result.contact.avatarURL), placeholder: nil,  options: [.processor(Constant.avatarImageProcessor)])
                self.nameLabel.text = result.contact.name
            })
    }
    
    private func setupLayout() {
        self.selectionStyle = .none
        self.messageContainerView.layer.cornerRadius = 10
        self.messageContainerView.layer.borderWidth = 0.1
        self.messageContainerView.layer.borderColor = Color.mainBlueColor.cgColor
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.height/2
        self.avatarImage.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
