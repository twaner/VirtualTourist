//
//  TravelLocationMapViewController.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 5/17/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationMapViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Props
    
    // These are to handle new pins that are dropped
    var location: CLLocation? = nil
    var locationPlacemark: MKPlacemark? = nil
    var mapState: MapState? = nil
    var annotation: MKPointAnnotation? = nil
    var tapCount = 0
    var region: MKCoordinateRegion? = nil
    var annotations = [Annotation]()
    var anno: Annotation? = nil
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.navigationItem.title = "Map"
        var uilpgr = UILongPressGestureRecognizer(target: self, action: "tap:")
        uilpgr.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(uilpgr)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: get map state from core data if it exists
        self.annotations = self.fetchAllPins()
        println("PIN COUNT: \(self.annotations.count)")
        
        if self.annotations.count > 0 {
            var pins = placeAnnotations()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.mapView.showAnnotations(pins, animated: true)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func placeAnnotations() -> [MKPointAnnotation] {
        var pinArray = [MKPointAnnotation]()
        for i in self.annotations {
            pinArray.append(i.annotation)
        }
        return pinArray
    }
    
    // MARK: - Actions
    
    func tap(gestureRecognizer: UIGestureRecognizer) {
        println("Tapped \(tapCount)")
        tapCount += 1
        var touchPoint = gestureRecognizer.locationInView(self.mapView)
        
        if .Began == gestureRecognizer.state {
            var newCoordinate: CLLocationCoordinate2D = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            let coordinates: [CLLocationDegrees] = [newCoordinate.latitude, newCoordinate.longitude]
            
            var newLocation: CLLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            let region = self.mapView.region
            println("\(region.span.latitudeDelta) \(region.span.longitudeDelta)")
            self.mapState = MapState(region: region)
            self.getLocations(newLocation)
            self.region = region
        }
    }
    
    ///
    ///Uses a CLLocation to reverse Geocode a location and return an MKPlacemark
    func getLocations(location: CLLocation) {
        var geoCoder: CLGeocoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if let error = error {
                println("getLocation error \(error)")
            } else if placemarks.count > 0 {
                let placemark = placemarks.first as! CLPlacemark
                self.locationPlacemark = MKPlacemark(placemark: placemark)
                self.updateMap(self.locationPlacemark!)
            } else{
                println("getLocations - no placemarks returned")
            }
        })
    }
    
    func updateMap(placemark: MKPlacemark) {
        let latitude = placemark.coordinate.latitude
        let longitude = placemark.coordinate.longitude
        let location = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
        let annotation = MKPointAnnotation()
        self.annotation = annotation
        annotation.coordinate = location
        annotation.title = placemark.locality
        annotation.subtitle = placemark.administrativeArea
        //TODO: Put on main thread
        self.mapView.addAnnotation(annotation)
        self.mapView.showAnnotations([annotation], animated: true)
        
        // Save data
        var mapAnnotation = Annotation(latitude: latitude, longitude: longitude, title: annotation.title, subtitle: annotation.subtitle, context: self.sharedContext)
        self.saveContext()
    }

    
    // MARK: - MKMapViewDelegate
    
    func getCoordinates(address: String?) {
        self.displayActivityView(true)
        var geoCoder: CLGeocoder = CLGeocoder()

        // OLD CODE
        geoCoder.geocodeAddressString(address, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) -> Void in
            println("geoCoder")
            if let error = error {
                println("getCoordinates error \(error)")
                self.displayActivityView(false)
            } else {
                if (placemarks != nil && placemarks.count > 0) {
                    let result = placemarks[0] as! CLPlacemark
                    self.locationPlacemark = MKPlacemark(placemark: result)
                    self.displayActivityView(false)
                    println("geocodeAddressString -> \(self.locationPlacemark)")
//                    self.performSegueWithIdentifier("CollectionSegue", sender: self)
                } else {
                    println("Issue with placemark")
                    // TODO: Warning failed to post placemark
                    self.displayActivityView(false)
                }
            }
        })
    }
    
    func mapViewWillStartLoadingMap(mapView: MKMapView!) {
        // TODO: start spinner
//        println("mapViewWillStartLoadingMap")
        self.displayActivityView(true)
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        println("mapViewDidFinishLoadingMap")
        println("\(mapView.region.span.longitudeDelta) \(mapView.region.span.latitudeDelta)")
        self.displayActivityView(false)
    }

    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        // TODO: stop spinner
        println("mapViewDidFinishRenderingMap")
        self.displayActivityView(false)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if let annotation = annotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.InfoLight) as! UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        self.annotation = mapView.selectedAnnotations.first as? MKPointAnnotation
        
        let lat = NSNumber(double: (self.annotation?.coordinate.latitude)! as Double)
        let long = NSNumber(double: (self.annotation?.coordinate.longitude)! as Double)

        let predicate = NSPredicate(format: "latitude==%d", lat)
        let predicate1 = NSPredicate(format: "longitude==%d", long)
        let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [predicate, predicate1])
        
        self.anno = self.fetchPin(lat.doubleValue, long: long.doubleValue)
        
        self.performSegueWithIdentifier("CollectionSegue", sender: self)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("error: \(error)")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var userLocation: CLLocation = locations[0] as! CLLocation
        self.mapUpdater(userLocation, mapView: self.mapView)
        println("locationManager - \(userLocation)")
    }

    // MARK: - Helper methods
    
    ///
    /// Displays or hides an activity indicator.
    ///
    /// :param: on Turns activity indicator on or off.
    func displayActivityView(on: Bool) {
        if on {
            self.activityIndicator.startAnimating()
            self.activityIndicator.alpha = 1.0
        } else {
            self.activityIndicator.alpha = 0.0
            self.activityIndicator.stopAnimating()
        }
    }

    
    func mapUpdater(userLocation: CLLocation, mapView: MKMapView) {
        var latitude: CLLocationDegrees = userLocation.coordinate.latitude
        var longitude: CLLocationDegrees = userLocation.coordinate.longitude
        
        var latDetal: CLLocationDegrees = 0.01
        var longDetal: CLLocationDegrees = 0.01
        
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDetal, longDetal)
        println("SPAN \(span)")
        
        var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        var region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! CollectionViewController
        vc.mapState = self.mapState
        vc.annotation = self.annotation
        vc.mapAnnotation = self.anno
    }
    
    // MARK: - Core Data Convenience
    
    func fetchPin(lat: Double, long: Double) -> Annotation? {
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Annotation")

        var lat = "\(lat)"
        var long = "\(long)"
        
        let predicate = NSPredicate(format: "latitude == %@", lat)
        let predicate1 = NSPredicate(format: "longitude == %@", long)
        let compoundPredicate = NSCompoundPredicate.andPredicateWithSubpredicates([predicate, predicate1])
        
        fetchRequest.predicate = compoundPredicate
        fetchRequest.sortDescriptors = []
        let pin = self.sharedContext.executeFetchRequest(fetchRequest, error: error)?.first as! Annotation
        if error != nil {
            println("Error getting pin \(error)")
            return nil
        }
        return pin
    }
    
    func fetchAllPins() -> [Annotation] {
        let error: NSErrorPointer = nil
        // Create request
        let fetchRequest = NSFetchRequest(entityName: "Annotation")
        
        // execute
        let results = self.sharedContext.executeFetchRequest(fetchRequest, error: error)
        
        if error != nil {
            print("Error in fetchAllPins() \(error)")
        }
        return results as! [Annotation]
    }
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}
