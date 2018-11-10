//
//  PlacesList.swift
//  ARKit+CoreLocation
//
//  Created by 李渊琛 on 12/2/17.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import MapKit
import CocoaLumberjack
import Alamofire

class PlacesList {
    var list : Array<[String : Any]> = []
    var tobeAdded : Array<[String : Any]> = []
    var tobeRemoved : Array<[String : Any]> = []
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func getAddList () -> Array<[String : Any]> {
        let temp = self.tobeAdded
        list = list + temp
        self.tobeAdded = []
        
        return temp
    }
    
}

extension UIImage {
    static func emptyImageWithSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}


func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
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
