//
//  WeatherManager.swift
//  Weather
//
//  Created by Patrick Dunshee on 5/8/16.
//  Copyright © 2016 Patrick Dunshee. All rights reserved.
//

import Foundation

protocol WeatherFetcher {
    func fetchWeatherInformationForZip(zipCode: String, completion: (result: () throws -> WeatherInfo) -> Void) throws
}

enum WeatherFetcherError: ErrorType {
    case NoInternetConnection
    case InvalidInput
    case UnexpectedResponse
}

class WeatherManager {
    var weatherFetcher: WeatherFetcher = WundergroundFetcher()
    func fetchWeatherInformationForZip(zipCode: String, completion: (result: () throws -> WeatherInfo) -> Void) throws {
        if !isZipCodeValid(zipCode) {
            throw WeatherFetcherError.InvalidInput
        }
        
        try weatherFetcher.fetchWeatherInformationForZip(zipCode, completion: completion)
    }
    
    // Valid US Zip Code formats are ddddd and ddddd-dddd where each d is any digit
    func isZipCodeValid(zipCode: String) -> Bool {
        let characterCount = zipCode.characters.count
        guard characterCount == 5 || characterCount == 10 else {
            return false
        }
        var isValid = true
        
        for i in 0..<characterCount {
            let character = zipCode[zipCode.startIndex.advancedBy(i)]
            if i != 5 {
                let s = String(character).unicodeScalars
                let uni = s[s.startIndex]
                
                let digits = NSCharacterSet.decimalDigitCharacterSet()
                let isADigit = digits.longCharacterIsMember(uni.value)
                if !isADigit {
                    isValid = false
                    break
                }
            } else {
                if character != "-" {
                    isValid = false
                    break
                }
            }
        }
        
        return isValid
    }
}