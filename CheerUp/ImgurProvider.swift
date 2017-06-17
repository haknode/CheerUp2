//
//  ImgurProvider.swift
//  CheerUp
//
//  Created by stefan on 08/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import Moya
import Alamofire
import SwiftyJSON

private class ImageUrl {
    var id: String
    var url: String
    var type: ImageType
    
    init(id: String, url: String, type: ImageType) {
        self.id = id
        self.url = url
        self.type = type
    }
}

class ImgurProvider : ImageProviderProtocol {

    ///adds the api key to the reqeusts
    private var myEndpointClosure = { (target: ImgurComApi) -> Endpoint<ImgurComApi> in
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": "Client-ID **YOUR_KEY**"])
    }
    
    private var provider = MoyaProvider<ImgurComApi>()
    
    private var storage = StorageService.sharedInstance
    
    private var searchResults = [ImageUrl]()
    
    private var previousSearchResultIds = [String]()
    
    private var currentSearchPage = [String : Int]()
    
    private var numberOfRunningRequests = ConcurrentCounter()
    
    ///define witch image type to use
    public var useGifs = true {
        didSet{
            searchResults.removeAll()
        }
    }

    public var useJpgs = true {
        didSet{
            searchResults.removeAll()
        }
    }

    public var usePngs = true {
        didSet{
            searchResults.removeAll()
        }
    }

    
    init(){
        provider = MoyaProvider<ImgurComApi>(endpointClosure: myEndpointClosure)
    }
    
    ///calles the completionhandler if a new image is available
    public func getRandomImage(onCompletion completionHandler: @escaping CompletionHandler<Image, NetworkError>, ignoreMaxNumberOfRequests: Bool) {
        nextImage(onCompletion: { (image, error) in
            if let image = image {
                
                //check if an image with this id is already stored locally (as favorites)
                if let storedImage = self.storage.loadImage(withId: image.id){
                    completionHandler(storedImage, nil)
                    return
                }
                
                //if not stored locally , download it
                self.download(url: image.url, onCompletion: { (data, error) in
                    if let data = data {
                        completionHandler(Image(data: data, id: image.id, type: image.type, source: .imgur, shareUrl: image.url), nil)
                    }
                    else{
                        completionHandler(nil, error)
                    }
                })
            }
            else{
                completionHandler(nil, error)
            }
        }, ignoreMaxNumberOfRequests: ignoreMaxNumberOfRequests)
    }
    
    ///calls the completion handler with a new imageUrl object (as soon as one is available)
    ///uses images from previous searches (searchResults array)
    ///or starts a new search if the searchResults array is empty
    private func nextImage(onCompletion completionHandler: @escaping CompletionHandler<ImageUrl, NetworkError>, ignoreMaxNumberOfRequests: Bool){

        //try to use imageUrl from previous searches
        if let image = searchResults.getAndRemoveRandomElement(){
            completionHandler(image, nil)
        }
        else{
            guard let tag = SettingsService.sharedInstance.getSelectedTags().randomElement() else{
                completionHandler(nil, .generalError("no tag!"))
                return
            }
            
            //search for images
            //if the search is completed, the completionhandler is called with an imageUrl
            performSearch(withTag: tag, onCompletion: { (success, error) in
                if let image = self.searchResults.getAndRemoveRandomElement(){
                    completionHandler(image, nil)
                }
                else{
                    completionHandler(nil, error)
                }
            }, ignoreMaxNumberOfRequests: ignoreMaxNumberOfRequests)
        }
    }
    
