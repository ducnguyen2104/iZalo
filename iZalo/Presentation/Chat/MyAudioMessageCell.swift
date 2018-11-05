//
//  MyAudioMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 11/5/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import Kingfisher

class MyAudioMessageCell: UITableViewCell {

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var waveImageView: AnimatedImageView!
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!
    public var isAnimating = false
    private let loadAndPlayAudioUseCase = LoadAndPlayAudioUseCase()
    private var firebasePath: String?
    var countdownTimer: Timer!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
        
    }

    private func setupLayout() {
        self.selectionStyle = .none
        self.messageContainerView.layer.cornerRadius = 10
        self.messageContainerView.layer.borderWidth = 0.1
        self.messageContainerView.layer.borderColor = Color.mainBlueColor.cgColor
        self.waveImageView.autoPlayAnimatedImage = false
    }
    
    func bind(item: MessageItem) {
        self.firebasePath = String(item.message.content.split(separator: ",")[0])
        self.waveImageView.kf.setImage(with: URL(string: Constant.equalizerGifURL))
        if !item.isTimeHidden {
            self.timestampLabel.isHidden = false
            self.timestampLabelHeightConstraint.constant = 20
            self.timestampLabel.text = item.message.timestampInString
        } else {
            self.timestampLabelHeightConstraint.constant = 0
            self.timestampLabel.isHidden = true
        }
        self.durationLabel.text = String(item.message.content.split(separator: ",")[1])
    }
    
    func startAnimating() {
        self.isAnimating = true
        self.waveImageView.startAnimating()
        self.playImageView.image = #imageLiteral(resourceName: "ic_blue_stop")
//        self.loadAndPlayAudioUseCase.execute(request: self.firebasePath!)
    }
    func stopAnimating() {
        self.isAnimating = false
        self.waveImageView.stopAnimating()
        self.playImageView.image = #imageLiteral(resourceName: "ic_blue_play")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
//    var totalTime: Int?
//    public func startTimer(totalTime: Int) {
//        self.totalTime = totalTime
//        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
//    }
//    
//    func updateTime() {
//
//        durationLabel.text = "\(timeFormatted(totalTime!))"
//        
//        if totalTime != 0 {
//            totalTime! -= 1
//        } else {
//            endTimer()
//        }
//    }
//    
//    func endTimer() {
//        countdownTimer.invalidate()
//    }
//    
//    func timeFormatted(_ totalSeconds: Int) -> String {
//        let seconds: Int = totalSeconds % 60
//        let minutes: Int = (totalSeconds / 60) % 60
//        //     let hours: Int = totalSeconds / 3600
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
}
