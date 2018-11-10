//
//  ViewController.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import UIKit
import SceneKit 
import MapKit
import CocoaLumberjack
import Alamofire

@available(iOS 11.0, *)
class ViewController: UIViewController, MKMapViewDelegate, SceneLocationViewDelegate {
    let sceneLocationView = SceneLocationView()
    
    let mapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    
    var updateUserLocationTimer: Timer?
    
    ///Whether to show a map view
    ///The initial value is respected
    var showMapView: Bool = false
    
    var centerMapOnUserLocation: Bool = false
    
    ///Whether to display some debugging data
    ///This currently displays the coordinate of the best location estimate
    ///The initial value is respected
//    var displayDebugging = false
    
 //  var infoLabel = UILabel()
    
//    var updateInfoLabelTimer: Timer?
    
    var updatePlaceTimer : Timer?
    
    var adjustNorthByTappingSidesOfScreen = false
    
    var currLocation : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    var placesList : PlacesList = PlacesList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        infoLabel.font = UIFont.systemFont(ofSize: 10)
//        infoLabel.textAlignment = .left
//        infoLabel.textColor = UIColor.white
//        infoLabel.numberOfLines = 0
 //       sceneLocationView.addSubview(infoLabel)
        
//        updateInfoLabelTimer = Timer.scheduledTimer(
//            timeInterval: 0.1,
//            target: self,
//            selector: #selector(ViewController.updateInfoLabel),
//            userInfo: nil,
//            repeats: true)
        
        updatePlaceTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(ViewController.updatePlace),
            userInfo: nil,
            repeats: true)
        
        //Set to true to display an arrow which points north.
        //Checkout the comments in the property description and on the readme on this.
//        sceneLocationView.orientToTrueNorth = false
        
//        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        //sceneLocationView.showAxesNode = false
        sceneLocationView.locationDelegate = self
        
//        if displayDebugging {
//            sceneLocationView.showFeaturePoints = true
//        }

        view.addSubview(sceneLocationView)
//        let rect = CGRect(x: 10, y: 10, width: 100, height: 100)
//        let myView = UIView(frame: rect)
//        view.addSubview(myView)
        
//        if showMapView {
//            mapView.delegate = self
//            mapView.showsUserLocation = true
//            mapView.alpha = 0.8
//            view.addSubview(mapView)
//
//            updateUserLocationTimer = Timer.scheduledTimer(
//                timeInterval: 0.5,
//                target: self,
//                selector: #selector(ViewController.updateUserLocation),
//                userInfo: nil,
//                repeats: true)
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DDLogDebug("run")
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DDLogDebug("pause")
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
//
//        infoLabel.frame = CGRect(x: 6, y: 0, width: self.view.frame.size.width - 12, height: 14 * 4)
//
//        if showMapView {
//            infoLabel.frame.origin.y = (self.view.frame.size.height / 2) - infoLabel.frame.size.height
//        } else {
//            infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
//        }
//
        mapView.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height / 2,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height / 2)
    }
    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Release any cached data, images, etc that aren't in use.
