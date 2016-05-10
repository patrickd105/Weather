//
//  ViewController.swift
//  Weather
//
//  Created by Patrick Dunshee on 5/8/16.
//  Copyright © 2016 Patrick Dunshee. All rights reserved.
//

import UIKit
import CoreData

private let zipCellIdentifier = "ZipCell"
private let detailsSegueIdentifier = "ZipDetailsSegue"

class ZipTableViewController: UITableViewController {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchedResultsController: NSFetchedResultsController! = nil
    var selectedZip: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Zip Codes"
        
        let nib = UINib(nibName: zipCellIdentifier, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: zipCellIdentifier)
        
        configureFetchedResultsController()
        addDefaultZipCodesIfFirstLaunch()
        performFetch()
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    func addDefaultZipCodesIfFirstLaunch() {
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
        if !launchedBefore  {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
            
            let defaultZipCodes = [78751, 85718, 75201]
            
            let entityDescription = NSEntityDescription.entityForName("ZipCode", inManagedObjectContext: managedObjectContext)
            for zipInteger in defaultZipCodes {
                let zipCode = NSManagedObject.init(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
                if let zipCode = zipCode as? ZipCode {
                    zipCode.zipCode = "\(zipInteger)"
                }
            }
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == detailsSegueIdentifier {
            if let zipDetailsTableViewController = segue.destinationViewController as? ZipDetailsTableViewController {
                if let selectedZip = selectedZip {
                    zipDetailsTableViewController.selectedZip = selectedZip
                }
            }
        }
    }
}

// MARK: UITableViewDataSource
extension ZipTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(zipCellIdentifier, forIndexPath: indexPath) as! ZipCell
        let zipCode = fetchedResultsController.objectAtIndexPath(indexPath)
        
        if let zipCode = zipCode as? ZipCode {
            cell.configureForZipCode(zipCode)
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension ZipTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let zipCode = fetchedResultsController.objectAtIndexPath(indexPath)
        
        if let zipCode = zipCode as? ZipCode {
            if let code = zipCode.zipCode {
                selectedZip = code
                performSegueWithIdentifier(detailsSegueIdentifier, sender: self)
            }
        }
    }
}

// MARK: Core Data Helpers
extension ZipTableViewController {
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Perform fetch error: \(error), \(error.userInfo)")
        }
    }
    
    func configureFetchedResultsController() {
        let fetchRequest = zipCodeFetchRequest()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
    }
    
    func zipCodeFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "ZipCode")
        let sortDescriptor = NSSortDescriptor(key: "zipCode", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
}

// MARK: FetchedResultsControllerDelegate
extension ZipTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ZipCell
                let zipCode = fetchedResultsController.objectAtIndexPath(indexPath)
                
                if let zipCode = zipCode as? ZipCode {
                    cell.configureForZipCode(zipCode)
                }
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
}