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
class ViewController2: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    let sceneLocationView = SceneLocationView()
    
    var updateUserLocationTimer: Timer?
    var updatePlaceTimer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.alpha = 0.8
        
        
        view.addSubview(sceneLocationView)
        view.addSubview(mapView)
        view.addSubview(searchBar)
        
        var list : Array<LocationAnnotationNode> = Array()
        list.append(MapLabel(name: "GC", latitude: 43.072433, longitude: -89.403405).getNode())
        list.append(MapLabel(name: "Chad", latitude: 43.073676, longitude: -89.400900).getNode())
        for mapLabel in list {
            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: mapLabel)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height
        )
        
//        mapView.frame = CGRect(
//            x: 0,
//            y: self.view.frame.size.height / 2,
//            width: self.view.frame.size.width,
//            height: self.view.frame.size.height / 2
//        )
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }
}
