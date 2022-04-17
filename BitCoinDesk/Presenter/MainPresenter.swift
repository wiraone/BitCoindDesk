//
//  MainPresenter.swift
//  BitCoinDesk
//
//  Created by Mac on 15/04/22.
//

import Foundation
import CoreData

protocol MainPresenterDelegate: AnyObject {
    func didSuccessFetchCurrentPriceFromAPI(currentPrice: CurrentPriceModel)
    func didFailedFetchCurrentPriceFromAPI()
}

class MainPresenter {
    private weak var delegate: MainPresenterDelegate?
    private var currentPriceAPI: CurrentPriceAPI!
    
    init(delegate: MainPresenterDelegate) {
        self.delegate = delegate
    }
    
    /**
        Fetch current price from coin desk using thei api
        - Returns: Success delegate if there is no error message else otherwise
    */
    func fetchCurrentPriceFromAPI() {
        let configuration = URLSessionConfiguration.ephemeral
        let urlSession = URLSession(configuration: configuration)
        
        currentPriceAPI = CurrentPriceAPI.init(urlSession: urlSession)
        currentPriceAPI.getCurrentPrice { currentPrice in
            
            if let _ = currentPrice.errorMessage {
                self.delegate?.didFailedFetchCurrentPriceFromAPI()
            }
            else {
                self.delegate?.didSuccessFetchCurrentPriceFromAPI(currentPrice: currentPrice)
            }
        }
    }
    
    /**
        Generate content for  Time, Price, currency, User Location, this data will display below chart view
     
        - Parameters:
            - charts: chart data can be from API or core data database
            - currenyCode: currecy code type
         
        - Returns: List of content
    */
    func generateContent(charts: [Chart], currencyCode: String = "USD") -> [Content] {
        var contents: [Content] = []
        for chart in charts {
            var price = chart.usd
            
            if currencyCode == "GBP" {
                price = chart.gbp
            }
            else if currencyCode == "EUR" {
                price = chart.eur
            }
            
            let createdAt = Date(timeIntervalSince1970: chart.createdAt).toString(format: "HH:mm:ss")
            let content = Content(price: price, userLocation: chart.location, createdAt: createdAt)
            contents.append(content)
        }
        return contents
    }
    
    /**
        Generate point entry to render data on chart
     
        - Parameters:
            - charts: chart data can be from API or core data database
            - currenyCode: currecy code type
         
        - Returns: List of point entry
    */
    func generatePointEntry(charts: [Chart], currencyCode: String = "USD") -> [PointEntry] {
        var pointEntries: [PointEntry] = []
        
        //Add default point entry
        let pointEntry: PointEntry = PointEntry(value: 0, label: "00")
        pointEntries.append(pointEntry)
        
        for chart in charts {
            var rateFloat = chart.usd?.rateFloat
            
            if currencyCode == "GBP" {
                rateFloat = chart.gbp?.rateFloat
            }
            else if currencyCode == "EUR" {
                rateFloat = chart.eur?.rateFloat
            }
            
            let date = Date(timeIntervalSince1970: chart.createdAt)
            let hourLabel = date.toString(format: "HH")
            let rateInt = Int(rateFloat ?? 0)
            let pointEntry: PointEntry = PointEntry(value: rateInt, label: hourLabel)
            pointEntries.append(pointEntry)
        }
        return pointEntries
    }
    
    /**
        Fetch data from core data entity chart
        - Parameters:
        - Returns: List of chart data
    */
    func fetchDataFromCoreDataDB() -> [Chart] {
        var chartList: [Chart] = []
        let fetch: NSFetchRequest<Chart> = Chart.fetchRequest()
        let sortDate = NSSortDescriptor.init(key: "createdAt", ascending: false)
        let context = AppDelegate.instance.sharedContext()
        fetch.sortDescriptors = [sortDate]
        fetch.fetchLimit = Configuration.TableView.maximumRow

        if let charts = try? context.fetch(fetch) {

            for chart in charts {
                chartList.append(chart)
            }
        }
        return chartList.reversed()
    }
    
    /**
        Delete data from core data if data is not on today date
     
        - Parameters:
            - charts: chart data can be from API or core data database
         
        - Returns: List of chart
    */
    func deletePastDataFromCoreDataDB(charts: [Chart]) -> [Chart] {
        var chartList: [Chart] = []
        let context = AppDelegate.instance.sharedContext()
        let calendar = Calendar.current
      
        for chart in charts {
            let date = Date(timeIntervalSince1970: chart.createdAt)
            
            if !calendar.isDateInToday(date) {
                context.delete(chart)
            }
            else {
                chartList.append(chart)
            }
        }
        
        try? context.save()
        return chartList
    }
}

