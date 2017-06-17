//
//  GalleryViewController.swift
//  CheerUp
//
//  Created by stefan on 01/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//


import UIKit

class GalleryViewController: UIViewController, UICollectionViewDelegate, CBLUICollectionDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

   // @IBOutlet weak var editButton: UIBarButtonItem!
   // @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var storage = StorageService.sharedInstance
    
    var editMode = false
    
    var selectedElements = [IndexPath]()
    var indexPathForSegue: IndexPath?
    
    var collectionSource = CBLUICollectionSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        
        //setup datasource for collectionview and vice versa
        collectionView.dataSource = collectionSource
        collectionSource.collectionView = collectionView
        
        collectionSource.query = storage.loadAllLiveQuery()

        automaticallyAdjustsScrollViewInsets = false
        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom != .pad{
            if Display.typeIsLike == .iphone7plus{
                flowLayout.sectionInset.top = 44
            }
            else{
                flowLayout.sectionInset.top = 32
            }
        } else{
            flowLayout.sectionInset.top = 64
        }


        editButton.setImage(UIImage(named: "edit.png")?.withRenderingMode(.alwaysOriginal), for: .normal)
        editButton.setImage(UIImage(named: "editfilled.png")?.withRenderingMode(.alwaysOriginal), for: .selected)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        automaticallyAdjustsScrollViewInsets = false
        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom != .pad{
            if Display.typeIsLike == .iphone7plus{
                flowLayout.sectionInset.top = 44
            }
            else{
                flowLayout.sectionInset.top = 32
            }
        } else{
            flowLayout.sectionInset.top = 64
        }
    }

    //returns the flow layout of the tagCollectionView
    var flowLayout :UICollectionViewFlowLayout{
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    ///sets the ui to *not* editing mode
    override func viewWillAppear(_ animated: Bool) {
        editMode = false
        updateViewToEditMode()
        
        super.viewWillAppear(animated)

    }
    
    ///disables editig mode before the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        if editMode {
            toggleEditMode()
        }
        
        super.viewWillDisappear(animated)
    }
    
    @IBAction func deleteButtonOnClick(_ sender: Any) {
        do{
            try collectionSource.deleteDocuments(atIndexes: selectedElements)
        }catch let error as NSError{
            print("error: \(error)")
        }
        
        selectedElements.removeAll()
    }
    
    @IBAction func editButtonOnClick(_ sender: Any) {
        toggleEditMode()
    }

    
    ///toggles the editing mode and updates the ui acordingly
    func toggleEditMode(){
        editMode = !editMode
        
        updateViewToEditMode()
    }
 
    ///updates the ui elements acoring to the editing mode
    ///removes the selection from all selected elements
    func updateViewToEditMode(){
        if editMode{
            deleteButton.isHidden = false
            deleteButton.isEnabled = true
            editButton.isSelected = true
        }
        else{
            editButton.isSelected = false
            deleteButton.isHidden = true
            deleteButton.isEnabled = false
        }
        
        if selectedElements.count != 0 {
            for element in selectedElements {
                if let cell = collectionView.cellForItem(at: element) as? ImageCollectionViewCell{
                    cell.isHighlited(highlited: false)
                }
            }
            
            selectedElements.removeAll()
        }
        
        self.collectionView.reloadData()
    }
    
    ///return a image cell with the image fethed from the database
    ///method from CBLUICollectionDelegate
    func couchCollectionSource(_ source: CBLUICollectionSource, cellForRowAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        
        if let row = collectionSource.row(at: indexPath){
            if let image = StorageService.imageMetadataFromDocument(cblDocument: row.document){
                cell.setImage(fromMetadata: image)
                if editMode {
                    cell.toggleEditMode(editmode: true)
                }
                else {
                    cell.toggleEditMode(editmode: false)
                }
            }
        }
        
        return cell
    }
    
    ///called if an element is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if editMode{    //in editing mode, select/deselect the image
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
                if selectedElements.contains(indexPath){
                    selectedElements.remove(at: selectedElements.index(where: {$0 == indexPath})!)
                    
                    cell.isHighlited(highlited: false)
                }
                else{
                    selectedElements.append(indexPath)
                    
                    cell.isHighlited(highlited: true)
                }
            }
        }
        else{   //if not in editing mode, go to details vc for the selected iamge
            indexPathForSegue = indexPath
            performSegue(withIdentifier: "galleryToDetails", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = CGFloat(0)
        
        if UIDevice.current.orientation.isLandscape {
            width = UIScreen.main.bounds.height
        } else{
            width = UIScreen.main.bounds.width
        }
        
        return CGSize(width: (width - 3)/4, height: (width - 3) / 4)
    }
    ///set the currently selected image as image to display in the details vc
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "galleryToDetails", let indexPath = indexPathForSegue{
            if let vc = segue.destination as? GalleryDetailsViewController{
                vc.imageSource = collectionSource
                vc.imageSourceRow = UInt(indexPath.item)
            }
        }
    }
}
