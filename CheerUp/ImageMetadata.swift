//
//  ImageMetadata.swift
//  CheerUp
//
//  Created by stefan on 11/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

///defines the metadata a image has
///does not contain the image data itself
class ImageMetadata{
    ///the thumbnail is not stored directly, but a method that returns the thumbnail
    ///method only creates thumbnail if neccesary
    private let thumbnailCreator: () -> Data

    public let id: String
    public let type: ImageType
    public let source: ImageSource
    public var isFavorite: Bool
    public var shareUrl: String
    
    ///does not store the thumbnail, but calls the thumbnailCreator method
    public var thumbnail: Data {
        return thumbnailCreator()
    }
    
    init(id: String, thumbnail: Data, type: ImageType, source: ImageSource, shareUrl: String, isFavorite: Bool = false){
        self.id = id
        self.thumbnailCreator = {_ in return thumbnail}
        self.isFavorite = isFavorite
        self.type = type
        self.source = source
        self.shareUrl = shareUrl
    }
    
    init(id: String, thumbnailCreator: @escaping () -> Data, type: ImageType, source: ImageSource, shareUrl: String, isFavorite: Bool = false) {
        self.id = id
        self.thumbnailCreator = thumbnailCreator
        self.isFavorite = isFavorite
        self.type = type
        self.source = source
        self.shareUrl = shareUrl
    }
}

///defines the type an image can be of
enum ImageType: String {
    case gif = "gif"
    case other = "other"
}

///defines the source an image can originate from
enum ImageSource: String {
    case giphy = "giphy"
    case imgur = "imgur"
}
