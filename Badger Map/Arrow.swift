//
//  Arrow.swift
//  Badger Map
//
//  Created by qsy on 2018/11/11.
//  Copyright © 2018年 Project Dent. All rights reserved.
//

import Foundation

import SceneKit
import UIKit
import MapKit

class Arrow{
    let latitude:CLLocationDegrees
    let longitude:CLLocationDegrees
    let node: LocationAnnotationNode

    public init(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        self.latitude = latitude;
        self.longitude = longitude;
        
        let pinCoordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: CLLocationDistance(280))
        self.node = LocationAnnotationNode(location: pinLocation, image: Arrow.getImage(size: 400))
        node.scaleRelativeToDistance = true
    }
    
    static func getImage(size: CGFloat) -> UIImage {
        let canvasSize = CGSize(
            width: 2*size,
            height: size
        )
        
        UIGraphicsBeginImageContext(canvasSize)
        
        let arrow = UIBezierPath.arrow(from: CGPoint(x: 0, y:0), to:CGPoint(x:800, y:0), tailWidth: 200, headWidth: 400, headLength: 300)
        let ctx = UIGraphicsGetCurrentContext()!
        
        ctx.setFillColor(gray:0.7, alpha: 1)
        ctx.addPath(arrow.cgPath)
        ctx.fillPath()
        
        let result=UIGraphicsGetImageFromCurrentImageContext()
        
        return result!
    }
}

extension UIBezierPath {
    
    class func arrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> Self {
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength
        
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }
        var points: [CGPoint] = [
            p(0, tailWidth / 2),
            p(tailLength, tailWidth / 2),
            p(tailLength, headWidth / 2),
            p(length, 0),
            p(tailLength, -headWidth / 2),
            p(tailLength, -tailWidth / 2),
            p(0, -tailWidth / 2)
        ]
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)
        
        let path = CGMutablePath()
        for i in 0..<points.count{
            path.addLine(to: points[i], transform: transform)
        }
        path.closeSubpath()
        
        return self.init(cgPath: path)
    }
    
}
