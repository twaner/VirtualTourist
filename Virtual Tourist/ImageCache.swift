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
    var fileManager = NSFileManager.defaultManager()
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
        
        // Test if saved
        
        var loaded = UIImage(contentsOfFile: path)
        if loaded == nil {
            println("IMAGE NOT SAVED")
        } else {
            println("IMAGE SAVED")
        }
        
        var error: NSError?
        let fileList = fileManager.contentsOfDirectoryAtPath("/", error: &error) as! [String]
        println("FILELIST COUNT \(fileList.count)")
        //        for i in fileList {
        //            println("Filelist \(i)")
        //        }
        #if arch(i386) || arch(x86_64)
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
            NSLog("Document Path: %@", documentsPath)
        #endif
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let docDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let url = docDirectoryURL.URLByAppendingPathComponent(identifier)
        return url.path!
    }
}
