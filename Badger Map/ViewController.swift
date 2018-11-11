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
        MapLabel(name: "GC", latitude: 43.072433, longitude: -89.403405),
        MapLabel(name: "Chad", latitude: 43.073676, longitude: -89.400900)
    ]
    
    var filteredList : Array<MapLabel> = []

    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
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
       
        
        
        // resetBtn
        resetBtn.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        resetBtn.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: resetBtn.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: resetBtn.widthAnchor),
            ])
        
        
        view.addSubview(sceneLocationView)
        view.addSubview(mapView)
        view.addSubview(tableView)
        view.addSubview(searchBar)
        view.addSubview(resetBtn)
        
        
        let button = UIButton()
        button.frame = CGRect(x: self.view.frame.size.width - 60, y: 60, width: 50, height: 50)
        button.backgroundColor = UIColor.red
        button.setTitle("Name your Button ", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
    }

    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    func initView(){
        print("called")
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
        sceneLocationView.isHidden = false
        searchBar.endEditing(true)
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        
        for label in list{
            self.sceneLocationView.removeLocationNode(locationNode: label.node);
        }
        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: list[indexPath.row].node)
    }
}
