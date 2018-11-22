//
//  MyVideoMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 11/12/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import IJKMediaFramework

class MyVideoMessageCell: UITableViewCell {
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    var player: IJKMediaPlayback?
    private var url: String?
    private var duration: String?
    private var thumbURL: String?
    public var isPlaying = false
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }

    func bind(item: MessageItem) {
        if !item.isTimeHidden {
            self.timestampLabel.isHidden = false
            self.timestampLabelHeightConstraint.constant = 20
            self.timestampLabel.text = item.message.timestampInString
        } else {
            self.timestampLabelHeightConstraint.constant = 0
            self.timestampLabel.isHidden = true
        }
        self.duration = String(item.message.content.split(separator: ",")[2])
        self.durationLabel.text = self.duration
        self.thumbURL = String(item.message.content.split(separator: ",")[1])
        self.thumbnailImageView.kf.setImage(with: URL(string: self.thumbURL!))
        self.url = String(item.message.content.split(separator: ",")[0])
    }
    
    private func setupLayout() {
        self.selectionStyle = .none
        self.messageContainerView.layer.cornerRadius = 10
        self.messageContainerView.layer.borderWidth = 0.1
        self.messageContainerView.layer.borderColor = Color.mainBlueColor.cgColor
    }
    
    func playVideo() {
        guard url != nil else {
            return
        }
        if(self.isPlaying) {
            player?.pause()
            self.isPlaying = false
        }
        else {
            if (player != nil) {
                player?.play()
                self.isPlaying = true
            }
            else {
                player = IJKMPMoviePlayerController(contentURLString: url!)
                player?.view.frame = self.thumbnailImageView.frame
                player?.view.frame.origin.x += 10
                player?.view.frame.origin.y += 10
                player?.view.transform = CGAffineTransform(scaleX: -1, y: -1)
                player?.view.tag = 10
                addSubview((player?.view)!)
                player?.prepareToPlay()
                player?.play()
                self.isPlaying = true
            }
        }
    }
    
    func endVideo() {
        if(player != nil) {
            player?.stop()
            viewWithTag(10)?.removeFromSuperview()
            player = nil
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
