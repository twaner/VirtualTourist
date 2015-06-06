//
//  ImageCache.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 5/31/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache()
    
    // MARK: - Get images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        if identifier == nil || identifier != "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        var data: NSData?
        
        // Memory
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Local
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        // if nil, remove from cache
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
            return
        }
        // keep in memory
        inMemoryCache.setObject(image!, forKey: path)
        // doc directory
        let data = UIImagePNGRepresentation(image!)
        data.writeToFile(path, atomically: true)
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let docDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let url = docDirectoryURL.URLByAppendingPathComponent(identifier)
        return url.path!
    }
}
