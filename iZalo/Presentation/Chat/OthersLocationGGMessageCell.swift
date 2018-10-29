//
//  OthersLocationGGMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 10/25/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift
class OthersLocationGGMessageCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }

    func setupLayout() {
        self.selectionStyle = .none
        self.messageContainerView.layer.cornerRadius = 10
        self.messageContainerView.layer.borderWidth = 0.1
        self.messageContainerView.layer.borderColor = UIColor.gray.cgColor
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.height/2
        self.avatarImageView.clipsToBounds = true
        mapView.settings.setAllGesturesEnabled(false)
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
            self.avatarImageView.isHidden = false
            let _ = contactObservable.subscribe(onNext: {(contact) in
                self.avatarImageView.kf.setImage(with: URL(string: contact.avatarURL), placeholder: nil,  options: [.processor(Constant.avatarImageProcessor)])
            })
        } else {
            self.avatarImageView.isHidden = true
        }
        let latlongArray = item.message.content.split(separator: ",")
        guard latlongArray.count == 2 else {
            print("error: latlongArray doesn't have 2 element")
            return
        }
        let lat = Double(latlongArray[0])
        let long = Double(latlongArray[1])
        guard lat != nil && long != nil else {
            print("error: nil lat or long")
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: lat!, longitude: long!, zoom: 17.0)
        mapView.camera = camera
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        marker.map = mapView
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
