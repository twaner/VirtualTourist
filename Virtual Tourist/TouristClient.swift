//
//  TouristClient.swift
//  
//
//  Created by Taiowa Waner on 5/27/15.
//
//

import Foundation

class TouristClient {
    
    var session: NSURLSession
    
    // MARK: - Flickr Auth values
    var key: String? = nil
    var secretKey: String? = nil
    
    init() {
        self.session = NSURLSession.sharedSession()
    }
    
    // MARK: - Flickr Helpers
    
    func flickrGetHelper(method: String, parameters: [String: AnyObject], completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {

        let urlString = TouristClient.Constants.FlickrURL +  TouristClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {
            (data, response, downloadError) in
            
            if let error = downloadError {
                let newError = TouristClient.errorForData(data, response: response, error: error)
                println("flickrGetHelper \(newError)")
            } else {
               TouristClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[TouristClient.JSONResponseKeys.Message] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    class func sharedInstance() -> TouristClient {
        struct Singleton {
            static var sharedInstance = TouristClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}