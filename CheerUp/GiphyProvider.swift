//
//  GiphyProvider.swift
//  CheerUp
//
//  Created by stefan on 31/01/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import Foundation

import Moya
import SwiftyJSON
import Alamofire

class GiphyProvider: ImageProviderProtocol{

    private let storage = StorageService.sharedInstance
    
    private let moyaProvider = MoyaProvider<GiphyComApi>()

    private let rating = "pg-13"
    
    private let testApiKey = "**YOUR_KEY**"

    private var numberOfRunningRequests = ConcurrentCounter()
    
    ///the completionhandler is called when a new image is available
    public func getRandomImage(onCompletion completionHandler: @escaping CompletionHandler<Image, NetworkError>, ignoreMaxNumberOfRequests: Bool) {
        
        var tag = SettingsService.sharedInstance.getSelectedTags().randomElement()

        if tag == nil {
            tag = ""
        }

        if !ignoreMaxNumberOfRequests && self.numberOfRunningRequests.value > 3{
            print("max number of running requests reached: \(self.numberOfRunningRequests.value)")
            
            //completionHandler(nil, .generalError("max number of network requests reached: \(self.numberOfRunningRequests.value)"))
            return
        }
                
        print("request sent with tag: \(tag!)")
        
        self.numberOfRunningRequests.increment()
        moyaProvider.request(.random(apiKey: testApiKey, tags: [tag!], rating: rating)) { (result) in
            switch result {
            case .success(let response):
                let data = response.data
                
                let json = JSON(data: data)
                
                let imageUrl = json["data"]["image_url"].stringValue
                let imageId = json["data"]["id"].stringValue
                
                if imageUrl.isEmpty || imageId.isEmpty {
                    completionHandler(nil, .generalError("error reading json response"))

                    return
                }
                
                //check if image with this id is already stored locally
                if let storedImage = self.storage.loadImage(withId: imageId) {
                    self.numberOfRunningRequests.decrement()
                    
                    completionHandler(storedImage, nil)
                    return
                }
                
                //not stored locally, download the image
                Alamofire.request(imageUrl).response(completionHandler: { (response) in
                    self.numberOfRunningRequests.decrement()

                    if let error = response.error{
                        completionHandler(nil, .generalError("Alamofire Error: \(error.localizedDescription)"))
                    }
                    else if let data = response.data{
                        completionHandler(Image(data: data, id: imageId, type: .gif, source: .giphy, shareUrl: imageUrl), nil)
                    }
                    else{
                        completionHandler(nil, .generalError("Alamofire no data available"))
                    }
                })
                
            case .failure(let error):
                self.numberOfRunningRequests.decrement()

                completionHandler(nil, .generalError("Moya Error: \(error.localizedDescription)"))
            }
        }
    }
}
