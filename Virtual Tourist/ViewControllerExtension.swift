//
//  ViewControllerExtension.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 6/25/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit

/**
Extension class for UIViewController. This class contains helper functions for the activity indicator and alert controller.

*/
extension UIViewController {
    
    ///
    /// Displays or hides an activity indicator.
    ///
    /// :param: on Turns activity indicator on or off.
    func displayActivityViewIndicator(on: Bool, activityIndicator: UIActivityIndicatorView) {
        if on {
            activityIndicator.startAnimating()
            activityIndicator.alpha = 1.0
        } else {
            activityIndicator.alpha = 0.0
            activityIndicator.stopAnimating()
        }
    }
    
    ///
    /// Displays an UIAlertController with an action message option
    ///
    /// :param: title of Alert
    /// :param: message message of alert
    /// :param: action title for the action button.
    func displayUIAlertController(title:String, message:String, action: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: action, style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///
    ///Displays an UIAlertController with an OK message for action.
    ///:param: title of Alert
    ///:param: error message of alert
    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
