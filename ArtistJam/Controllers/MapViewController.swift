//
//  MapViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/21/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func controller(controller: MapViewController, didAcceptCoordinate coordinates: CLLocationCoordinate2D)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var acceptedCoordinates: CLLocationCoordinate2D?
    var delegate: MapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector(("longPressOnMap:")))
        longPress.delegate = self
        mapView.addGestureRecognizer(longPress)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
        
        mapView.setRegion(region, animated: true)
    }
    
    
    func longPressOnMap(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            mapView.removeAnnotations(mapView.annotations)
            let point = sender.location(in: mapView)
            acceptedCoordinates = mapView.convert(point, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = acceptedCoordinates!
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func acceptLocation(sender: UIButton) {
        delegate?.controller(controller: self, didAcceptCoordinate: acceptedCoordinates!)
        navigationController?.popViewController(animated: true)
    }
    
}
