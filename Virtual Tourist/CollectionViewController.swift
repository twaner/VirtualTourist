//
//  CollectionViewController.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 5/17/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var touristCollectionView: UICollectionView!
    @IBOutlet weak var collectionButton: UIBarButtonItem!
    
    // MARK: - Props
    var mapState: MapState? = nil
    var annotation: MKPointAnnotation? = nil
    var region: MKCoordinateRegion? = nil
    var photoArrayTmp: [[String: AnyObject]] = []
    var mapAnnotation: Annotation!
    // NSFetchedResultsControllerDelegate with collection view
    var selectedIndexPaths = [NSIndexPath]()
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    var insertedIndexPaths: [NSIndexPath]!
    var counter = 0
    var deletedCounter = 0
    var downloaded = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // perform fetch
        fetchedResultsController.performFetch(nil)
        
        // Set delegates
        fetchedResultsController.delegate = self
        self.touristCollectionView.delegate = self
        self.touristCollectionView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionButton.enabled = false
        if self.mapAnnotation.photos.isEmpty {
            self.populate()
        } else {
            self.collectionButton.enabled = true
        }
        self.setMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBActions
    
    @IBAction func collectionButtonTapped(sender: UIBarButtonItem) {
        // Delete all photos
        self.deleteAllPhotos()
        // Get new photos
        self.populate()
    }
    
    // MARK: - Helper methods
    
    ///
    ///Uses the TouristClient in order to retrieve an array of dictionaries that is used to populate
    ///
    func getPhotosForLocation() {
        
        TouristClient.sharedInstance().flickrPhotosSearch(self.annotation!, completionHandler: { (success, result, error) -> Void in
            
            if let error = error {
                println("ERROR \(error)")
            } else {
                if let photos = result as? [[String:AnyObject]] {
                    println(result)
                    self.photoArrayTmp = photos
                    if self.photoArrayTmp.count > 0 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.touristCollectionView.reloadData()
                        })
                    }
                }
            }
        })
    }
    
    func populate() {
        println("POPULATE COUNT \(self.mapAnnotation.photos.count)")
        if self.mapAnnotation.photos.isEmpty {
            // Call Api
            TouristClient.sharedInstance().flickrPhotosSearch(self.annotation!, completionHandler: { (success, result, error) -> Void in

                if let error = error {
                    println("flickrPhotoSearch error: \(error)")
                } else {
                    if let photosDictionaries = result as? [[String: AnyObject]] {
                        var photos = photosDictionaries.map() {
                            (dictionary: [String: AnyObject]) -> Photo in
                            let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                            photo.pin = self.mapAnnotation
                            self.downloaded++
                            println("DOWNLOADED \(self.downloaded)")
                            return photo
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.counter++
                            println("async block - \(self.counter)")
                            self.collectionButton.enabled = true
                            self.touristCollectionView.reloadData()
                        })
                        self.saveContext()
                    } else {
                        let error = NSError(domain: "Movie for Person Parsing. Cant find cast in \(result)", code: 0, userInfo: nil)
                        println(error)
                    }
                }
            })
        } else {
            println("populate final else")
            self.collectionButton.enabled = true
        }
    }
    
    // This might not be need/clean up and jsut drop the pin
    func setMap() {
        
        if let mapState = self.mapState {
                self.mapView.setRegion(self.mapState!.region!, animated: true)
        } else {
            println("Could not set the region")
        }
        
        let location = CLLocationCoordinate2D(latitude: Double(self.mapAnnotation.latitude), longitude: Double(self.mapAnnotation.longitude))
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = self.mapAnnotation.title
        annotation.subtitle = self.mapAnnotation.subtitle
        self.annotation = annotation
        
        self.mapView.addAnnotation(self.annotation!)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TouristCollectionViewCell
        
        if let index = find(selectedIndexPaths, indexPath) {
            selectedIndexPaths.removeAtIndex(index)
        } else {
            selectedIndexPaths.append(indexPath)
        }
        
        self.deleteSelectedPhoto()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        println("number of cells \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! TouristCollectionViewCell
        cell.activityIndicator.hidden = false
        cell.activityIndicator.startAnimating()
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        cell.cellImage.image = UIImage(named: "Blank52")
        configureCell(cell, photo: photo)
//        counter += 1
//        println("collectionView cellForItemAtIndexPath: \(counter)")
        
        return cell
    }
    
    // MARK: - Cell Helper methods
    
    ///
    ///Configures the TouristCollectionViewCell. Sets a placeholder image; checks to see if a photo exists; downloads and sets image.
    ///
    ///:param: cell TouristCollectionViewCell to be updated.
    ///:param: photo Photo to display in the cell.
    func configureCell(cell: TouristCollectionViewCell, photo: Photo) {
        var photoImage = UIImage(named: "Blank52")
        cell.cellImage.image = nil
        if photo.imagePath == nil || photo.imagePath == "" {
            photoImage = UIImage(named: "Blank52")
        } else {
            let task = TouristClient.sharedInstance().taskForCreatingImage(photo.imagePath!) { (imageData, error) -> Void in
                if let error = error {
                    println("Poster download error: \(error.localizedDescription)")
                }
                if let data = imageData {
                    let image = UIImage(data: data)
                    photo.photoImage = image
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.hidden = true
                        cell.cellImage.image = image
                    })
                }
            }
            cell.taskToCancelIfCellIsReused = task
        }
        cell.cellImage.image = photoImage!
    }

    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.insertedIndexPaths = [NSIndexPath]()
        self.deletedIndexPaths = [NSIndexPath]()
        self.updatedIndexPaths = [NSIndexPath]()
        println("controllerWillChangeContent")
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            case .Insert:
                println("Insert called")
                self.insertedIndexPaths.append(newIndexPath!)
                break
            case .Delete:
                println("delete called")
                self.deletedIndexPaths.append(indexPath!)
                break
            case .Update:
                println("Update called")
                self.updatedIndexPaths.append(indexPath!)
                break
            case .Move:
                println("Move is not allowed in this app")
            default:
                break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println("controllerDidChangeContent")
        
        self.touristCollectionView.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                self.touristCollectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.touristCollectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.touristCollectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
        }, completion: nil)
    }

    // MARK: - Core Data helpers
    
    ///
    /// Deletes all photo objects related to Annotation
    ///
    func deleteAllPhotos() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            deletedCounter++
            println("DELETE ALL \(deletedCounter)")
            sharedContext.deleteObject(photo)
        }
        self.saveContext()
    }
    
    ///
    /// Deletes a photo object related to Annotation
    ///
    func deleteSelectedPhoto() {
        var photoToDelete = [Photo]()
        
        for indexPath in self.selectedIndexPaths {
            photoToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photoToDelete {
            sharedContext.deleteObject(photo)
            self.saveContext()
        }
        self.selectedIndexPaths = [NSIndexPath]()
    }
    
    ///
    /// Updates text on collection Button
    ///
    func updateCollectionButton() {
        if self.selectedIndexPaths.count > 0 {
            self.collectionButton.title = "New Collection"
        } else {
            self.collectionButton.title = "Clear All"
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.mapAnnotation)
        fetchRequest.sortDescriptors = []
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    ///
    /// Calls the saveContext() method on the sharedInstance
    ///
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}
