//
//  MapViewController.swift
//  Grodno Guide
//
//  Created by Mikhail Ladutska on 3/3/20.
//  Copyright © 2020 Mikhail Ladutska. All rights reserved.
//

import UIKit
import MapKit
import Contacts


class MapViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // may be for future needs
    //var responseResult: [MKMapItem]! = []
   
    let regionGrodno = CLLocationCoordinate2D(latitude: 53.6688, longitude: 23.8223)
    
    
    var locationManager = CLLocationManager()
    var pointsOfInterest: MKPointOfInterestFilter! = nil
    var toiletButtonClicked = false
    var controllerName = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        changeTitle(name: controllerName)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationEnabled()
    }
    
    //change viewcontroller title
    private func changeTitle(name: String) {
        switch name {
        case _:
            self.title = name
        default:
            break
        }
    }
    
    // add free toilets in Grodno :)
   private func addToilets() {
        let univermagLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(53.68244992829319, 23.831569254398346)
        let univermag = Toilets(title: "Универмаг", subtitle: "Советская улица, 18, Торговый дом Неман, на первом этаже", coordinate: univermagLocation)
        let molodegaLocation = CLLocationCoordinate2DMake(53.679730216954866, 23.831417709589005)
        let molodega = Toilets(title: "Молодежный центр Гродно", subtitle: "вход сбоку", coordinate: molodegaLocation)
        let underBridgeLocation = CLLocationCoordinate2DMake(53.67402628507989, 23.82860563944418)
        let underBridgeToilet = Toilets(title: "Под мостом", subtitle: "вход под мостом", coordinate: underBridgeLocation)
        
        let toilets = [univermag, molodega, underBridgeToilet]
        
        for item in toilets {
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = item.coordinate
            annotation.title = item.title
            annotation.subtitle = item.subtitle
            
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        let annotationView = views.first!
        
        if let annotation = annotationView.annotation {
            
            if annotation is MKUserLocation {
                
                var region = MKCoordinateRegion()
                region.center = self.mapView.userLocation.coordinate
                region.span.latitudeDelta = 0.025
                region.span.longitudeDelta = 0.025
                
                self.mapView.setRegion(region, animated: false)
                
            }
            if toiletButtonClicked == false {
                searchPlaces()
            } else {
                addToilets()
            }
            
        }
        
    }
    
    
    //find me button method
    
    @IBAction func findMeButtonTapped(_ sender: UIButton) {
        centerViewOnUserLocation()
    }
    
    //MARK: - Search places method
    private func searchPlaces() {
        
        let request = MKLocalSearch.Request()
        
        request.pointOfInterestFilter = pointsOfInterest
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            
            guard let response = response else {
                return
            }
            
            for item in response.mapItems {
                
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                annotation.subtitle = item.placemark.postalAddress?.street
            
                DispatchQueue.main.async {
                    self?.mapView.addAnnotation(annotation)
                }
            }
        }
        
    }
    
    //MARK: - Check authorization
    private func checkAuthorizationStatus() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            mapView.mapType = .standard
            self.overrideUserInterfaceStyle = .light
            // locationManager.startUpdatingLocation()
            centerViewOnUserLocation()
        case .denied:
            showAlert(title: "Your location service is disabled", message: "Please provide your location for better service", url: URL(string: UIApplication.openSettingsURLString))
            mapView.setCenter(regionGrodno, animated: false)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.setCenter(regionGrodno, animated: false)
        case .restricted:
            break
        @unknown default:
            fatalError()
        }
    }
    
    // create alert method
    private func showAlert(title: String, message: String?, url: URL?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alert) in
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    private func checkLocationEnabled() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkAuthorizationStatus()
        } else {
            showAlert(title: "Your location service turned off", message: "Enable your location for better service", url: URL(string: UIApplication.openSettingsURLString))
        }
        
    }
    
    private func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    private func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(region, animated: false)
        }
    }
    
    
    
}
// location manager delegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(region, animated: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorizationStatus()
    }
    
}
// subscribing to mapview delegate and create custom pin annotation
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            //pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = UIColor.systemPink
        }
        else {
            
            pinView!.annotation = annotation
        }
        return pinView
    }
    
}
