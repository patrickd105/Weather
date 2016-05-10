//
//  ZipDetailsTableViewController.swift
//  Weather
//
//  Created by Patrick Dunshee on 5/8/16.
//  Copyright © 2016 Patrick Dunshee. All rights reserved.
//

import UIKit

let zipDetailsCellIdentifier = "ZipDetailsCell"

enum DetailRowType: Int {
    case TemperatureRow = 0
    case HumidityRow
}

class ZipDetailsTableViewController: UITableViewController {
    var selectedZip: String!
    var requestCompleted = false
    let weatherManager = WeatherManager()
    var weatherInfo: WeatherInfo?
    let weatherManagerErrorHelper = WeatherManagerErrorHelper()
    var currentFetcherError: WeatherFetcherError?
    
    override func viewDidLoad() {
        let nib = UINib(nibName: zipDetailsCellIdentifier, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: zipDetailsCellIdentifier)
        
        title = "Weather info for \(selectedZip)"
        
        attemptWeatherFetch()
    }
}

// MARK: Weather Fetch
extension ZipDetailsTableViewController {
    func attemptWeatherFetch() {
        do {
            try weatherManager.fetchWeatherInformationForZip(selectedZip) { (result) in
                do {
                    try self.weatherInfo = result()
                    self.currentFetcherError = nil
                } catch WeatherFetcherError.NoInternetConnection {
                    self.currentFetcherError = .NoInternetConnection
                } catch WeatherFetcherError.InvalidInput {
                    self.currentFetcherError = .InvalidInput
                } catch let error as NSError {
                    self.currentFetcherError = .UnexpectedResponse
                    // TODO: prompt user to send error report
                    print("Prompt user to send problem report for error: \(error)")
                }
                self.requestCompleted = true
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                })
            }
        } catch WeatherFetcherError.NoInternetConnection {
            currentFetcherError = .NoInternetConnection
            requestCompleted = true
            tableView.reloadData()
        } catch let error as NSError {
            currentFetcherError = .UnexpectedResponse
            requestCompleted = true
            // TODO: prompt user to send error report
            print("Prompt user to send problem report for error: \(error)")
            tableView.reloadData()
        }
    }
}

// MARK: UITableViewDataSource
extension ZipDetailsTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentFetcherError != nil || !requestCompleted {
            return 1
        }
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(zipDetailsCellIdentifier, forIndexPath: indexPath) as? ZipDetailsCell else {
            fatalError("Couldn't dequeue ZipDetailsCell properly")
        }
        
        guard let weatherInfo = weatherInfo else {
            if requestCompleted {
                cell.detailsLabel.text = weatherManagerErrorHelper.getUserFriendlyErrorMessage(currentFetcherError)
            } else {
                cell.detailsLabel.text = "Fetching information..."
            }
            return cell
        }
        
        var detailsString = ""
        let row = DetailRowType(rawValue: indexPath.row)!
        switch row {
        case .TemperatureRow:
            detailsString = "Temperature: \(weatherInfo.currentTemperatureInFarenheit) F"
        case .HumidityRow:
            detailsString = "Humidity: \(weatherInfo.currentHumidity)%"
        }
        
        cell.detailsLabel.text = detailsString
        
        return cell
    }
}