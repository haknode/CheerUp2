//
//  ImageViewController.swift
//  CheerUp
//
//  Created by stefan on 01/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import UIKit
import Gifu

class ImageViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: GIFImageView!
    @IBOutlet weak var gifImageView: GIFImageView!
    
    @IBOutlet weak var addToFavoritesButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var infoLabel: UILabel!
    

    
    //var refreshControl: UIRefreshControl!
    
    let imageService = ImageService.sharedInstance
    let storage = StorageService.sharedInstance
    
    var currentImage: Image?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
        
        //TODO: if image has almost screen aspect ratio, use full screen instead of fit
        backgroundImageView.addBlurEffect()
        
        imageService.useStoredImagesIfCacheEmpty = false
        
        loadImage()
        
        //refreshControl = UIRefreshControl()
        //refreshControl.addTarget(self, action: #selector(reloadButtonOnClick(_:)), for: UIControlEvents.valueChanged)
        //imageScrollView.addSubview(refreshControl)

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(touch(_:)))
        singleTap.numberOfTapsRequired = 1
        gifImageView.addGestureRecognizer(singleTap)
        gifImageView.isUserInteractionEnabled = true
    }
    
    ///shows the navigation bar
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    ///hides the navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func reloadButtonOnClick(_ sender: Any) {
        infoLabel.isHidden = true

        loadImage()
        //refreshControl.endRefreshing()
    }
    @IBAction func touch(_ sender: Any) {
        reloadButtonOnClick(sender)
    }
    
    @IBAction func settingsButtonOnClicl(_ sender: Any) {
        performSegue(withIdentifier: "rootToSettings", sender: self)
    }
    
    @IBAction func favoritesButtonOnClick(_ sender: Any) {
        performSegue(withIdentifier: "rootToGallery", sender: self)
    }
    
    @IBAction func addToFavoritesButtonOnClick(_ sender: Any) {
        if let image = currentImage{
            if image.isFavorite{
                storage.remove(image: image)
                image.isFavorite = false
            }
            else{
                storage.save(image: image)
                image.isFavorite = true
            }
            
            setFavoriteStatus(isFavorite: image.isFavorite)
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
    
    ///loads a image from the imageProvider
    private func loadImage(){
        if !activityIndicator.isHidden {
            return
        }
        
        activityIndicator.isHidden = false
        
        //stopImage()
        
        imageService.requestImage(onCompletion: {(image, error) in
            
            if let image = image{
                self.playImage(image: image)
                ScrollingViewController.instance?.incrementCounter()
            }
            else if let error = error{
                switch error{
                case .generalError(let errorMsg):
                    print("error: \(errorMsg)")
                    self.showErrorImage()
                }
            }
            else{
                print("error: other Error")
                self.showErrorImage()
            }
            
        })
    }
    
    ///display the image in the imageImageView and the backgroundImageView
    public func playImage(image: Image){
        currentImage = image

        print("image size: \(image.data.count / 1024) kb")

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
        
        setFavoriteStatus(isFavorite: image.isFavorite)
        
        //TODO: use loadingIndicator from https://github.com/naoyashiga/RPLoadingAnimation
        activityIndicator.isHidden = true
    }
    
    ///stops animating the gif (if the image is a gif)
    public func stopImage(){
        gifImageView.stopAnimatingGIF()
        backgroundImageView.stopAnimatingGIF()
    }
    
    private func showErrorImage(){
        infoLabel.isHidden = false
        infoLabel.text = "No Internet Connection"
        
        activityIndicator.isHidden = true
    }
    
    ///sets the style of the star button depending on the favorite status
    func setFavoriteStatus(isFavorite: Bool){
        if isFavorite{
            addToFavoritesButton.setImage(#imageLiteral(resourceName: "starfilled.png"), for: .normal)
        }
        else{
            addToFavoritesButton.setImage(#imageLiteral(resourceName: "star.png"), for: .normal)
        }
    }
}
