//
//  WeatherManagerErrorHelper.swift
//  Weather
//
//  Created by Patrick Dunshee on 5/9/16.
//  Copyright © 2016 Patrick Dunshee. All rights reserved.
//

import Foundation

class WeatherManagerErrorHelper {
    func getUserFriendlyErrorMessage(weatherFetcherError: WeatherFetcherError?) -> String {
        guard let currentFetcherError = weatherFetcherError else {
            return "Unknown error"
        }
        
        switch currentFetcherError {
        case .InvalidInput:
            return "Invalid zip code"
        case .NoInternetConnection:
            return "No internet connection"
        case .UnexpectedResponse:
            return "Unknown error"
        }
    }
}