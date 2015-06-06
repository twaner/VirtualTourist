//
//  Annotation.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 5/26/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@objc(Annotation)

class Annotation: NSManagedObject {
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var title: String
    @NSManaged var subtitle: String
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude: Double, longitude: Double, title: String, subtitle: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Annotation", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.subtitle = subtitle
    }
    
     var annotation: MKPointAnnotation {
        get {
            let annotation = MKPointAnnotation()
            let location = CLLocationCoordinate2DMake(latitude, longitude)
            annotation.coordinate = location
            annotation.title = self.title
            annotation.subtitle = self.subtitle
            return annotation
        }
    }
}