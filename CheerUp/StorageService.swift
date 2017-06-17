//
//  StorageService.swift
//  CheerUp
//
//  Created by stefan on 31/01/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import Foundation
//couchbase lite import in Bridging header

class StorageService{
 
    public static let sharedInstance = StorageService()
 
    private let dbName = "images"
    
    private var database : CBLDatabase
    
    init(){
        database = try! CBLManager.sharedInstance().databaseNamed(dbName)
    }
    
    ///returns a view of all image documents
    private func getImagesListView() -> CBLView {
        let imagesListView = database.viewNamed("list/images")
        if imagesListView.mapBlock == nil{
            imagesListView.setMapBlock({ (doc, emmit) in
                if let docType = doc["documentType"] as? String, docType == "image"{
                    emmit(docType, nil)
                }
            }, version: "1.0")
        }
        
        return imagesListView
    }
    
    ///returns a view of all  cached image documents
    private func getCacheImagesListView() -> CBLView {
        let imagesListView = database.viewNamed("list/cacheImages")
        if imagesListView.mapBlock == nil{
            imagesListView.setMapBlock({ (doc, emmit) in
                if let docType = doc["documentType"] as? String, docType == "cacheImage"{
                    emmit(docType, nil)
                }
            }, version: "1.0")
        }
        
        return imagesListView
    }
    
    ///saves an image into the database
    public func save(image: Image, documentType: String = "image"){
        
        let properties: [String:Any] = ["documentType": documentType,
                                        "type": image.type.rawValue,
                                        "source": image.source.rawValue,
                                        "shareUrl": image.shareUrl]
        
        do{
            if let document = database.document(withID: image.id){
                try document.putProperties(properties)
                let revision = document.currentRevision?.createRevision()
                
                //the image data is added as attachment
                revision?.setAttachmentNamed("image", withContentType: "data", content: image.data)
                revision?.setAttachmentNamed("thumbnail", withContentType: "data", content: image.thumbnail)
                try revision?.save()
            }
        } catch let error as NSError {
            print("CBL Error: \(error)")
        }
    }
    
    ///loads an image from the database, returns nil if no image with the given id exists
    public func loadImage(withId id: String) -> Image?{
        if let document = database.document(withID: id){
            return StorageService.imageFromDocument(cblDocument: document)
        }
        
        return nil
    }
    
    /*
    ///returns an array with all images from the database, my be slow and to big!
    public func loadAll() -> [Image]{
        
        var images = [Image]()
        
        let view = getImagesListView()
        
        let query = view.createQuery()
        
        if let result = try? query.run(){
            while let row = result.nextRow(){
                if let image = StorageService.imageFromDocument(cblDocument: row.document){
                    images.append(image)
                }
            }
        }

        return images
    }
    */
    
    ///returns a live query of all images
    public func loadAllLiveQuery() -> CBLLiveQuery{
        return getImagesListView().createQuery().asLive()
    }
    
    ///returns a random image from the databse, or nil if no image is available
    public func loadRandom() -> Image?{
        let query = getImagesListView().createQuery()
        
        if let result = try? query.run(){
            if result.count > 0{
                let r = arc4random_uniform(UInt32(result.count))    //use a random row
                
                let row = result.row(at: UInt(r))
                
                return StorageService.imageFromDocument(cblDocument: row.document)
            }
        }
        
        return nil
    }
    
    ///removes an image from the database
    public func remove(image: Image){
        remove(withId: image.id)
    }
    
    ///removes an image from the database
    public func remove(withId id: String){
        do{
            if let document = database.document(withID: id){
                try document.delete()
            }
        } catch let error as NSError {
            print("CBL Error: \(error)")
        }
    }
    
    
    //== Cach Methods ==\\
    
    ///saves an array of images as cache, deletes the old cache
    public func saveCache(imageArray: [Image]){
        deleteCache()
        
        for image in imageArray{
            save(image: image, documentType: "cacheImage")
        }
    }
    
    ///loads the entire cache (all images) and returns all images
    ///deletes the cache after loading
    public func loadCache() -> [Image]{
        var images = [Image]()
        
        let query = getCacheImagesListView().createQuery()
        
        if let result = try? query.run(){
            while let row = result.nextRow(){
                if let image = StorageService.imageFromDocument(cblDocument: row.document){
                    image.isFavorite = false
                    
                    images.append(image)
                }
                
                try? row.document?.delete()
            }
        }
        
        return images
    }
    
    ///delete the entire (all images) cache
    public func deleteCache(){
        let query = getCacheImagesListView().createQuery()
        
        if let result = try? query.run(){
            while let row = result.nextRow(){
                try? row.document?.delete()
            }
        }
    }
    
    //== End Cach Methods ==\\
    
    
    ///creats an image object from a given cbl document
    ///returns nil if no image object could be created
    public static func imageFromDocument(cblDocument document: CBLDocument?) -> Image? {
        if let properties = document?.properties{
            if let id = document?.documentID, let type = properties["type"] as? String, let source = properties["source"] as? String, let shareUrl = properties["shareUrl"] as? String, let attachment = document?.currentRevision?.attachmentNamed("image"){
                if let data = attachment.content, let type = ImageType(rawValue: type), let source = ImageSource(rawValue: source) {
                    return Image(data: data, id: id, type: type, source: source, shareUrl: shareUrl, isFavorite: true)
                }
            }
        }
        
        return nil
    }
    
    ///creats an imageMetadata object from a given cbl document
    ///imageMetadata objects dont contain the image itself (only a thumbnail) and therefore are smaller
    ///returns nil if no image object could be created
    public static func imageMetadataFromDocument(cblDocument document: CBLDocument?) -> ImageMetadata? {
        if let properties = document?.properties{
            if let id = document?.documentID, let type = properties["type"] as? String, let source = properties["source"] as? String, let shareUrl = properties["shareUrl"] as? String, let attachment = document?.currentRevision?.attachmentNamed("thumbnail"){
                if let data = attachment.content, let type = ImageType(rawValue: type), let source = ImageSource(rawValue: source) {
                    return ImageMetadata(id: id, thumbnail: data, type: type, source: source, shareUrl: shareUrl, isFavorite: true)
                }
            }
        }
        
        return nil
    }
}
