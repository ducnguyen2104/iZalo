//
//  ViewLocationVC.swift
//  iZalo
//
//  Created by CPU11613 on 10/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

protocol ViewLocationtDisplayLogic: class {
    func goBack()
    func pointToMyLocation()
}

class ViewLocationVC: BaseVC, MKMapViewDelegate, CLLocationManagerDelegate {

    public typealias ViewModelType = ViewLocationVM
    public var viewModel: ViewLocationVM!
    
    class func instance(lat: Double, long: Double) -> ViewLocationVC {
        return ViewLocationVC(lat: lat, long: long)
    }
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toMyLocationButton: UIButton!
    var locationManager: CLLocationManager?
    private var lat: Double?
    private var long: Double?
    private let disposeBag = DisposeBag()
    private let defaultLocation = CLLocation(latitude: 10.773695, longitude: 106.660454)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(lat: Double, long: Double) {
        super.init(nibName: "ViewLocationVC", bundle: nil)
        self.lat = lat
        self.long = long
        self.viewModel = ViewLocationVM(displayLogic: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        setupLayout()
        bindViewModel()
    }

    func setupLayout() {
        
        toMyLocationButton.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        toMyLocationButton.layer.cornerRadius = toMyLocationButton.frame.height/2
        toMyLocationButton.layer.borderColor = UIColor.gray.cgColor
        toMyLocationButton.layer.borderWidth = 0.1
        
                mapView.showsUserLocation = true
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!)
        annotation.title = "Vị trí được chia sẻ"
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegionMakeWithDistance(
            CLLocation(latitude: self.lat!, longitude: self.long!).coordinate, 500, 500)
        mapView.setRegion(region, animated: true)
    }
    
    func bindViewModel() {
        let input = ViewLocationVM.Input(
            
            backTrigger: self.backButton.rx.tap.asDriver(),
            myLocationTrigger: self.toMyLocationButton.rx.tap.asDriver())
        let output = self.viewModel.transform(input: input)
        output.fetching.drive(onNext: { [unowned self] (show) in
            self.showLoading(withStatus: show)
        }).disposed(by: self.disposeBag)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.showLoading(withStatus: false)
            self.handleError(error: error)
        }).disposed(by: self.disposeBag)
    }
}
extension ViewLocationVC: ViewLocationtDisplayLogic {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func pointToMyLocation() {
        
        if let userLocation = self.locationManager?.location?.coordinate {
            let region = MKCoordinateRegionMakeWithDistance(
                userLocation, 500, 500)
            mapView.setRegion(region, animated: true)
            
        }
        else {
            showToast(message: "Không thể xác định vị trí của bạn")
        }
    }
}
