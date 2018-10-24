//
//  PickLocationVC.swift
//  iZalo
//
//  Created by CPU11613 on 10/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

protocol PickLocationtDisplayLogic: class {
    func goBack()
    func pointToMyLocation()
}

class PickLocationVC: BaseVC, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {

    public typealias ViewModelType = PickLocationVM
    public var viewModel: PickLocationVM!
    
    class func instance(currentUsername: String, conversation: Conversation) -> PickLocationVC {
        return PickLocationVC(currentUsername: currentUsername, conversation: conversation)
    }
    
   
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager?
    private let disposeBag = DisposeBag()
    var pointAnnotation:CustomPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var currentUsername: String?
    private var annotation: MKAnnotation?
    private let defaultLocation = CLLocation(latitude: 10.773695, longitude: 106.660454)
    
    init(currentUsername: String, conversation: Conversation) {
        super.init(nibName: "PickLocationVC", bundle: nil)
        self.currentUsername = currentUsername
        self.viewModel = PickLocationVM(displayLogic: self, currentUsername: currentUsername, conversationId: conversation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        setupLayout()
        bindViewModel()
    }
    
    func setupLayout() {
        
        myLocationButton.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        myLocationButton.layer.cornerRadius = myLocationButton.frame.height/2
        myLocationButton.layer.borderColor = UIColor.gray.cgColor
        myLocationButton.layer.borderWidth = 0.1
        mapView.delegate = self
        let gestureZ = UILongPressGestureRecognizer(target: self, action: #selector(self.revealRegionDetailsWithLongPressOnMap(sender:)))
        mapView.addGestureRecognizer(gestureZ)
        
//        mapView.showsUserLocation = true
        if let userLocation = self.locationManager?.location?.coordinate {
            let lat = NumberUtils.RoundDoubleTo6DigitsPrecision(input: userLocation.latitude)
            let long = NumberUtils.RoundDoubleTo6DigitsPrecision(input: userLocation.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.title = "Vị trí của bạn"
            annotation.subtitle = "Bấm giữ map để chọn vị trí"
//            pointAnnotation = CustomPointAnnotation()
//            pointAnnotation.pinCustomImageName = "ic_red_pin"
//            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//            pointAnnotation.title = "Vị trí của bạn"
//
//            pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
//            mapView.addAnnotation(pinAnnotationView.annotation!)
            
            self.annotation = annotation
            
            mapView.addAnnotation(self.annotation!)
            
            let region = MKCoordinateRegionMakeWithDistance(
                userLocation, 500, 500)
            mapView.setRegion(region, animated: true)
            
            self.viewModel.updateLatLong(latitude: lat, longtitude: long)
            self.locationLabel.text = "\(lat), \(long)"
        }
        else {
            let lat = NumberUtils.RoundDoubleTo6DigitsPrecision(input: defaultLocation.coordinate.latitude)
            let long = NumberUtils.RoundDoubleTo6DigitsPrecision(input: defaultLocation.coordinate.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.title = "Vị trí mặc định"
            annotation.subtitle = "Không thể xác định vị trí của bạn"
            self.annotation = annotation
            mapView.addAnnotation(self.annotation!)
            
            let region = MKCoordinateRegionMakeWithDistance(
                defaultLocation.coordinate, 500, 500)
            mapView.setRegion(region, animated: true)
            
            self.viewModel.updateLatLong(latitude: lat, longtitude: long)
            self.locationLabel.text = "\(lat), \(long)"
        }
    }

    func bindViewModel() {
        let input = PickLocationVM.Input(
            
            sendTrigger: self.sendButton.rx.tap.asDriver(),
            backTrigger: self.backButton.rx.tap.asDriver(),
            myLocationTrigger: self.myLocationButton.rx.tap.asDriver())
        let output = self.viewModel.transform(input: input)
        output.fetching.drive(onNext: { [unowned self] (show) in
            self.showLoading(withStatus: show)
        }).disposed(by: self.disposeBag)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.showLoading(withStatus: false)
            self.handleError(error: error)
        }).disposed(by: self.disposeBag)
    }
    
    @IBAction func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        
        let lat = NumberUtils.RoundDoubleTo6DigitsPrecision(input: locationCoordinate.latitude)
        let long = NumberUtils.RoundDoubleTo6DigitsPrecision(input: locationCoordinate.longitude)
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        if self.annotation != nil {
            mapView.removeAnnotation(self.annotation!)
        }
        annotation.title = "Vị trí đang được chọn"
        self.annotation = annotation
        mapView.addAnnotation(self.annotation!)
        self.viewModel.updateLatLong(latitude: lat, longtitude: long)
        self.locationLabel.text = "\(lat), \(long)"
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let reuseIdentifier = "pin"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
//
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//            annotationView?.canShowCallout = true
//        } else {
//            annotationView?.annotation = annotation
//        }
//
//        let customPointAnnotation = annotation as! CustomPointAnnotation
//        annotationView?.image = UIImage(named: customPointAnnotation.pinCustomImageName)
//
//        return annotationView
//    }
}

extension PickLocationVC: PickLocationtDisplayLogic {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func pointToMyLocation() {
        mapView.removeAnnotation(self.annotation!)
        
        if let userLocation = self.locationManager?.location?.coordinate {
            let lat = NumberUtils.RoundDoubleTo6DigitsPrecision(input: userLocation.latitude)
            let long = NumberUtils.RoundDoubleTo6DigitsPrecision(input: userLocation.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.title = "Vị trí của bạn"
            self.annotation = annotation
            
            mapView.addAnnotation(self.annotation!)
            
            let region = MKCoordinateRegionMakeWithDistance(
                userLocation, 500, 500)
            mapView.setRegion(region, animated: true)
            
            self.viewModel.updateLatLong(latitude: lat, longtitude: long)
            self.locationLabel.text = "\(lat), \(long)"
        }
        else {
            let lat = NumberUtils.RoundDoubleTo6DigitsPrecision(input: defaultLocation.coordinate.latitude)
            let long = NumberUtils.RoundDoubleTo6DigitsPrecision(input: defaultLocation.coordinate.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.title = "Vị trí mặc định"
            annotation.subtitle = "Không thể xác định vị trí của bạn"
            self.annotation = annotation
            mapView.addAnnotation(self.annotation!)
            
            let region = MKCoordinateRegionMakeWithDistance(
                defaultLocation.coordinate, 500, 500)
            mapView.setRegion(region, animated: true)
            
            self.viewModel.updateLatLong(latitude: lat, longtitude: long)
            self.locationLabel.text = "\(lat), \(long)"
        }
    }
}
