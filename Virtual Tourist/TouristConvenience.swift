//
//  TouristConvenience.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 5/27/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension TouristClient {
    
    // MARK: - Get
    
    ///
    ///Helper method for using the flickr.photos.search api. Uses a placemark to determine what location to search.
    ///
    ///:param: placemark MKPlacemark to use for location
    ///:param: completionHandler completionHandler for method.
    func flickrPhotosSearch(annotation: MKPointAnnotation, completionHandler: (success: Bool, result: AnyObject?, error: NSError?) -> Void) {
        
        let pageNumber = arc4random_uniform(20) + 1//arc4random_uniform(9999)
        let pageStr = "\(pageNumber)"
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        
        var parameters: [String: AnyObject] = [
            ParamaterKeys.Method: Constants.GetPhotos,
            ParamaterKeys.ApiKey: Constants.FlickrApiKey,
            ParamaterKeys.Latitude: latitude,
            ParamaterKeys.Longitude: longitude,
            ParamaterKeys.Radius: "4",
            ParamaterKeys.Radius_Units: "1m",
            ParamaterKeys.Extras: "url_m",
            ParamaterKeys.DataFormat: "json",
            ParamaterKeys.No_JSON_Callback: "1",
            ParamaterKeys.PerPage: "100",
            ParamaterKeys.Page: pageStr
        ]
        
        flickrGetHelper(Constants.GetPhotos, parameters: parameters) { (result, error) -> Void in
            if let error = error {
                completionHandler(success: false, result: nil, error: error)
            } else {
                if let photoDictionary = result!.valueForKey(JSONResponseKeys.Photos) as? NSDictionary {
                    if let photoArray = photoDictionary.valueForKey(JSONResponseKeys.Photo) as? [[String: AnyObject]] {
                        completionHandler(success: true, result: photoArray, error: nil)
                    }
                }
            }
        }
    }
    
    func taskForCreatingImage(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        let url = NSURL(string: filePath)
        
        let request = NSURLRequest(URL: NSURL(string: filePath)!)
        let task = session.dataTaskWithRequest(request) {
            (data, response, downloadError) in
            if let error = downloadError {
                let newError = TouristClient.errorForData(data, response: response, error: error)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        task.resume()
        return task
    }
}