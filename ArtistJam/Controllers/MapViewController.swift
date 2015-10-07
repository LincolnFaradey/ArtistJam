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
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPressOnMap:")
        longPress.delegate = self
        mapView.addGestureRecognizer(longPress)
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpanMake(0.25, 0.25))
        
        mapView.setRegion(region, animated: true)
    }
    
    
    func longPressOnMap(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            mapView.removeAnnotations(mapView.annotations)
            let point = sender.locationInView(mapView)
            acceptedCoordinates = mapView.convertPoint(point, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = acceptedCoordinates!
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func acceptLocation(sender: UIButton) {
        delegate?.controller(self, didAcceptCoordinate: acceptedCoordinates!)
        navigationController?.popViewControllerAnimated(true)
    }
    
}
