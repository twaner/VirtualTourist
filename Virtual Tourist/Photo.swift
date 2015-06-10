//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 5/26/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)

class Photo: NSManagedObject {
    
    struct Keys {
        static let Url = "url_m"
        static let Title = "title"
    }
    
    //TODO: The image might ned to be stored as NSData then the data converted to image in code.
    @NSManaged var image: UIImage?
    @NSManaged var title: String?
    @NSManaged var imagePath: String?
    @NSManaged var pin: Annotation?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.imagePath = dictionary[Keys.Url] as? String
        self.title = dictionary[Keys.Title] as? String
    }
    
    
    var photoImage: UIImage? {
        get {
            return TouristClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        set {
            TouristClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath!)
        }
    }
}
//pinkstone.co.uk/how-to-save-a-uiimage-in-core-data-and-retrieve-it/