//
//  ListViewController.swift
//  Application
//
//  Created by Oleg Gnashuk on 2/20/16.
//  Copyright © 2016 Oleg Gnashuk. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {
    
    var waypoints = [Waypoint]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        waypoints = [Waypoint]()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Waypoint")
        
        var managedObjects = [NSManagedObject]()
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            managedObjects = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        for object in managedObjects {
            let waypoint = Waypoint()
            waypoint.title = object.valueForKey("title") as? String
            waypoint.subtitle = object.valueForKey("text") as? String
            waypoint.imageURL = object.valueForKey("imageURL") as? String
            waypoint.latitude = object.valueForKey("latitude") as? Double
            waypoint.longitude = object.valueForKey("longitude") as? Double
            
            waypoints.append(waypoint)
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return waypoints.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Note", forIndexPath: indexPath) as! TableViewCell
        
        cell.waypoint = waypoints[indexPath.section]
        
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Details" {
            if let destination = segue.destinationViewController as? ViewController {
                if let index = self.tableView.indexPathForSelectedRow {
                    let tableCell = tableView.cellForRowAtIndexPath(index) as? TableViewCell
                    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                    let imageURL = documentsURL.URLByAppendingPathComponent(tableCell!.waypoint!.imageURL).path!
                    if let imageData = NSData(contentsOfURL: NSURL(fileURLWithPath: imageURL)) {
                        destination.image = UIImage(data: imageData)
                    }
                    destination.waypoint = tableCell!.waypoint
                }
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
