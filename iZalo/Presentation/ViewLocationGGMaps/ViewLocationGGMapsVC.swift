//
//  ViewLocationGGMapsVC.swift
//  iZalo
//
//  Created by CPU11613 on 10/25/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift

protocol ViewLocationtGGMapsDisplayLogic: class {
    func goBack()
}

class ViewLocationGGMapsVC: BaseVC {
    
    public typealias ViewModelType = ViewLocationGGMapsVM
    public var viewModel: ViewLocationGGMapsVM!
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var backButton: UIButton!
    class func instance(lat: Double, long: Double) -> ViewLocationGGMapsVC {
        return ViewLocationGGMapsVC(lat: lat, long: long)
    }
    
    var ggMapView: GMSMapView!
    private var lat: Double?
    private var long: Double?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    private let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(lat: Double, long: Double) {
        super.init(nibName: "ViewLocationGGMapsVC", bundle: nil)
        self.lat = lat
        self.long = long
        self.viewModel = ViewLocationGGMapsVM(displayLogic: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindViewModel()
    }
    
    func setupLayout() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: lat!, longitude: long!, zoom: 17.0)
        ggMapView = GMSMapView.map(withFrame: self.mapView.bounds, camera: camera)
        
        ggMapView.settings.myLocationButton = true
        ggMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        ggMapView.isMyLocationEnabled = true
        
        view.addSubview(ggMapView)
        
        ggMapView.translatesAutoresizingMaskIntoConstraints = false
        ggMapView.topAnchor.constraint(equalTo: mapView.topAnchor).isActive = true
        ggMapView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor).isActive = true
        ggMapView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor).isActive = true
        ggMapView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor).isActive = true
        self.mapView.isHidden = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        marker.title = "Vị trí được chia sẻ"
        marker.map = ggMapView
    }
    func bindViewModel() {
        let input = ViewLocationGGMapsVM.Input(
            backTrigger: self.backButton.rx.tap.asDriver())
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

extension ViewLocationGGMapsVC: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
//        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17)
//
//        self.ggMapView.animate(to: camera)
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
        // Display the map using the default location.
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
extension ViewLocationGGMapsVC: ViewLocationtGGMapsDisplayLogic {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
