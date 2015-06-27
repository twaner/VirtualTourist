//
//  ImageDocumentDirectory.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 6/25/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit

class ImageDocumentDirectory {
    
    private var fileManager = NSFileManager.defaultManager()
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        if identifier == nil || identifier != "" {
            return nil
        }
        let path = pathForIdentifier(identifier!)
        var data: NSData?
        if let data = NSData(contentsOfFile: path) {
            println("IN imageWithIdentifier DATA \(data)")
            return UIImage(data: data)
        }
        return nil
    }
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        if image == nil {
            fileManager.removeItemAtPath(path, error: nil)
            return
        }
        let data = UIImagePNGRepresentation(image!)
        data.writeToFile(path, atomically: true)
        
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
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
            NSLog("Document Path: %@", documentsPath)
            let fileList2 = fileManager.contentsOfDirectoryAtPath(documentsPath, error: &error) as! [String]
            println("FILELIST COUNT2 \(fileList2.count)")
        #endif
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let docDirectoryURL: NSURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let url = docDirectoryURL.URLByAppendingPathComponent(identifier.lastPathComponent)

        return url.path!
    }
}
