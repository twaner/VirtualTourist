//
//  MapState.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 5/26/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import CoreData
import MapKit

//@objc(Movie)

///
/// Sets the intial state of the map by saving the most recent region value.
class MapState {
    
    var region: MKCoordinateRegion? = nil
    
    /*
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
    regionRadius * 2.0, regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
    }
    */

    init(region: MKCoordinateRegion) {
        self.region = region
    }
}
