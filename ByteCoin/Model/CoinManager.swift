//
//  CoinManager.swift
//  ByteCoin
//
//  Edited by Akhil Raj on 03/17/2022.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func currencyDidUpdate(price: String, currency: String)
    func didFailWithError(_ coinManager: CoinManager, error: Error)
}

struct CoinManager {
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "D09FC65C-CC42-49C6-9BC8-31CBE6511502"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
            
            //Use String concatenation to add the selected currency at the end of the baseURL along with the API key.
            let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
            
            //Use optional binding to unwrap the URL that's created from the urlString
            if let url = URL(string: urlString) {
                
                //Create a new URLSession object with default configuration.
                let session = URLSession(configuration: .default)
                
                //Create a new data task for the URLSession
                let task = session.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        self.delegate?.didFailWithError(self, error: error!)
                        return
                    }
                    
                    if let safeData = data {
                        if let coinPrice = parseJSON(safeData) {
                            let priceString = String(format: "%.2f", coinPrice)
                            self.delegate?.currencyDidUpdate(price: priceString, currency: currency)
                        }
                    }
                }
                //Start task to fetch data from bitcoin average's servers.
                task.resume()
            }
        }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinPriceData.self, from: data)
            let lastPrice = decodedData.rate
            
            return lastPrice
        }
        catch {
            delegate?.didFailWithError(self, error: error)
            return nil
        }
    }
}
