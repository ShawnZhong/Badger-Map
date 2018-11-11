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
class ViewController2: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDataSource {
    
    let list: Array<MapLabel> = [
        MapLabel(name: "GC", latitude: 43.072433, longitude: -89.403405),
        MapLabel(name: "Chad", latitude: 43.073676, longitude: -89.400900)
    ]
    
    var filteredList : Array<MapLabel> = []

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    let sceneLocationView = SceneLocationView()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredList = list
        
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
        
        for mapLabel in list {
            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: mapLabel.getNode())
        }
        
        searchBar.delegate = self
        
        tableView.dataSource = self
        tableView.isHidden = true;
        
        view.addSubview(sceneLocationView)
        view.addSubview(mapView)
        view.addSubview(searchBar)
        view.addSubview(tableView)
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
        tableView.isHidden = true
        sceneLocationView.isHidden = false
        searchBar.endEditing(true)
        searchBar.searchBarStyle = UISearchBar.Style.minimal
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        tableView.isHidden = false
        sceneLocationView.isHidden = true
        searchBar.searchBarStyle = UISearchBar.Style.default
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            filteredList = list
        } else {
            let tmp = list.filter({( mapLabel : MapLabel) -> Bool in
                return mapLabel.name.lowercased.contains(searchText.lowercased())
            })
            if(tmp.count != 0) {
                filteredList = tmp
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = filteredList[indexPath.row].name as String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        print(list[indexPath.row].name)
        tableView.isHidden = true;
    }
}
