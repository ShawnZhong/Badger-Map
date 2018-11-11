//
//  ViewController.swift
//  ARKit+CoreLocation
//
//  Created by Shawn Zhong on 11/10/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit
import SceneKit
import MapKit

@available(iOS 11.0, *)
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate{
    
    let list: Array<MapLabel> = [
        MapLabel(name: "Chadbourne", latitude: 43.073676, longitude: -89.400900),
        MapLabel(name: "Bascom", latitude: 43.075357, longitude: -89.404098),
        MapLabel(name: "Van Vleck", latitude: 43.074830, longitude: -89.404665),
        MapLabel(name: "Engineering", latitude: 43.071780, longitude: -89.410150),
        MapLabel(name: "Regent", latitude: 43.067998, longitude: -89.409786),
        MapLabel(name: "Lucky", latitude: 43.072898, longitude: -89.398432),
        MapLabel(name: "Computer Science", latitude: 43.071467, longitude: -89.406842),
    ]
    
    var filteredList : Array<MapLabel> = []

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var button: UIButton!
    
    let sceneLocationView = SceneLocationView()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sceneLocationView
        initView()
        filteredList = list
        
        // mapView
        mapView.delegate = self
        mapView.layer.cornerRadius = 25.0;
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
    
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: false)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        
        // searchBar
        searchBar.delegate = self
        
        //tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
       
        
        view.addSubview(sceneLocationView)
        view.addSubview(mapView)
        view.addSubview(tableView)
        view.addSubview(searchBar)
        
        
        self.button = UIButton()
        self.button.isHidden = true
        self.button.layer.cornerRadius = 10.0;
        self.button.frame = CGRect(
            x: 50,
            y: self.view.frame.size.height - 200,
            width: 75,
            height: 45
        )
        self.button.backgroundColor = UIColor.red
        self.button.setTitle("Reset", for: .normal)
        self.button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
       
        view.addSubview(self.button)
    }

    
    @objc func buttonAction(sender: UIButton!) {
        self.button.isHidden = true
        initView()
    }
    
    func initView(){
        for mapLabel in list {
            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: mapLabel.node)
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.isHidden = true
        self.button.isHidden = false
        sceneLocationView.isHidden = false
        searchBar.endEditing(true)
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        
        for label in list{
            self.sceneLocationView.removeLocationNode(locationNode: label.node);
        }
        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: list[indexPath.row].node)
    }
}