    ///performs a search with the given tag and adds the results to th searchResults array
    ///the completion handler is called when the search is done
    private func performSearch(withTag tag: String, onCompletion completionHandler: @escaping CompletionHandler<Bool, NetworkError>, ignoreMaxNumberOfRequests: Bool ){
        
        var page = 1
        
        //use the stored page number, if available (a previous search was already executed)
        if let p = currentSearchPage[tag]{
            page = p
        }
        else{   //use a random page if this is the first search
            page = Int(arc4random_uniform(UInt32(50)))
        }
        
        if !ignoreMaxNumberOfRequests && self.numberOfRunningRequests.value > 3{
            print("max number of running requests reached: \(self.numberOfRunningRequests.value)")
            
            //completionHandler(nil, .generalError("max number of network requests reached: \(self.numberOfRunningRequests.value)"))

            return
        }
        
        print("request sent with tag: \(tag) using results page: \(page)")
        
        self.numberOfRunningRequests.increment()
        provider.request(.search(query: tag, page: page)) { (result) in
            switch result {
            case .success(let response):
                
                let json = JSON(data: response.data)
                
                if json["success"].boolValue != true {
                    completionHandler(false, .generalError("Error: response success == false"))
                    self.numberOfRunningRequests.decrement()
                    return
                }
                
                let data = json["data"].arrayValue
                
                if data.count == 0 {    //if the request is successful but the data array is empty, we reached the end the results, start at first page again
                    self.currentSearchPage[tag] = 1
                }
                else{
                    self.currentSearchPage[tag] = page + 1  //increment and store the search results page
                }
                
                for d in data{
                    let id = d["id"].stringValue
                    let link = d["link"].stringValue
                    let animated = d["animated"].boolValue
                    let type = d["type"].stringValue
                    let size = d["size"].int32Value
                    let nsfw = d["data"].boolValue
                    
                    //link returned is just thumbnail if gif is too big (we could generate the url manually from id?)
                    //but gifs bigger than 20mb are a problem anyway
                    if size > 5 * 1024 * 1024{
                        print("image too big!")
                        continue
                    }
                    
                    if nsfw == true {
                        print("image is nsfw!")
                        continue
                    }
                    
                    if self.useGifs && animated && type == "image/gif"{
                        self.addToSearchResults(ImageUrl(id: id, url: link, type: .gif))
                    }
                    else if self.useJpgs && type == "image/jpeg"{
                        self.addToSearchResults(ImageUrl(id: id, url: link, type: .other))
                    }
                    else if self.usePngs && type == "image/png"{
                        self.addToSearchResults(ImageUrl(id: id, url: link, type: .other))
                    }
                    else if type != ""{
                        print("type=\(type)")
                    }
                }
                
                self.numberOfRunningRequests.decrement()
                
                completionHandler(true, nil)

            case .failure(let error):
                self.numberOfRunningRequests.decrement()
                
                completionHandler(false, .generalError("Moya Error: \(error.localizedDescription)"))
            }
        }
    }
    
    ///downloads the given url
    ///the completionhandler is called when the data is available
    private func download(url: String, onCompletion completionHandler: @escaping CompletionHandler<Data, NetworkError> ){
         
        //no authentication header required because this is a public url
        Alamofire.request(url).response(completionHandler: { (response) in
            
            if let error = response.error{
                completionHandler(nil, .generalError("Alamofire Error: \(error.localizedDescription)"))
            }
            else if let data = response.data{
                completionHandler(data, nil)
            }
            else{
                completionHandler(nil, .generalError("Alamofire no data available"))
            }
        })
    }
    
    ///adds an imageUrl to the search results if:
    /// the previsousSearchResults do not already contain the id
    /// the searchResulsts do not already contain the id
    private func addToSearchResults(_ imageUrl: ImageUrl){
        
        if previousSearchResultIds.contains(where: { $0 == imageUrl.id }){
            print("imageid is in previous search results")

            return
        }
        
        if !searchResults.contains(where: { $0.id == imageUrl.id }){
            searchResults.append(imageUrl)
            
            previousSearchResultIds.enqueue(imageUrl.id)
            
            if previousSearchResultIds.count > 50 {
                _ = previousSearchResultIds.dequeue()
            }
        }
        else{
            print("imageUrl already exists")
        }
    }
}


