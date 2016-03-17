//
//  ViewController.swift
//  Prototype
//
//  Created by Oleg Gnashuk on 1/19/16.
//  Copyright © 2016 Oleg Gnashuk. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, SendWaypointBackDelegate {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Standard
            mapView.delegate = self
            mapView.showsUserLocation = true
        }
    }
    
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    var currentCoordinates: CLLocationCoordinate2D!
    
    var manager: CLLocationManager!
    
    var waypoints = [Waypoint]()
    var managedObjects = [NSManagedObject]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Waypoint")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            managedObjects = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        print("fetched requests \(managedObjects.count)")
        for managedObject in managedObjects {
            var waypoint = Waypoint()
            waypoint.title = managedObject.valueForKey("title") as? String
            waypoint.subtitle = managedObject.valueForKey("text") as? String
            waypoint.imageURL = managedObject.valueForKey("imageURL") as? String
            waypoint.latitude = managedObject.valueForKey("latitude") as? Double
            waypoint.longitude = managedObject.valueForKey("longitude") as? Double
            print("waypoint title \(waypoint.title)")
            print("waypoint text \(waypoint.subtitle)")
            print("waypoint image URL \(waypoint.imageURL)")
            print("waypoint coordinates \(waypoint.latitude) \(waypoint.longitude)")
            waypoints.append(waypoint)
        }
        
        clearWaypoints()
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if #available(iOS 8.0, *) {
            manager.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        manager.startUpdatingLocation()
    }
    
    private func clearWaypoints() {
        if mapView?.annotations != nil { mapView.removeAnnotations(mapView.annotations as [MKAnnotation]) }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let waypoint = view.annotation as? Waypoint {
            if let url = waypoint.imageURL {
                if view.leftCalloutAccessoryView == nil {
                    view.leftCalloutAccessoryView = UIButton(frame: CGRect(x: 0, y: 0, width: 59, height: 59))
                }
                if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton {
                    let imageURL = documentsURL.URLByAppendingPathComponent(waypoint.imageURL).path!
                    if let image = UIImage(contentsOfFile: imageURL) {
                        thumbnailImageButton.setImage(image, forState: .Normal)
                    }
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("waypoint")
        
        view?.leftCalloutAccessoryView = nil
        view?.rightCalloutAccessoryView = nil
        if let waypoint = annotation as? Waypoint {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "waypoint")
            view?.canShowCallout = true
            if waypoint.imageURL != nil {
                view?.leftCalloutAccessoryView = UIButton(frame: CGRect(x: 0, y: 0, width: 59, height: 59))
                view?.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIButton
            }
        } else {
            view?.annotation = annotation
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if  (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegueWithIdentifier("Show Details", sender: view)
        } else if let waypoint = view.annotation as? Waypoint {
            if waypoint.imageURL != nil {
                performSegueWithIdentifier("Waypoint Image", sender: view)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentCoordinates = locations[0].coordinate
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "New Note" {
            if let navigationViewController = segue.destinationViewController as? UINavigationController {
                if let destinationViewController = navigationViewController.topViewController as? NewNoteViewController {
                    var waypoint = Waypoint()
                    if currentCoordinates != nil {
                        waypoint.coordinate = currentCoordinates
                        destinationViewController.newWaypoint = waypoint
                        destinationViewController.delegate = self
                    } else {
                        if #available(iOS 8.0, *) {
                            let alertTitle = NSLocalizedString("Warning", comment: "Alert message title in global map.")
                            let alertMessage = NSLocalizedString("Location tracking is not available.", comment: "Alert message text in global map.")
                            let alertDismissButton = NSLocalizedString("Dobrze", comment: "Alert dismiss button text.")
                            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: alertDismissButton, style: UIAlertActionStyle.Default, handler: nil))
                            presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        } else if segue.identifier == "Waypoint Image" {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? Waypoint  {
                if #available(iOS 8.0, *) {
                    if let tvc = segue.destinationViewController as? WaypointViewController {
                        if let ppc = tvc.popoverPresentationController {
                            ppc.delegate = self
                        }
                        let imageURL = documentsURL.URLByAppendingPathComponent(waypoint.imageURL).path!
                        if let image = UIImage(contentsOfFile: imageURL) {
                            tvc.image = image
                            var parentViewSize = self.view.frame.size
                            if parentViewSize.width > parentViewSize.height {
                                parentViewSize.width = parentViewSize.height
                            } else {
                                parentViewSize.height = parentViewSize.width
                            }
                            tvc.preferredContentSize = parentViewSize
                        }
                    }
                }
                
            }
        } else if segue.identifier == "Show Details" {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? Waypoint  {
                var destination = segue.destinationViewController
                if let navCon = destination as? UINavigationController {
                    destination = navCon.visibleViewController!
                }
                if let dvc = destination as? ViewController {
                    let imageURL = documentsURL.URLByAppendingPathComponent(waypoint.imageURL).path!
                    if let image = UIImage(contentsOfFile: imageURL) {
                        dvc.image = image
                        dvc.waypoint = waypoint
                    }
                }
                
            }
        }
    }
    
    func sendWaypointBack(waypoint: Waypoint) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Waypoint", inManagedObjectContext: managedContext)
        let managedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        managedObject.setValue(waypoint.title, forKey: "title")
        managedObject.setValue(waypoint.subtitle, forKey: "text")
        managedObject.setValue(waypoint.imageURL, forKey: "imageURL")
        managedObject.setValue(waypoint.latitude, forKey: "latitude")
        managedObject.setValue(waypoint.longitude, forKey: "longitude")
        
        do {
            try managedContext.save()
            managedObjects.append(managedObject)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    @available(iOS 8.0, *)
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}

extension MKAnnotationView {
    func popoverSourceRectForCoordinatePoint(coordinatePoint: CGPoint) -> CGRect {
        var popoverSourceRectCenter = coordinatePoint
        popoverSourceRectCenter.x -= frame.width / 2 - centerOffset.x - calloutOffset.x
        popoverSourceRectCenter.y -= frame.height / 2 - centerOffset.y - calloutOffset.y
        return CGRect(origin: popoverSourceRectCenter, size: frame.size)
    }
}

