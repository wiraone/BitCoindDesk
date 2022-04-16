//
//  CurrentPriceAPITest.swift
//  BitCoinDeskTests
//
//  Created by Mac on 14/04/22.
//

import XCTest
@testable import BitCoinDesk

class CurrentPriceAPITest: XCTestCase {

    // custom urlsession for mock network calls
    var urlSession: URLSession!

    override func setUpWithError() throws {
        // Set url session for mock networking
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
    }
       
       func testGetCurrentPriceAPI() throws {
           // Current Price API. Injected with custom url session for mocking
           let currentPriceAPI = CurrentPriceAPI(urlSession: urlSession)
           
           // Set mock data
           var sampleEURCurrency = Currency()
           var sampleUSDCurrency = Currency()
           var sampleGBPCurrency = Currency()
           var sampleBPIData = Bpi()
           var sampleTime = Time()
           var sampleCurrentPriceData = CurrentPriceModel()
    
           sampleEURCurrency.code = "EUR"
           sampleEURCurrency.currencyDescription = "This is EUR currency mock data"
           
           sampleUSDCurrency.code = "USD"
           sampleUSDCurrency.currencyDescription = "This is USD currency mock data"
           
           sampleGBPCurrency.code = "GBP"
           sampleGBPCurrency.currencyDescription = "This is GBP currency mock data"
           
           sampleBPIData.eur = sampleEURCurrency
           sampleBPIData.usd = sampleUSDCurrency
           sampleBPIData.gbp = sampleGBPCurrency
           
           sampleTime.updated = ""
           sampleTime.updatedISO = ""
           sampleTime.updateduk = ""
           
           sampleCurrentPriceData.bpi = sampleBPIData
           sampleCurrentPriceData.chartName = "Bitcoin mock name"
           sampleCurrentPriceData.time = sampleTime
           sampleCurrentPriceData.disclaimer = "Disclaimer mock data"
           
           let mockData = try JSONEncoder().encode(sampleCurrentPriceData)
           
           // Return data in mock request handler
           MockURLProtocol.requestHandler = { request in
               return (HTTPURLResponse(), mockData)
           }
           
           // Set expectation. Used to test async code.
           let expectation = XCTestExpectation(description: "response")
           
           // Make mock network request to get current price
           currentPriceAPI.getCurrentPrice { price in
               // Test
               XCTAssertEqual(price.bpi?.eur?.code, "EUR")
               expectation.fulfill()
           }
           wait(for: [expectation], timeout: 1)
       }

}
