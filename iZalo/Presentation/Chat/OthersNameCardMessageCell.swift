//
//  OthersNameCardMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 10/22/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import RxSwift

class OthersNameCardMessageCell: UITableViewCell {

    @IBOutlet weak var senderAvatarImageView: UIImageView!
    @IBOutlet weak var nameCardAvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    
    private let searchUsernameUseCase = SearchUsernameUseCase()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    func setupLayout() {
        self.selectionStyle = .none
        self.messageContainerView.layer.cornerRadius = 10
        self.messageContainerView.layer.borderWidth = 0.1
        self.messageContainerView.layer.borderColor = UIColor.gray.cgColor
        self.senderAvatarImageView.layer.cornerRadius = self.senderAvatarImageView.frame.height/2
        self.senderAvatarImageView.clipsToBounds = true
    }
    
    func bind(item: MessageItem, contactObservable: Observable<Contact>) {
        if !item.isTimeHidden {
            self.timestampLabel.isHidden = false
            self.timestampLabelHeightConstraint.constant = 20
            self.timestampLabel.text = item.message.timestampInString
        } else {
            self.timestampLabelHeightConstraint.constant = 0
            self.timestampLabel.isHidden = true
        }
        if !item.isAvatarHidden {
            self.senderAvatarImageView.isHidden = false
            let _ = contactObservable.subscribe(onNext: {(contact) in
                self.senderAvatarImageView.kf.setImage(with: URL(string: contact.avatarURL), placeholder: nil,  options: [.processor(Constant.avatarImageProcessor)])
            })
        } else {
            self.senderAvatarImageView.isHidden = true
        }
        self.searchUsernameUseCase.execute(request: SearchUsernameRequest(username: item.message.content, currentUsername: item.currentUsername))
            .subscribe(onNext: { (result) in
                print("result: \(result)")
                self.nameCardAvatarImageView.kf.setImage(with: URL(string: result.contact.avatarURL), placeholder: nil,  options: [.processor(Constant.avatarImageProcessor)])
                self.nameLabel.text = result.contact.name
            })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
