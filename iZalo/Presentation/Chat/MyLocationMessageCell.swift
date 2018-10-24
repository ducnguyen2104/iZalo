//
//  MyLocationMessageCell.swift
//  iZalo
//
//  Created by CPU11613 on 10/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import MapKit

class MyLocationMessageCell: UITableViewCell {

    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var timestampLabelHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }

    private func setupLayout() {
        self.selectionStyle = .none
        self.messageContainerView.layer.cornerRadius = 10
        self.messageContainerView.layer.borderWidth = 0.1
        self.messageContainerView.layer.borderColor = Color.mainBlueColor.cgColor
        self.mapView.isZoomEnabled = false
        self.mapView.isPitchEnabled = false
        self.mapView.isRotateEnabled = false
        self.mapView.isScrollEnabled = false
        self.mapView.isUserInteractionEnabled = false
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
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        mapView.addAnnotation(annotation)
        let location = CLLocation(latitude: lat!, longitude: long!)
        let region = MKCoordinateRegionMakeWithDistance(
            location.coordinate, 250, 250)
        mapView.setRegion(region, animated: true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
