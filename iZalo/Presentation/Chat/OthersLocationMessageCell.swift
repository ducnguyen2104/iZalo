//
//  OthersLocationMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 10/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class OthersLocationMessageCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!
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
        self.mapView.isZoomEnabled = false
        self.mapView.isPitchEnabled = false
        self.mapView.isRotateEnabled = false
        self.mapView.isScrollEnabled = false
        self.mapView.isUserInteractionEnabled = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        mapView.addAnnotation(annotation)
        let location = CLLocation(latitude: lat!, longitude: long!)
        let region = MKCoordinateRegionMakeWithDistance(
            location.coordinate, 250, 250)
        mapView.setRegion(region, animated: true)
    }
}
