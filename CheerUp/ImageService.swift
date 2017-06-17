//
//  ImageService.swift
//  CheerUp
//
//  Created by stefan on 08/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

class ImageService {
    
    public static let sharedInstance = ImageService()
    
    private let settings = SettingsService.sharedInstance
    private let storage = StorageService.sharedInstance
    
    private let cacheSize = 6
    
    private var imageCache = Array<Image>()
    private var cachedImageTypes = SettingsService.sharedInstance.getSliderValue()
    
    private var lastImage : Image?
    private var currentImage : Image?
    
    private var imgurProvider = ImgurProvider()
    private var giphyProvider = GiphyProvider()
    
    private var imageProviders = [ImageProviderProtocol]()
    
    init() {
        imageProviders.append(imgurProvider)
        imageProviders.append(giphyProvider)
    }
    
    ///if true, the method requestImage will return a favorite image if no image is in the cache and the network request will take some time
    public var useStoredImagesIfCacheEmpty = true
    
    ///the completion handler will be called when an image is available
    public func requestImage(onCompletion completionHandler: @escaping CompletionHandler<Image, NetworkError>){
        
        //print("cache size: \(imageCache.count)")
        
        let index = settings.getSliderValue()
        
        if cachedImageTypes != index {
            imageCache.removeAll()
        }
        
        cachedImageTypes = index
        
        if let cachedImage = imageCache.dequeue(){
            setLastImage(currentImage: cachedImage)
            completionHandler(cachedImage, nil)
        }
        else if useStoredImagesIfCacheEmpty, let image = storage.loadRandom(){
            completionHandler(image, nil)
        }
        else{
            getImageProviderToUse().getRandomImage(onCompletion: {(image, error) in
                if let image = image{
                    self.setLastImage(currentImage: image)
                }
                
                completionHandler(image, error)
            }, ignoreMaxNumberOfRequests: true)
        }
        
        fillCache()
    }
    
    ///fills up the cache, is called recursivly
    private func fillCache(){
        let missingCount = cacheSize - imageCache.count
        
        if missingCount > 0 {
            
            getImageProviderToUse().getRandomImage(onCompletion: { (image, error) in
                
                if let image = image{
                    self.imageCache.enqueue(image)
                    //print("added image to cache")
                    
                    self.fillCache()
                }
            }, ignoreMaxNumberOfRequests: false)
        }
    }
    
    private func getImageProviderToUse() -> ImageProviderProtocol {
        let index = settings.getSliderValue()
        
        if index == 0 {
            imgurProvider.useGifs = false
            imgurProvider.useJpgs = true
            imgurProvider.usePngs = true
            
            return imgurProvider
        }
        else if index == 1 {
            imgurProvider.useGifs = true
            imgurProvider.useJpgs = true
            imgurProvider.usePngs = true
            
            return imageProviders.randomElement()!
        } else if index == 2{
            imgurProvider.useGifs = true
            imgurProvider.useJpgs = false
            imgurProvider.usePngs = false
            
            return imageProviders.randomElement()!
        }
        
        return ImgurProvider()
    }
    
    private func setLastImage(currentImage current: Image){
        lastImage = currentImage
        currentImage = current
    }
    
    public func getLastImage() -> Image? {
        return lastImage
    }
    
    public func getCurrentImage() -> Image?{
        return currentImage
    }

    ///persists the cache
    ///writes the cached images into the storage
    public func saveCache(){
        storage.saveCache(imageArray: imageCache)
    }
    
    ///loads cached images from the storage and fills the cache with them
    public func loadCache(){
        
        imageCache.removeAll()
        
        for image in storage.loadCache(){
            imageCache.append(image)
            
            print("loaded image into cache id=\(image.id)")
        }
    }
    
    /*
    func saveCacheToFile(){
        if let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first{
            let path = dir
            
            let list = path.appendingPathComponent("list")
            
            var listArray = [String]()
            
            for item in imageCache{
                listArray.append(item.id)
            }
            
            let a = NSArray(array: listArray)
            a.write(to: try! list.asURL(), atomically: false)
            
            for image in imageCache{
                let tmpPath = path.appendingPathComponent(image.id)
                
                try! image.data.write(to: try! tmpPath.asURL())
            }
        }
    }
    
    func loadCacheFromFile(){
        if let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first{
            let path = dir
            
            let list = path.appendingPathComponent("list")
            
            if let listArray = NSArray(contentsOf: try! list.asURL()){
                for i in listArray{
                    let tmpPath = path.appendingPathComponent(i as! String)
                    
                    if let d = try? Data(contentsOf: try! tmpPath.asURL()){
                        imageCache.append(Image(data: d, id: i as! String, type: .other, source: .giphy))
                        
                        print("loaded image from file: \(i as! String)")
                    }
                }
            }
        }
    }
    */
}
