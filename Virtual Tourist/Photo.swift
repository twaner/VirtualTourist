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
    
    override func prepareForDeletion() {
        TouristClient.DocumentAccessor.imageAccessor.deleteImage(self.imagePath!)
    }
    
    var photoImage: UIImage? {
        get {
            return TouristClient.DocumentAccessor.imageAccessor.imageWithIdentifier(imagePath)
        }
        set {
            TouristClient.DocumentAccessor.imageAccessor.storeImage(newValue, withIdentifier: imagePath!)
        }
    }
}