//    }
    
    @objc func updatePlace() {
        var urlStr = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyCTuPGgIixohdDF2qpJ5NyuvTa6A7GrTUo&type=restaurant&location="
        urlStr += String(format:"%.15f", self.currLocation.latitude)+","
        urlStr += String(format:"%.15f", self.currLocation.longitude)+"&radius=300"

        //print(urlStr)
        Alamofire.request(urlStr).responseJSON { response in
            if let jsonObj = try! JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                //print(jsonObj)
                if let places = jsonObj["results"] as? Array<[String : Any]> {
                    self.placesList.updateList(new_list: places,view_controller: self)
                    let add_list = self.placesList.getAddList()
                    for item in add_list {
                        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: item["node"] as! LocationNode)
                    }
                }
            }
        }
    }
    
    @objc func updateUserLocation() {
        if let currentLocation = sceneLocationView.currentLocation() {
            DispatchQueue.main.async {
                if let bestEstimate = self.sceneLocationView.bestLocationEstimate(),
                    let position = self.sceneLocationView.currentScenePosition() {
                    DDLogDebug("")
                    DDLogDebug("Fetch current location")
                    DDLogDebug("best location estimate, position: \(bestEstimate.position), location: \(bestEstimate.location.coordinate), accuracy: \(bestEstimate.location.horizontalAccuracy), date: \(bestEstimate.location.timestamp)")
                    DDLogDebug("current position: \(position)")
                    
                    let translation = bestEstimate.translatedLocation(to: position)
                    
                    
                    DDLogDebug("translation: \(translation)")
                    DDLogDebug("translated location: \(currentLocation)")
                    DDLogDebug("")
                }
                
                if self.userAnnotation == nil {
                    self.userAnnotation = MKPointAnnotation()
                    self.mapView.addAnnotation(self.userAnnotation!)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                    self.userAnnotation?.coordinate = currentLocation.coordinate
                }, completion: nil)
            
                if self.centerMapOnUserLocation {
                    UIView.animate(withDuration: 0.45, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                        self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                    }, completion: {
                        _ in
                        self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
                    })
                }
                
//                if self.displayDebugging {
//                    let bestLocationEstimate = self.sceneLocationView.bestLocationEstimate()
//
//                    if bestLocationEstimate != nil {
//                        if self.locationEstimateAnnotation == nil {
//                            self.locationEstimateAnnotation = MKPointAnnotation()
//                            self.mapView.addAnnotation(self.locationEstimateAnnotation!)
//                        }
//
//                        self.locationEstimateAnnotation!.coordinate = bestLocationEstimate!.location.coordinate
//                    } else {
//                        if self.locationEstimateAnnotation != nil {
//                            self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
//                            self.locationEstimateAnnotation = nil
//                        }
//                    }
//                }
            }
        }
    }
    
//    @objc func updateInfoLabel() {
//        if let position = sceneLocationView.currentScenePosition() {
//            infoLabel.text = "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
//        }
//
//        if let eulerAngles = sceneLocationView.currentEulerAngles() {
//            infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
//        }
//
//        if let heading = sceneLocationView.locationManager.heading,
//            let accuracy = sceneLocationView.locationManager.headingAccuracy {
//            infoLabel.text!.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
//        }
//
//        let date = Date()
//        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
//
//        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
//            infoLabel.text!.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
//        }
//    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//
//        if let touch = touches.first {
//            if touch.view != nil {
//                if (mapView == touch.view! ||
//                    mapView.recursiveSubviews().contains(touch.view!)) {
//                    centerMapOnUserLocation = false
//                } else {
//
//                    let location = touch.location(in: self.view)
//
//                    if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
//                        print("left side of the screen")
//                        sceneLocationView.moveSceneHeadingAntiClockwise()
//                    } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
//                        print("right side of the screen")
//                        sceneLocationView.moveSceneHeadingClockwise()
//                    } else {
//                        let image = UIImage(named: "pin")!
//                        let annotationNode = LocationAnnotationNode(location: nil, image: image)
//                        annotationNode.scaleRelativeToDistance = true
//                        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
//                    }
//                }
//            }
//        }
//    }
    
    //MARK: MKMapViewDelegate
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            return nil
//        }
//
//        if let pointAnnotation = annotation as? MKPointAnnotation {
//            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
//
//            if pointAnnotation == self.userAnnotation {
//                marker.displayPriority = .required
//                marker.glyphImage = UIImage(named: "user")
//            } else {
//                marker.displayPriority = .required
//                marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
//                marker.glyphImage = UIImage(named: "compass")
//            }
//
//            return marker
//        }
//
//        return nil
//    }
    
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        //DDLogDebug("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
        self.currLocation = location.coordinate
    }
    
   func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
//        DDLogDebug("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
   }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
}

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
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
