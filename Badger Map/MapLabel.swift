//
//  MapLabel.swift
//  ARKit+CoreLocation
//
//  Created by Shawn Zhong on 11/10/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import SceneKit
import UIKit
import MapKit

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
        self.node = LocationAnnotationNode(location: pinLocation, image: MapLabel.getImage(name: name, size: 1000))
        node.scaleRelativeToDistance = true
    }
    
    static func getImage(name: NSString, size: CGFloat) -> UIImage {
        let font = UIFont(name: "Courier-Bold", size: size)!
        let size = CGSize(
            width: CGFloat(size * CGFloat(name.length) * 0.75),
            height: font.lineHeight
        )
        //draw image first
        UIGraphicsBeginImageContext(size)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let ctx = UIGraphicsGetCurrentContext()!
        
        ctx.setFillColor(gray:1, alpha: 1)
        ctx.addPath(UIBezierPath(roundedRect: rect, cornerRadius: size.height / 4 ).cgPath)
        ctx.fillPath()
        
        //vertically center (depending on font)
        let text_style=NSMutableParagraphStyle()
        text_style.alignment=NSTextAlignment.center
        
        let text_color = UIColor(white: CGFloat(0), alpha: CGFloat(1))
        
        let attributes=[
            NSAttributedString.Key.font:font,
            NSAttributedString.Key.paragraphStyle:text_style,
            NSAttributedString.Key.foregroundColor:text_color
        ]
        
        
        let text_rect_name = CGRect(
            x: 0,
            y: (size.height - font.lineHeight) / 4,
            width: size.width,
            height: font.lineHeight
        )
        
        name.draw(in: text_rect_name.integral, withAttributes: attributes)
        
        let result=UIGraphicsGetImageFromCurrentImageContext()
        
        return result!
    }
}
