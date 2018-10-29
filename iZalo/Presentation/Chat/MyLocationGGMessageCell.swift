//
//  MyLocationGGMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 10/25/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import GoogleMaps

class MyLocationGGMessageCell: UITableViewCell {

    @IBOutlet weak var tempMapView: GMSMapView!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    private func setupLayout() {
        self.selectionStyle = .none
        self.messageContainerView.layer.cornerRadius = 10
        self.messageContainerView.layer.borderWidth = 0.1
        self.messageContainerView.layer.borderColor = Color.mainBlueColor.cgColor
//        addSubview(ggMapView)
//        ggMapView.translatesAutoresizingMaskIntoConstraints = false
//        ggMapView.topAnchor.constraint(equalTo: topAnchor, constant: 37).isActive = true
////        ggMapView.bottomAnchor.constraint(equalTo: timestampLabel.topAnchor, constant: -5).isActive = true
//        ggMapView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
////        ggMapView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
////        self.tempMapView.isHidden = true
        tempMapView.settings.setAllGesturesEnabled(false)
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
        tempMapView.camera = camera
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        marker.map = tempMapView
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
