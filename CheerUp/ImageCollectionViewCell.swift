//
//  ImageCollectionViewCell.swift
//  CheerUp
//
//  Created by stefan on 01/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import UIKit
import Gifu

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var gifImageView: GIFImageView!
    
    var border : CALayer?
    var markedsymbol : CALayer?
    var playsymbol : CALayer?
    
    var isGif = false   // doesnt work
    
    ///sets the full image (or the gif) as image
    public func setImage(fromImage image: Image){
        if image.type == .gif{
            gifImageView.animate(withGIFData: image.data)
            isGif = true
        }
        else if image.type == .other{
            if gifImageView.isAnimatingGIF {
                gifImageView.stopAnimatingGIF()
            }
            gifImageView.image = UIImage(data: image.data)
        }
        
        isHighlited(highlited: false)   //not highlited as default
    }
    
    ///sets the thumbnail as the image
    public func setImage(fromMetadata metadata: ImageMetadata){
        gifImageView.image = UIImage(data: metadata.thumbnail)
        
        isHighlited(highlited: false)    //not highlited as default
    }
    
    public func toggleEditMode(editmode: Bool){
        addBorderAndImageView()
        if editmode {
            isHighlited(highlited: false)
        }
        else {
            isHighlited(highlited: false)
            markedsymbol?.contents = nil
            border?.isHidden = true
        }
        
    }
    
    public func addBorderAndImageView(){
        if border == nil {
            border = CALayer()
            
            border!.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            border!.backgroundColor = UIColor.white.cgColor
            border!.opacity = 0.2
            gifImageView.layer.addSublayer(border!)
            
            let size = CGFloat(20)
            
            markedsymbol = CALayer()
            markedsymbol?.frame = CGRect(x: 0, y: 0, width: size, height: size)
            markedsymbol?.frame.origin.x = self.bounds.width - size
            markedsymbol?.frame.origin.y = self.bounds.height - size
            markedsymbol?.frame.size = CGSize(width: size, height: size)
            gifImageView?.layer.addSublayer(markedsymbol!)
            
            if isGif {
            
                playsymbol = CALayer()
                playsymbol?.frame = CGRect(x: 0, y: 0, width: size, height: size)
                playsymbol?.frame.origin.x = 0
                playsymbol?.frame.origin.y = gifImageView.bounds.height - size
                playsymbol?.frame.size = CGSize(width: size, height: size)
            
                gifImageView?.layer.addSublayer(playsymbol!)
            }
        }
    }
    
    ///displays a visual indication weather this cell is selected or not
    public func isHighlited(highlited: Bool){
        addBorderAndImageView()
        if highlited{
            border?.isHidden = false
            markedsymbol?.contents = #imageLiteral(resourceName: "markfilled.png").cgImage
        }
        else {
            border?.isHidden = false
            markedsymbol?.contents = #imageLiteral(resourceName: "mark.png").cgImage
        }
    }
}
