//
//  TouristConstants.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 5/27/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import Foundation

extension TouristClient {
    
    // MARK: - Constants
    
    struct Constants {
        
        // MARK: - API Keys
        
        static let FlickrApiKey = "cc4e0bbebaac27eb3fe7f90fe3003e8a"
        static let FlickrSecret = "d1481fe4e4f0986c"
        
        // MARK: - URLs
        
        static let FlickrURL = "https://api.flickr.com/services/rest/"
        
        // MARK: - Methods
        
        static let GetPhotos = "flickr.photos.search"
    }
    
    struct ParamaterKeys {
        
        // MARK: - Flickr Param Keys
        static let Method = "method"
        static let ApiKey = "api_key"
        static let Extras = "extras" // returns a url in response
        static let DataFormat = "format"
        static let No_JSON_Callback = "nojsoncallback"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Radius = "radius"
        static let Radius_Units = "radius_units"
    }
    
    struct JSONResponseKeys {
        
        // MARK: - Flickr
        static let Photos = "photos"
        static let Photo = "photo"
        static let URL_M = "url_m"
        static let Title = "title"
        static let Message = "message"
        static let Stat = "stat"
    }
}

//lat 41.8831922 long -87.6431329
//        -122.42307100000001,37.773779,-122.411071,37.815779
//        method=flickr.photos.search&api_key=e5550815eb1a52b179afb30b894b21d2&accuracy=3&lat=41.8831922&lon=-87.6431329&radius=1&radius_units=mi&extras=url_m&format=json&nojsoncallback=1&auth_token=72157653159417620-cddff9ca3c9f42a8&api_sig=62a05877450a04daf0b1207dfb599aca
//https://www.flickr.com/services/api/explore/flickr.photos.search
