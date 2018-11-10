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
    
    func textToImage(drawText name: NSString, rating: NSString, price_level: NSInteger?, /*img_url: String,*/ size: CGFloat) -> UIImage {
        //print(rating)
        //text attributes
        let font=UIFont(name: "Courier-Bold", size: size)!
        let text_style=NSMutableParagraphStyle()
        text_style.alignment=NSTextAlignment.center
        let text_color=UIColor(white: CGFloat(0), alpha: CGFloat(1))
        let attributes=[NSAttributedString.Key.font:font, NSAttributedString.Key.paragraphStyle:text_style, NSAttributedString.Key.foregroundColor:text_color]
        
        
        let size = CGSize(width: CGFloat(size * CGFloat(name.length)*0.75), height: font.lineHeight*4)
        //draw image first
        UIGraphicsBeginImageContext(size)
//        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
//        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        //ctx.saveGState()
        //ctx.setAlpha(CGFloat(0.5))
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
        
        var rating_output : NSString = "Rating: "+(rating as String)+" Price: " as NSString
        if price_level != 0 {
            for _ in 1...price_level! {
                rating_output = (rating_output as String) + "$" as NSString
            }
        }
        else {
            rating_output = (rating_output as String) + "Unavailable" as NSString
        }
        
        let text_rect_rate=CGRect(x: 0, y: (size.height-text_h)*3/4, width: size.width, height: text_h)
        rating_output.draw(in: text_rect_rate.integral, withAttributes: attributes)
        
//        let url = URL(string: img_url)!
//        if let filePath = Bundle.main.path(forResource: "imageName", ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
//            imageView.contentMode = .scaleAspectFit
//            imageView.image = image
//        }
//        getDataFromUrl(url: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//
//            let ciImage = CIImage(image: UIImage(data: data)!)
//
//            let context = CIContext(options: nil)
//            let cgImage : CGImage = context.createCGImage(inputImage, fromRect: inputImage.extent())
//
//            ctx.draw(CGImage, in: <#T##CGRect#>)
//        }
        
        let result=UIGraphicsGetImageFromCurrentImageContext()
        
        return result!
    }
    
    @available(iOS 11.0, *)
    func updateList (new_list : Array<[String : Any]>, view_controller: ViewController) {
        for place in new_list {
            var existed = false
            for original_item in self.list {
                if place["name"] as? String == original_item["name"] as? String{
                    existed = true
                    break
                }
            }
            if existed {
                continue
            }
            
            let placeLoc = (place["geometry"] as! [String:Any])["location"] as! [String: Any]
            
            var urlStr = "https://maps.googleapis.com/maps/api/elevation/json?key=AIzaSyB4yFebE_T_LrJfWK1EMgUbPvwxgwbxKto&locations="
            let lat = placeLoc["lat"] as! Double
            let lng = placeLoc["lng"] as! Double
            urlStr += String(lat) + ","
            urlStr += String(lng)
            
            //print(urlStr);
            
            let dlat = view_controller.currLocation.latitude - lat
            let dlng  = view_controller.currLocation.longitude - lng
            let distance  = log(sqrt(dlat*dlat  + dlng*dlng)*10000)*10-5
            //print(distance)
            
            Alamofire.request(urlStr).responseJSON { response in
                let jsonObj = try! JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: Any]
                //print(jsonObj)
                var elevation = 0.0
                for result in (jsonObj["results"] as! Array<[String : Any]>) {
                    var temp = [String:Any]()
                    
                    let placeId = place["place_id"] as! String
                    //print(placeId)
                    urlStr = "https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyCGfzMhTP1pfK6czstJJyrhASbpBGBxSZE&placeid=" + placeId
                    Alamofire.request(urlStr).responseJSON { response in
                        if let jsonObj = try! JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                            //jsonObj
                            let  rating = (jsonObj["result"] as! [String:Any])["rating"] as! NSNumber
                            //                            temp["rating"] = rating
                            
                            
                            elevation = result["elevation"] as! Double
                            let pinCoordinate = CLLocationCoordinate2D(latitude: placeLoc["lat"] as! Double, longitude: placeLoc["lng"] as! Double)
                            let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: elevation)
                            var priceLevel : NSInteger
                            if ((place["price_level"] as? NSInteger) != nil) {
                                priceLevel = place["price_level"] as! NSInteger
                            }
                            else{
                                priceLevel = 0
                            }
                            let pinImage = self.textToImage(drawText: place["name"] as! NSString, rating: "\(rating)" as NSString, price_level: priceLevel, size: CGFloat(distance))
                            
                            let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
                            
                            temp["name"] = place["name"]
                            temp["node"] = pinLocationNode
                            self.tobeAdded.append(temp)
                        }
                    }
                }
            }
        }
    }
    
    func getAddList () -> Array<[String : Any]> {
        let temp = self.tobeAdded
        list = list + temp
        self.tobeAdded = []
        
        return temp
    }
    
    //    func getRemoveList () -> Array<[String : Any]> {
    ////        let temp = self.tobeRemoved
    ////        list = list - temp
    ////        self.tobeRemoved = []
    ////
    ////        return temp
    //
    //        // TODO
    //    }
    
    
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
