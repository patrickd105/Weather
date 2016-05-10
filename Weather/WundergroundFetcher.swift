//
//  WundergroundStrategy.swift
//  Weather
//
//  Created by Patrick Dunshee on 5/8/16.
//  Copyright © 2016 Patrick Dunshee. All rights reserved.
//

import Foundation

class WundergroundFetcher {
    func getWeatherFetcherErrorFromJSON(jsonData: [String : AnyObject]) -> WeatherFetcherError {
        let wundergroundResponse = jsonData["response"]
        guard let wundergroundError = wundergroundResponse?["error"] else {
            // If we got valid JSON back but it does not contain an error at this stage, the user entered a nonspecific location, which means it's not a zip code
            return .InvalidInput
        }
        if let wundergroundErrorType = wundergroundError?["type"] {
            if let wundergroundErrorType = wundergroundErrorType {
                if let wundergroundErrorTypeString = wundergroundErrorType as? String {
                    if wundergroundErrorTypeString == "querynotfound" || wundergroundErrorTypeString == "invalidquery" {
                        return .InvalidInput
                    }
                }
            }
        }
        return .UnexpectedResponse
    }
}

// MARK: Weather Fetcher Functions
extension WundergroundFetcher: WeatherFetcher {
    func fetchWeatherInformationForZip(zipCode: String, completion: (result: () throws -> WeatherInfo) -> Void) throws {
        if !Reachability.isConnectedToNetwork() {
            throw WeatherFetcherError.NoInternetConnection
        }
        let wundergroundEndpoint: String = "http://api.wunderground.com/api/d6ba9b394270f12f/conditions/q/\(zipCode).json"
        guard let url = NSURL(string: wundergroundEndpoint) else {
            throw WeatherFetcherError.InvalidInput
        }
        let urlRequest = NSURLRequest(URL: url)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
            guard error == nil else {
                completion(result: {throw error!})
                return
            }
            
            guard let responseData = data else {
                completion(result: {throw WeatherFetcherError.InvalidInput})
                return
            }
            
            do {
                guard let weatherData = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: AnyObject] else {
                    completion(result: {throw WeatherFetcherError.UnexpectedResponse})
                    return
                }
                
                guard let currentObservation = weatherData["current_observation"] else {
                    completion(result: {throw self.getWeatherFetcherErrorFromJSON(weatherData)})
                    return
                }
                guard let currentTemperatureInFarenheit = currentObservation["temp_f"] as? Float else {
                    completion(result: {throw WeatherFetcherError.UnexpectedResponse})
                    return
                }
                guard let currentHumidityString = currentObservation["relative_humidity"] as? String else {
                    completion(result: {throw WeatherFetcherError.UnexpectedResponse})
                    return
                }
                let currentHumidity = (currentHumidityString as NSString).floatValue
                
                let weatherInfo = WeatherInfo(currentTemperatureInFarenheit: currentTemperatureInFarenheit, currentHumidity: currentHumidity)
                completion(result: {return weatherInfo})
            } catch let error as NSError {
                completion(result: {throw error})
            }
        })
        task.resume()
    }
}