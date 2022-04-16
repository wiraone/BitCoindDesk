//
//  CurrentPriceAPI.swift
//  BitCoinDesk
//
//  Created by Mac on 14/04/22.
//

import Foundation
import Combine

class CurrentPriceAPI {
    let url = URL(string: Configuration.BaseURL.url)!
    private var cancellable: AnyCancellable?
    
    // session to be used to make the API call
    let session: URLSession
    
    // Make the session shared by default.
    // In unit tests, a mock session can be injected.
    init(urlSession: URLSession = .shared) {
        self.session = urlSession
    }
    
    // get current price from backend using combine framework
    func getCurrentPrice(completion: @escaping (CurrentPriceModel) -> Void) {
        cancellable = session.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: CurrentPriceModel.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .catch({ (error) -> Just<CurrentPriceModel> in
                let errorMessage = error.localizedDescription
                var currentPriceModel = CurrentPriceModel()
                currentPriceModel.errorMessage = errorMessage
                return Just(currentPriceModel)
            })
            .sink { currentPrice in
                completion(currentPrice)
        }
    }
}
