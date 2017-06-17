//
//  SettingsViewController.swift
//  CheerUp
//
//  Created by stefan on 03/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    
    var editModeEnabled = false
    var tags = [String: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        
        //if estimatedItemSize is set once (no matter which value) the cells will autosize to the content
        flowLayout.estimatedItemSize = CGSize(width: 100, height: 25)
        //flowLayout.sectionInset.top = 64
        
        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom != .pad {
            print("Landscape")
            
            if Display.typeIsLike == .iphone7plus{
                viewTopConstraint.constant = 44
                
            }
            else{
                viewTopConstraint.constant = 32
                
            }
        } else{
            print("Portrait")
            
            viewTopConstraint.constant = 64
        }
        
        editButton.setImage(UIImage(named: "dustin.png")?.withRenderingMode(.alwaysOriginal), for: .normal)
        editButton.setImage(UIImage(named: "dustbinfilled.png")?.withRenderingMode(.alwaysOriginal), for: .selected)

        tags = SettingsService.sharedInstance.getTags()
        segmentControl.selectedSegmentIndex = SettingsService.sharedInstance.getSliderValue()
        
        tagCollectionView.layoutIfNeeded()
    }

    //load the current tags from the settings
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        
        setEditMode(false)
        updateViewToEditMode()
    }
    
    //save the tags to the settings
    override func viewWillDisappear(_ animated: Bool) {
        SettingsService.sharedInstance.setTags(tags: tags)
        SettingsService.sharedInstance.setSliderValue(segmentControl.selectedSegmentIndex)
        
        super.viewWillDisappear(animated)
    }
    
    //returns the flow layout of the tagCollectionView
    var flowLayout :UICollectionViewFlowLayout{
        return tagCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    @IBAction func editButtonOnClick(_ sender: Any) {
        toggleEditMode()
        updateViewToEditMode()
    }
    
    func toggleEditMode() {
        editModeEnabled = !editModeEnabled
    }
    
    func setEditMode(_ edit: Bool) {
        self.editModeEnabled = edit
    }
    
    func updateViewToEditMode() {
        if editModeEnabled {
            addButton.isHidden = true
            deleteButton.isHidden = true
            
            editButton.isSelected = true
        }
        else {
            addButton.isHidden = false
            deleteButton.isHidden = true
            
            editButton.isSelected = false
        }
    
        tagCollectionView.reloadData()
        //tagCollectionView.reloadItems(at: tagCollectionView.indexPathsForVisibleItems)
    }
    
    @IBAction func addButtonOnClick(_ sender: Any) {
        let alert = UIAlertController(title: "Add Tags", message: "Enter your tags seperated by spaces", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: "your tags")
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let textField = alert.textFields![0]
            
            let newTags = textField.text?.components(separatedBy: [" ", ",", "."])
            
            if let newTags = newTags {
                for newTag in newTags{
                    if newTag != " " && newTag != "" {
                        self.tags[newTag] = true
                    }
                }

                self.tagCollectionView.dataSource = nil
                self.tagCollectionView.dataSource = self
                
                self.tagCollectionView.reloadData()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCollectionViewCell
        
        let tagName = Array(tags.keys)[indexPath.row]
        
        cell.text = tagName
        cell.tagSelected = tags[tagName]!
        cell.editMode = editModeEnabled
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! TagCollectionViewCell
        if let tag = cell.text {
            if editModeEnabled {
                self.tags.removeValue(forKey: tag)
                collectionView.deleteItems(at: [indexPath])
                
            }
            else{
                self.tags[tag] = !cell.tagSelected
                cell.tagSelected = !cell.tagSelected
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom != .pad {
            print("Landscape")
            
            if Display.typeIsLike == .iphone7plus{
                viewTopConstraint.constant = 44

            }
            else{
                viewTopConstraint.constant = 32

            }
        } else{
            print("Portrait")
            
            viewTopConstraint.constant = 64
        }
    }

}
