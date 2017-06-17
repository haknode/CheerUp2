//
//  TagCollectionViewCell.swift
//  CheerUp
//
//  Created by stefan on 03/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tagLabel: UILabel!
    
    //true if the tag is selected, false if the tag is not selected
    var tagSelected :Bool = true {
        didSet{
            updateButtonState()
        }
    }
    var editMode :Bool = false {
        didSet{
            updateEditState()
        }
    }

    //sets or gets the text of the tag
    var text :String? {
        get{
            return tagLabel.text
        }
        set{
            if newValue != nil{
                tagLabel.text = newValue
                
                self.layer.cornerRadius = 8
            }
        }
    }
    
    //sets the button style depending on the tag selection state
    private func updateButtonState(){
        let bluecolor = UIColor(red: 1, green: 149.0/255, blue: 0, alpha: 1)
        if tagSelected{
            self.backgroundColor = bluecolor
            self.tagLabel.textColor = UIColor.white
            self.layer.borderWidth = 1
            self.layer.borderColor = bluecolor.cgColor
        }
        else{
            self.backgroundColor = UIColor.white
            self.tagLabel.textColor = bluecolor
            self.layer.borderWidth = 1
            self.layer.borderColor = bluecolor.cgColor
        }
    }
    
    private func updateEditState() {
        if editMode {
            let bluecolor = UIColor(red: 1, green: 59.0/255, blue: 48.0/255, alpha: 1)
            self.backgroundColor = bluecolor
            self.tagLabel.textColor = UIColor.white
            self.layer.borderWidth = 1
            self.layer.borderColor = bluecolor.cgColor
        }
        else {
            updateButtonState()
        }
    }
}
