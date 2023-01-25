//
//  MapViewController.swift
//  favoritePlaces_PAVIT_868150
//
//  Created by PAVIT KALRA on 2023-01-24.
//

import UIKit
import MapKit
import CoreLocation
protocol MapViewControllerDelegate: AnyObject {
    func didSelectAnnotation(title: String)
}
class MapViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate{
    weak var delegate: MapViewControllerDelegate?
    @IBOutlet weak var map: MKMapView!
    var selectedAnnotation: MKPointAnnotation?
    let searchController = UISearchController(searchResultsController: nil)
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        showSearchBar()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        map.addGestureRecognizer(longPressGesture)
        
        map.delegate = self
        map.isZoomEnabled = false
    }
    
    
    func showSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Location"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .lightGray
    }
    
    
    @IBAction func zoomIn(_ sender: UIButton) {
        let currentRegion = map.region
        let newRegion = MKCoordinateRegion(center: currentRegion.center, span: MKCoordinateSpan(latitudeDelta: currentRegion.span.latitudeDelta/2, longitudeDelta: currentRegion.span.longitudeDelta/2))
        map.setRegion(newRegion, animated: true)
    }
    
    @IBAction func zoomOut(_ sender: UIButton) {
        let currentRegion = map.region
        let newRegion = MKCoordinateRegion(center: currentRegion.center, span: MKCoordinateSpan(latitudeDelta: currentRegion.span.latitudeDelta*2, longitudeDelta: currentRegion.span.longitudeDelta*2))
        map.setRegion(newRegion, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        
        displayLocation(latitude: latitude, longitude: longitude)
    }
    
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        //DEFINE SPAN
        let latdelta: CLLocationDegrees = 0.05
        let lngdelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latdelta, longitudeDelta: lngdelta)
        
        
        //DEFINE LOCATION
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        
        //DEFINE REGION
        let region = MKCoordinateRegion(center: location, span: span)
        
        
        //SET REGION ON MAP
        map.setRegion(region, animated: true)
        
    }
    
    @objc func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: map)
            let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            addToFavorites(annotation: annotation)
            selectedAnnotation = annotation
        }
    }
    
    func addToFavorites(annotation: MKPointAnnotation) {
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                print(error!)
            } else {
                if let placemark = placemarks?[0] {
                    annotation.title = placemark.name
                    self.map.addAnnotation(annotation)
                }
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchTerm = searchBar.text!

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        request.region = map.region

        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
            } else if response?.mapItems.count == 0 {
                print("No results found")
            } else {
                let firstResult = response!.mapItems[0]
                let annotation = MKPointAnnotation()
                annotation.coordinate = firstResult.placemark.coordinate
                annotation.title = firstResult.name
                self.map.addAnnotation(annotation)
                self.map.showAnnotations([annotation], animated: true)
            }
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is MKPointAnnotation else { return nil }
            
            let identifier = "Annotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let btn = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = btn
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let alert = UIAlertController(title: "Add to favorites", message: "Do you want to add this location to your favorites?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.selectedAnnotation = view.annotation as? MKPointAnnotation
            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                let address = self?.getAddress(for: view.annotation!.coordinate)
                // Save the address to UserDefaults
                UserDefaults.standard.set(address, forKey: "favorite_address")
                guard let selectedAnnotation = self?.selectedAnnotation else { return }
                self?.delegate?.didSelectAnnotation(title: selectedAnnotation.title ?? "My favorite address")
                self?.navigationController?.popViewController(animated: true)
            }
            // Add the save action to the alert controller
            alert.addAction(saveAction)
            // Present the alert controller
            present(alert, animated: true, completion: nil)
        }
    }
    func getAddress(for location: CLLocationCoordinate2D) -> String? {
        let geocoder = CLGeocoder()
        var address: String?
        geocoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?.first {
                    address = self.getFormattedAddress(from: placemark)
                }
            } else {
                print("Error getting address: \(error!)")
            }
        }
        return address
    }
    func getFormattedAddress(from placemark: CLPlacemark) -> String {
        var address = ""
        if let street = placemark.thoroughfare {
            address += street + ", "
        }
        if let city = placemark.locality {
            address += city + ", "
        }
        if let state = placemark.administrativeArea {
            address += state + " "
        }
        if let postalCode = placemark.postalCode {
            address += postalCode + ", "
        }
        if let country = placemark.country {
            address += country
        }
        return address
    }
}
