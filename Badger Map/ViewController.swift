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
        MapLabel(name: "Chadbourne", latitude: 43.073676, longitude: -89.400900, info: "Chadbourne Residence Hall is a popular option for both first-year and non-freshman residents, offering updated amenities and lots of gathering space. Home to the Chadbourne Residential College (a learning community sponsored by the College of Letters & Science and University Housing), Chadbourne offers a great blend of academic and residential life to all who live here."),
        MapLabel(name: "Bascom", latitude: 43.075357, longitude: -89.404098, info: "Bascom Hill is the main quadrangle that forms the symbolic core of the University of Wisconsin–Madison campus. It is located on the opposite end of State Street from the Wisconsin State Capitol, and is named after John Bascom, former president of the University of Wisconsin. The hill itself is a drumlin,[2] formed by glacial deposits about 18,000 years ago."),
        MapLabel(name: "Van Vleck", latitude: 43.074830, longitude: -89.404665, info: "Department of mathematics. It was picked as the most ugliest hall in some surveys. "),
        MapLabel(name: "Engineering", latitude: 43.071780, longitude: -89.410150, info: "Headquarter of nerds sponsored by Foxconn"),
        MapLabel(name: "Regent", latitude: 43.067998, longitude: -89.409786, info: "The Regent Apartments offer a 24-hour desk, friendly staff, a flat utility fee that includes 50 Mbps Internet, an iMac and PC computer station, game room, outdoor sports courts, fire pit and grill station, private and group study rooms, free Fitness On Demand, a gym room, and more."),
        MapLabel(name: "Lucky", latitude: 43.072898, longitude: -89.398432, info: "Lucky sets the standard for hassle-free campus living. As Madison’s skyline fills in, we’re still the only owner who understands that the luxury high-rise lifestyle isn’t just about amenities and looks; it’s also about the way the residents and the building are treated – with respect, dignity, and care."),
        MapLabel(name: "Computer Sciences", latitude: 43.071467, longitude: -89.406842, info: "In any case, bugs are prohibited here. "),
        MapLabel(name: "Chazen", latitude: 43.073877, longitude: -89.398433, info: "The Chazen is home to the second-largest collection of art in Wisconsin: more than 20,000 works include paintings, sculpture, drawings, prints, photographs, and decorative arts. The permanent collection covers diverse historical periods, cultures, and geographic locations, from ancient Greece, Western Europe, and the Soviet Empire, to Moghul India, eighteenth-century Japan, and modern Africa. The collection continues to grow thanks to artwork donations and purchases."),
        MapLabel(name: "College Library", latitude: 43.076746, longitude: -89.401241, info: "A good place for self study and group study with great view and diversy resources. "),
        MapLabel(name: "Dejope", latitude: 43.077607, longitude: -89.417774, info: "Having opened in 2012, Dejope Residence Hall is one of the Division of University Housing’s newest residence halls. Dejope is home to a mix of first-year and non-freshman residents, as well as the Four Lakes Market (one of six dining markets on campus), classroom space, on-site academic advising, a Technology Learning Center (TLC), and the satellite office to University Health Services (UHS). This new building features carpeted resident rooms with air conditioning and spacious walk-in closets."),
        MapLabel(name: "University Hospital", latitude: 43.076614, longitude: -89.431305, info: "With each visit to a UW Health clinic, we strive to exceed your expectations. You are welcome to contact the clinic manager if you would like personal assistance with any issue. Simply call the scheduling number for the clinic you visited and ask for the clinic manager. If you would care to Submit a Compliment, Concern or Complaint in a more formal manner, please contact Patient Relations."),
        MapLabel(name: "Natatorium", latitude: 43.076869, longitude: -89.420439, info: "Enjoy a workout or a swim at the historic Natatorium, located right along the Lakeshore Path."),
        MapLabel(name: "Randall Stadium", latitude: 43.069920, longitude: -89.412576, info: "Camp Randall Stadium is an outdoor stadium. It has been the home of Wisconsin Badgers football since 1895, with a fully functioning stadium since 1917. The oldest and fifth largest stadium in the Big Ten Conference, Camp Randall is the 41st largest stadium in the world, with a seating capacity of 80,321."),
    ]
    
//    var arrows: Array<Arrow> = []
    var filteredList : Array<MapLabel> = []

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoView: UITextView!
    
    
    var button: UIButton!
    var updateUserLocationTimer: Timer?
    var curLat: CLLocationDegrees = 0.0
    var curLong: CLLocationDegrees = 0.0
    
    let sceneLocationView = SceneLocationView()
    let locationManager = CLLocationManager()
    
    let listener = UIViewController()
    
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
        
        //infoView
        infoView.layer.cornerRadius = 25.0;
        
        view.addSubview(sceneLocationView)  
        view.addSubview(mapView)
        view.addSubview(tableView)
        view.addSubview(searchBar)
        view.addSubview(infoView)
        
        
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
        self.mapView.removeOverlays(self.mapView.overlays)
        initView()
    }
    
    func initView(){
        for mapLabel in list {
            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: mapLabel.node)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
//        if let eulerAngles = sceneLocationView.currentEulerAngles() {
//            print("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
//        }
        if let touch = touches.first {
            if touch.view != nil {
                if (mapView == touch.view! ||
                    mapView.recursiveSubviews().contains(touch.view!)) {
//                    centerMapOnUserLocation = false
                } else {
                    let sceneView = self.sceneLocationView
                    let location = touch.location(in: sceneView)
                    let hitTest = sceneView.hitTest(location)
                    
                    if (!hitTest.isEmpty) {
                        let results = hitTest.first!
                        let currentNode = results.node
                        if let locationNode = getLocationNode(node: currentNode) {
                            for label in list{
                                if(label.node == locationNode){
                                    infoView.text = (label.name as String) + "\r\n" + (label.info as String);
                                    infoView.isHidden = false;
                                    print(label.name)
                                    return
                                }
                            }
//                            var cur:LocationAnnotationNode = locationNode
//                            DDLogDebug("")
//                            DDLogDebug("title: \(locationNode.titlePlace!)")
//                            let distance = locationNode.location.distance(from: sceneView.currentLocation()!)
//                            DDLogDebug("distance: \(distance)")
                        }
                    }else if(!infoView.isHidden){
                        infoView.isHidden = true;
                        print("test")
                    }
                }
            }
        }
     }
    
    func getLocationNode(node: SCNNode) -> LocationAnnotationNode? {
        if node.isKind(of: LocationNode.self) {
            return node as? LocationAnnotationNode
        } else if let parentNode = node.parent {
            return getLocationNode(node: parentNode)
        }
        return nil
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
        searchBar.text = ""
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
        searchBar.text = ""
        
        for label in list{
            self.sceneLocationView.removeLocationNode(locationNode: label.node);
        }
        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: filteredList[indexPath.row].node)
        
        self.mapView.removeOverlays(self.mapView.overlays)
        directionRequest(mapLabel: filteredList[indexPath.row])
    }
    
    func directionRequest(mapLabel: MapLabel){
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: curLat, longitude: curLong), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: mapLabel.latitude, longitude: mapLabel.longitude), addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        curLat = locValue.latitude
        curLong = locValue.longitude
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5
        return renderer
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}
