//
//  GalleryDetailsViewController.swift
//  CheerUp
//
//  Created by stefan on 12/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import UIKit
import Gifu

class GalleryDetailsViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: GIFImageView!
    @IBOutlet weak var gifImageView: GIFImageView!
    
    var imageSource: CBLUICollectionSource?
    var imageSourceRow: UInt = 0
    
    var currentImage: Image?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImageView.addBlurEffect()
        
        if let imageRow = imageSource?.row(at: imageSourceRow){
            if let image = StorageService.imageFromDocument(cblDocument: imageRow.document){
                playImage(image: image)
            }
        }
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        
        leftSwipeGestureRecognizer.direction = .left
        rightSwipeGestureRecognizer.direction = .right
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        if let scrollVC = ScrollingViewController.instance {
            scrollVC.disableScrollBar()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let scrollVC = ScrollingViewController.instance {
            scrollVC.enableScrollBar()
        }
    }
    
    private func playImage(image: Image){

        currentImage = image
        
        if image.type == .gif{
            gifImageView.animate(withGIFData: image.data)
            backgroundImageView.animate(withGIFData: image.data)
            
        }
        else if image.type == .other{
            if gifImageView.isAnimatingGIF {
                gifImageView.stopAnimatingGIF()
            }
            if backgroundImageView.isAnimatingGIF {
                backgroundImageView.stopAnimatingGIF()
            }
            
            let image = UIImage(data: image.data)
            gifImageView.image = image
            backgroundImageView.image = image
        }
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer){
        
        var newRow = imageSourceRow
        
        if sender.direction == .right{
            print("swipe right")
            
            if newRow > 0{
                newRow -= 1
            }
        }
        else if sender.direction == .left{
            print("swipe left")
            
            if let sourceRows = imageSource?.rows {
                if sourceRows.count == 0{
                    return
                }
                
                if newRow < UInt(sourceRows.count-1){
                    newRow += 1
                }
            }
        }
        
        if let imageRow = imageSource?.row(at: newRow){
            if let image = StorageService.imageFromDocument(cblDocument: imageRow.document){
                imageSourceRow = newRow
                
                playImage(image: image)
            }
        }
        
    }
    
    ///TODO: how to share images?
    @IBAction func shareButtonOnClick(_ sender: Any) {
        if currentImage?.type == .gif {
            if let url = currentImage?.shareUrl{
                let activityItem: [AnyObject] = [url as AnyObject]
                
                let activityVC = UIActivityViewController(activityItems:  activityItem as [AnyObject], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
        }
        else{
            if let image = gifImageView.image{
                let activityItem: [AnyObject] = [image as AnyObject]
                
                let activityVC = UIActivityViewController(activityItems:  activityItem as [AnyObject], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
}
