//
//  ViewController2.swift
//  ARKit+CoreLocation
//
//  Created by Shawn Zhong on 11/10/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit
import SceneKit
import MapKit

@available(iOS 11.0, *)
class ViewController2: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    var list: Array<MapLabel> = [
        MapLabel(name: "GC", latitude: 43.072433, longitude: -89.403405),
        MapLabel(name: "Chad", latitude: 43.073676, longitude: -89.400900)
    ]

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    let sceneLocationView = SceneLocationView()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.layer.cornerRadius = 25.0;
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: false)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        searchBar.delegate = self
        
        for mapLabel in list {
            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: mapLabel.getNode())
        }
        
        view.addSubview(sceneLocationView)
        view.addSubview(mapView)
        view.addSubview(searchBar)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height
        )
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        print(searchBar.text!)
        searchBar.endEditing(true)
    }
}
