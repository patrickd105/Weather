//
//  WeatherInfo.swift
//  Weather
//
//  Created by Patrick Dunshee on 5/8/16.
//  Copyright © 2016 Patrick Dunshee. All rights reserved.
//

import Foundation

class WeatherInfo {
    var currentTemperatureInFarenheit: Float
    var currentHumidity: Float
    
    init(currentTemperatureInFarenheit: Float, currentHumidity: Float) {
        self.currentTemperatureInFarenheit = currentTemperatureInFarenheit
        self.currentHumidity = currentHumidity
    }
}