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

@available(iOS 11.0, *)
class ViewController: UIViewController, MKMapViewDelegate {
    
    let sceneLocationView = SceneLocationView()
    let mapView = MKMapView()
    let searchBar = UISearchController(searchResultsController: nil)
    
    var updateUserLocationTimer: Timer?
    var updatePlaceTimer : Timer?
    
    var currLocation : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.alpha = 0.8
        

        view.addSubview(sceneLocationView)
        view.addSubview(mapView)
        
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
        
        mapView.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height / 2,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height / 2
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
}

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}



class MapLabel{
    let name: NSString
    let latitude:CLLocationDegrees
    let longitude:CLLocationDegrees
    let node: LocationAnnotationNode
    
    public init(name: NSString, latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        self.name =  name;
        self.latitude = latitude;
        self.longitude = longitude;
        
        let pinCoordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 266)
        self.node = LocationAnnotationNode(location: pinLocation, image: MapLabel.getImage(name: name, size: 750))
        node.scaleRelativeToDistance = true
    }
    
    
    func getNode() -> LocationAnnotationNode{
        return self.node
    }
    
    static func getImage(name: NSString, size: CGFloat) -> UIImage {
        //text attributes
        let font=UIFont(name: "Courier-Bold", size: size)!
        let text_style=NSMutableParagraphStyle()
        text_style.alignment=NSTextAlignment.center
        let text_color=UIColor(white: CGFloat(0), alpha: CGFloat(1))
        let attributes=[NSAttributedString.Key.font:font, NSAttributedString.Key.paragraphStyle:text_style, NSAttributedString.Key.foregroundColor:text_color]
        
        let size = CGSize(width: CGFloat(size * CGFloat(name.length)*0.75), height: font.lineHeight*2)
        //draw image first
        UIGraphicsBeginImageContext(size)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(gray:1, alpha: 1)
        
        ctx.addPath(UIBezierPath(roundedRect: rect, cornerRadius: 10).cgPath)
        ctx.closePath()
        ctx.fillPath()
        ctx.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
        ctx.addPath(UIBezierPath(roundedRect: rect, cornerRadius: 10).cgPath)
        ctx.closePath()
        ctx.strokePath()
        
        //vertically center (depending on font)
        let text_h=font.lineHeight
        
        let text_rect_name=CGRect(x: 0, y: (size.height-text_h)/4, width: size.width, height: text_h)
        
        name.draw(in: text_rect_name.integral, withAttributes: attributes)
        
        let result=UIGraphicsGetImageFromCurrentImageContext()
        
        return result!
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    
}
