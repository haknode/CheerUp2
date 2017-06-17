//
//  Image.swift
//  CheerUp
//
//  Created by stefan on 31/01/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

///represents an image with data and metadata
///extends the imageMetadata with the actual data of an image
class Image: ImageMetadata{
    var data: Data

    init(data: Data, id: String, type: ImageType, source: ImageSource, shareUrl: String, isFavorite: Bool = false){
        self.data = data
        ///initialise the metadata, the createThumbnail method is only called if neccesary
        super.init(id: id, thumbnailCreator: {_ in return Image.createThumbnail(forData: data)}, type: type, source: source, shareUrl: shareUrl, isFavorite: isFavorite)
    }

    ///creates a thumbnail from an image
    ///max with of the resulting thumbnail is 200px
    ///if the original image is a gif, the first frame is used
    private static func createThumbnail(forData image: Data) -> Data {
        var thumbnail: Data?
        
        if let originalImage = UIImage(data: image) {
            let originalSize = originalImage.size;
            var scaleFactor: CGFloat = 1;
            
            //only scale if image is wider than 200px
            if originalSize.width > 200 {
                scaleFactor = 200 / originalSize.width
            }
            
            let newSize = CGSize(width: originalSize.width * scaleFactor, height: originalSize.height * scaleFactor);
            
            UIGraphicsBeginImageContext(newSize);
            var newFrame = CGRect.zero;
            newFrame.size = newSize;
            originalImage.draw(in: newFrame)
            
            if let shrunkImage = UIGraphicsGetImageFromCurrentImageContext() {
                thumbnail = UIImagePNGRepresentation(shrunkImage)
            }
            UIGraphicsEndImageContext();
        }
        
        if let thumbnail = thumbnail {
            return thumbnail
        }
        else{
            print("create thumbnail failed!")
            return Data()
        }
    }
}

