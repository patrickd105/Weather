//
//  WeatherManagerTests.swift
//  WeatherManagerTests
//
//  Created by Patrick Dunshee on 5/8/16.
//  Copyright © 2016 Patrick Dunshee. All rights reserved.
//

import XCTest
@testable import Weather

class WeatherManagerTests: XCTestCase {
    var weatherManager: WeatherManager!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        weatherManager = WeatherManager()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsZipCodeValid_FiveDigitsValid() {
        let returned = weatherManager.isZipCodeValid("78751")
        
        XCTAssert(returned)
    }
    
    func testIsZipCodeValid_FiveDigitsInvalid() {
        let returned = weatherManager.isZipCodeValid("78a51")
        
        XCTAssertFalse(returned)
    }
    
    func testIsZipCodeValid_TenDigitsValid() {
        let returned = weatherManager.isZipCodeValid("78751-9999")
        
        XCTAssert(returned)
    }
    
    func testIsZipCodeValid_TenDigitsInvalidHyphen() {
        let returned = weatherManager.isZipCodeValid("78751a9999")
        
        XCTAssertFalse(returned)
    }
    
    func testIsZipCodeValid_TenDigitsValidDigits() {
        let returned = weatherManager.isZipCodeValid("78751-9a99")
        
        XCTAssertFalse(returned)
    }
    
    func testFetchWeatherInformationForZip_InvalidZip() {
        let invalidZip = "99999"
        
        let invalidExpectation = expectationWithDescription("invalidZip")
        
        do {
            try weatherManager.fetchWeatherInformationForZip(invalidZip) { (result) in
                do {
                    try result()
                } catch WeatherFetcherError.InvalidInput {
                    invalidExpectation.fulfill()
                } catch {
                    
                }
            }
        } catch {
            
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(2, handler: { error in
            XCTAssertNil(error, "Expected \(WeatherFetcherError.InvalidInput) error")
        })
    }
    
    func testFetchWeatherInformationForZip_ValidFiveDigitZip() {
        let fiveDigitZip = "78751"
        
        let weatherDataExpectation = expectationWithDescription("validFiveDigitZip")
        
        do {
            try weatherManager.fetchWeatherInformationForZip(fiveDigitZip) { (result) in
                do {
                    try result()
                    weatherDataExpectation.fulfill()
                } catch {
                    
                }
            }
        } catch {
            
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(2, handler: { error in
            XCTAssertNil(error, "Expected no error")
        })
    }
    
    func testFetchWeatherInformationForZip_ValidTenDigitZip() {
        let tenDigitZip = "78751-5555"
        
        let weatherDataExpectation = expectationWithDescription("validFiveDigitZip")
        
        do {
            try weatherManager.fetchWeatherInformationForZip(tenDigitZip) { (result) in
                do {
                    try result()
                    weatherDataExpectation.fulfill()
                } catch {
                    
                }
            }
        } catch {
            
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(2, handler: { error in
            XCTAssertNil(error, "Expected no error")
        })
    }
    
}
