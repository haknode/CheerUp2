//
//  ScrollViewController.swift
//  CheerUp
//
//  Created by Hannes  on 22/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ScrollingViewController: UIViewController, UIScrollViewDelegate {
    
    var vc0 : UIViewController!
    var vc1 : UIViewController!
    var vc2 : UIViewController!
    
    static var instance: ScrollingViewController?
    
    var interstitial: GADInterstitial!
    var counter = 0
    
    var scrollBarDisabled = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    var layer = CAShapeLayer()
    
    @IBAction func favouritesClicked(_ sender: Any) {
        self.scrollView.scrollRectToVisible(CGRect(x: self.view.frame.width * 2, y: 0, width: self.view.frame.width, height: self.view.frame.height), animated: true)
    }
    
    @IBAction func settingsClicked(_ sender: Any) {
        self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), animated: true)
    }
    
    @IBAction func titleClicked(_ sender: Any) {
        self.scrollView.scrollRectToVisible(CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height), animated: true)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        ScrollingViewController.instance = self
        
        scrollView.delegate = self
        
        // Add Views to ScrollView
        
        vc0 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsVC") as UIViewController
        
        self.addChildViewController(vc0)
        self.scrollView.addSubview(vc0.view)
        vc0.didMove(toParentViewController: self)
        
        vc1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GifVC") as UIViewController
        
        var frame1 = vc1.view.frame
        frame1.origin.x = self.view.frame.size.width
        frame1.size = self.view.frame.size
        vc1.view.frame = frame1
        
        self.addChildViewController(vc1)
        self.scrollView.addSubview(vc1.view)
        vc1.didMove(toParentViewController: self)
        
        vc2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as UIViewController
        
        var frame2 = vc2.view.frame
        frame2.origin.x = self.view.frame.size.width * 2
        vc2.view.frame = frame2
        
        self.addChildViewController(vc2)
        self.scrollView.addSubview(vc2.view)
        vc2.didMove(toParentViewController: self)
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width * 3, height: self.view.frame.size.height - 66)
        self.automaticallyAdjustsScrollViewInsets = false   // This is/was a real pain in the ass I tell ya

        self.scrollView.contentOffset.x = self.view.frame.size.width
        
        
        // Custom Title
        
        //let shadow = NSShadow()
        //shadow.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        //shadow.shadowOffset = CGSize(width: 1, height: 1)
        /*let titleDict: NSDictionary =
            [NSForegroundColorAttributeName: UIColor.white,
             /*NSShadowAttributeName : shadow ,*/ NSFontAttributeName : UIFont.systemFont(ofSize: 28) , /*UIFontDescriptorFamilyAttribute : UIFont.fontNames(forFamilyName: "HelveticaNeue-CondensedBlack"),*/ NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: "-1.0"] */// the fact that we dont use this anymore makes me sad
        let titleButton = UIButton(type: .custom)
        //titleButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        titleButton.addTarget(self, action: #selector(titleClicked(_:)), for: .touchUpInside)
        //titleButton.setAttributedTitle(NSAttributedString(string: "cheerup", attributes: titleDict as? [String : Any]), for: .normal)
        
        titleButton.setImage(#imageLiteral(resourceName: "font.png"), for: .normal)
        titleButton.frame = CGRect(x: 0, y: 0, width: 60, height: 28)
        titleButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        self.navigationItem.titleView = titleButton
        
        // Custom NavButtons
        
        let settingsButton = UIButton(type: UIButtonType.custom)
        
        settingsButton.setImage(#imageLiteral(resourceName: "settings.png"), for: UIControlState.normal)
        settingsButton.addTarget(self, action: #selector(settingsClicked(_:)), for: UIControlEvents.touchUpInside)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        
        let settings = UIBarButtonItem(customView: settingsButton)

        let favouritesButton = UIButton(type: UIButtonType.custom)
        
        favouritesButton.setImage(#imageLiteral(resourceName: "favourites.png"), for: UIControlState.normal)
        favouritesButton.addTarget(self, action: #selector(favouritesClicked(_:)), for: UIControlEvents.touchUpInside)
        favouritesButton.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        
        let favourites = UIBarButtonItem(customView: favouritesButton)

        self.navigationItem.leftBarButtonItem = settings
        self.navigationItem.rightBarButtonItem = favourites
        
        //let context = UIGraphicsGetCurrentContext()
        //let blackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        //context?.addLines(between: [CGPoint(x: 100, y: 100), CGPoint(x: 200, y: 200)])

        createAndLoadInterstitial()
    }
 
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.layer.addSublayer(layer)
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        let index = Int(scrollView.contentOffset.x/self.view.frame.width)
        
        vc1.view.frame.origin.x = self.view.frame.size.height
        vc2.view.frame.origin.x = self.view.frame.size.height * 2
        
        let inset = getNavBarInset()
        
        print("Offsetfun: \(index)")
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.height * 3, height: self.view.frame.size.width - inset)
        
        self.scrollView.contentOffset.x = CGFloat(index) * self.view.frame.height
        
        vc0.view.frame.size = CGSize(width: self.view.frame.height, height: self.view.frame.width)
        vc1.view.frame.size = CGSize(width: self.view.frame.height, height: self.view.frame.width)
        vc2.view.frame.size = CGSize(width: self.view.frame.height, height: self.view.frame.width)
        
        drawScollBar(alpha: scrollView.contentOffset.x/self.view.frame.height / 2, screenWidth: self.view.frame.height)
        
        vc0.viewWillTransition(to: size, with: coordinator)
        vc1.viewWillTransition(to: size, with: coordinator)
        vc2.viewWillTransition(to: size, with: coordinator)
    
    }
    
    func getNavBarInset() -> CGFloat {
        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom != .pad {
            if Display.typeIsLike == .iphone7plus{
                return 44
            }
            return 32
        }
        else{
            return 64
        }
    }
    
    func drawScollBar(alpha: CGFloat, screenWidth: CGFloat){
        
        if scrollBarDisabled {
            layer.path = nil
            return
        }
        
        let aPath = UIBezierPath()
        
        var beginning = alpha * (screenWidth - 60) + 30
        let width : CGFloat = 210.0 * ((sin(alpha * CGFloat(M_PI)))/2.0+0.20)
        
        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom != .pad && Display.typeIsLike != .iphone7plus {
            beginning = alpha * (screenWidth - 68) + 34
            
            aPath.move   (to: CGPoint(x: beginning - width/2, y: 31))
            aPath.addLine(to: CGPoint(x: beginning + width/2, y: 31))
            aPath.addLine(to: CGPoint(x: beginning + width/2, y: 32))
            aPath.addLine(to: CGPoint(x: beginning - width/2, y: 32))
            
            print("Slider says Landscape")
        }
        else {
            aPath.move   (to: CGPoint(x: beginning - width/2, y: 43))
            aPath.addLine(to: CGPoint(x: beginning + width/2, y: 43))
            aPath.addLine(to: CGPoint(x: beginning + width/2, y: 44))
            aPath.addLine(to: CGPoint(x: beginning - width/2, y: 44))
            
            print("Slider says Portrait")
        }
        
        aPath.close()
        
        UIColor.red.set()
        aPath.stroke()
        aPath.fill()
        
        layer.path = aPath.cgPath
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = UIColor.black.cgColor
    }
    
    func disableScrollBar(){
        scrollBarDisabled = true
        drawScrollBar(1)
    }
    
    func enableScrollBar(){
        scrollBarDisabled = false
        drawScrollBar(1)
    }
    
    func drawScrollBar(_ alpha: CGFloat){
        drawScollBar(alpha: alpha, screenWidth: self.view.frame.width)
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       // print("scrolled: \(scrollView.contentOffset.x/self.view.frame.width / 2)")
        drawScrollBar(scrollView.contentOffset.x/self.view.frame.width / 2)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/self.view.frame.width)
        
        if index == 0 {
            vc0.viewWillAppear(false);
            vc1.viewWillDisappear(false);
            vc2.viewWillDisappear(false);
        }
        else if index == 1 {
            vc0.viewWillDisappear(false);
            vc1.viewWillAppear(false);
            vc2.viewWillDisappear(false);
        }
        else {
            vc0.viewWillDisappear(false);
            vc1.viewWillDisappear(false);
            vc2.viewWillAppear(false);
        }
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    func resetCounter() {
        counter = 0
    }
    
    func incrementCounter() {
        counter += 1
        if counter > 40 {
            if showInterstitial() {
                resetCounter()
                createAndLoadInterstitial()
            }
        }
        print("Counter: \(counter)")
    }
    
    func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-2296986015518482/3196629052")
        let request = GADRequest()
        // request.testDevices = []
        interstitial.load(request)
    }
    
    func showInterstitial() -> Bool {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            return true
        }
        print("Ad wasn't ready")
        return false
    }
}
