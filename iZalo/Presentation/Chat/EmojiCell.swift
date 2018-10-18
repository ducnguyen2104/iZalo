//
//  EmojiCell.swift
//  iZalo
//
//  Created by CPU11613 on 10/18/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit

class EmojiCell: UICollectionViewCell {

    @IBOutlet weak var emojiLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bind(item: EmojiItem) {
        self.emojiLabel.text = item.emoji
    }
}
