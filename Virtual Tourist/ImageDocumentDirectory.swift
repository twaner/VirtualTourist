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
            return UIImage(data: data)
        }
        return nil
    }
    
    /**
    Deletes an image from the document directory if the file exists at the path.
    
    :param: identifier filename to be turned into the path.
    */
    func deleteImage(identifier: String){
        var error: NSError?
        if fileManager.fileExistsAtPath(pathForIdentifier(identifier)) {
            fileManager.removeItemAtPath(pathForIdentifier(identifier), error: &error)
        }
    }
    
    /**
    Stores an image from the document directory if the image exists or else it will remove the item from the doc directory.
    
    :param: image Image the to be stored.
    :param: identifier String that will be used to create the file path.
    */
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        if image == nil {
            fileManager.removeItemAtPath(path, error: nil)
            return
        }
        let data = UIImagePNGRepresentation(image!)
        data.writeToFile(path, atomically: true)
    }
    
    /**
    Creates a path from the file's name that it willbe stored at.
    
    :param: identifier filename to be turned into the path.
    */
    func pathForIdentifier(identifier: String) -> String {
        let docDirectoryURL: NSURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let url = docDirectoryURL.URLByAppendingPathComponent(identifier.lastPathComponent)

        return url.path!
    }
}
