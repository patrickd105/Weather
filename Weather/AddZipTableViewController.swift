//
//  AddZipTableViewController.swift
//  Weather
//
//  Created by Patrick Dunshee on 5/8/16.
//  Copyright © 2016 Patrick Dunshee. All rights reserved.
//

import Foundation
import UIKit
import CoreData

private let zipEntryCellIdentifier = "ZipEntryCell"

class AddZipTableViewController: UITableViewController {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let weatherManagerErrorHelper = WeatherManagerErrorHelper()
    var requestInProgress = false
    var weatherManager = WeatherManager()
    var weatherInfo: WeatherInfo?
    var currentFetcherError: WeatherFetcherError? = .InvalidInput
    weak var zipEntryTextField: UITextField?
    
    override func viewDidLoad() {
        let zipEntryNib = UINib(nibName: zipEntryCellIdentifier, bundle: nil)
        tableView.registerNib(zipEntryNib, forCellReuseIdentifier: zipEntryCellIdentifier)
        let zipDetailsNib = UINib(nibName: zipDetailsCellIdentifier, bundle: nil)
        tableView.registerNib(zipDetailsNib, forCellReuseIdentifier: zipDetailsCellIdentifier)
        
        title = "Add Zip Code"
    }
    
    func reloadNonInputRows() {
        let indexPaths = [NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)]
        tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    
    func addNewZipCodeIfNotAlreadySaved(newZipCode: String) {
        do {
            let fetchRequest = NSFetchRequest(entityName: "ZipCode")
            fetchRequest.predicate = NSPredicate(format: "zipCode == %@", newZipCode)
            
            let existingZipCodes = try managedObjectContext.executeFetchRequest(fetchRequest)
            
            if existingZipCodes.count < 1 && weatherManager.isZipCodeValid(newZipCode) {
                let entityDescription = NSEntityDescription.entityForName("ZipCode", inManagedObjectContext: managedObjectContext)
                let zipCode = NSManagedObject.init(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
                
                if let zipCode = zipCode as? ZipCode {
                    zipCode.zipCode = newZipCode
                    do {
                        try managedObjectContext.save()
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                }
            }
        } catch let error as NSError {
            print("\(error)")
        }
    }
}

// MARK: Outlet Actions
extension AddZipTableViewController {
    @IBAction func doneTapped(sender: AnyObject) {
        guard let newZipCode = zipEntryTextField?.text else {
            navigationController?.popViewControllerAnimated(true)
            return
        }
        
        addNewZipCodeIfNotAlreadySaved(newZipCode)
        
        navigationController?.popViewControllerAnimated(true)
    }
}

// MARK: UITableViewDataSource
extension AddZipTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier(zipEntryCellIdentifier, forIndexPath: indexPath)
            if let entryCell = cell as? ZipEntryCell {
                zipEntryTextField = entryCell.zipEntryTextField
                if zipEntryTextField?.allTargets().count < 1 {
                    zipEntryTextField?.addTarget(self, action: #selector(AddZipTableViewController.textFieldDidChange), forControlEvents: .EditingChanged)
                }
            }
        case 1, 2:
            cell = configureZipDetailsCell(indexPath)
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
}

// MARK: Cell Configuration
extension AddZipTableViewController {
    func configureZipDetailsCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(zipDetailsCellIdentifier, forIndexPath: indexPath) as! ZipDetailsCell
        
        if requestInProgress {
            if indexPath.row == 1 {
                cell.detailsLabel.text = "Fetching information..."
            } else {
                cell.detailsLabel.text = ""
            }
        } else if let weatherInfo = weatherInfo {
            if indexPath.row == 1 {
                cell.detailsLabel.text = "Temperature: \(weatherInfo.currentTemperatureInFarenheit) F"
            } else if indexPath.row == 2 {
                cell.detailsLabel.text = "Humidity: \(weatherInfo.currentHumidity)%"
            }
        } else {
            if indexPath.row == 1 {
                cell.detailsLabel.text = weatherManagerErrorHelper.getUserFriendlyErrorMessage(currentFetcherError)
            } else {
                cell.detailsLabel.text = ""
            }
        }
        
        return cell
    }
    
    
}

// MARK: UITextField
extension AddZipTableViewController {
    func textFieldDidChange() {
        guard let zipEntryTextField = zipEntryTextField else {
            return
        }
        guard let zipInput = zipEntryTextField.text else {
            return
        }
        
        validateAndFetchWeatherDataForZipCode(zipInput)
    }
}

// MARK: Weather Fetch Handling
extension AddZipTableViewController {
    func validateAndFetchWeatherDataForZipCode(zipInput: String) {
        do {
            try weatherManager.fetchWeatherInformationForZip(zipInput, completion: { (result) in
                do {
                    try self.weatherInfo = result()
                    self.currentFetcherError = nil
                } catch WeatherFetcherError.InvalidInput {
                    self.currentFetcherError = .InvalidInput
                } catch WeatherFetcherError.UnexpectedResponse {
                    self.currentFetcherError = .UnexpectedResponse
                    // TODO: prompt user to send error report
                    print("Prompt user to send problem report")
                } catch let error as NSError {
                    self.currentFetcherError = .UnexpectedResponse
                    // TODO: prompt user to send error report
                    print("Prompt user to send problem report for error: \(error)")
                }
                self.requestInProgress = false
                dispatch_async(dispatch_get_main_queue(),{
                    self.reloadNonInputRows()
                })
            })
            requestInProgress = true
        } catch WeatherFetcherError.NoInternetConnection {
            currentFetcherError = .NoInternetConnection
        } catch WeatherFetcherError.InvalidInput {
            currentFetcherError = .InvalidInput
        } catch let error as NSError {
            currentFetcherError = .UnexpectedResponse
            // TODO: prompt user to send error report
            print("Prompt user to send problem report for error: \(error)")
        }
        weatherInfo = nil
        reloadNonInputRows()
    }
}