//
//  SettingsService.swift
//  CheerUp
//
//  Created by stefan on 03/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import Foundation

class SettingsService{
    
    public static let sharedInstance = SettingsService()
    
    let tagsKey = "tags"
    let sliderValueKey = "slidervalue"
    
    private var userDefaults = UserDefaults.standard
    
    private var selectedTags : [String]?
    
    private lazy var defaultTags : [String:Bool] = ["cat":true,
                                                    "dog":true,
                                                    "aww":false,
                                                    "cute":false,
                                                    "funny":false,
                                                    "kitten":true,
                                                    "corgi":true,
                                                    "koala":false,
                                                    "sloth":true,
                                                    "puppy":true,
                                                    "owl":true,
                                                    "parrot":true,
                                                    "bird":true,
                                                    "panda":true,
                                                    "animal":true,
                                                    "hedgehog":true,
                                                    "seal":true,
                                                    "hamster":true,
                                                    "rabbit":true,
                                                    "guineapig":true,
                                                    "adorable":true,
                                                    "meow":true,
                                                    "pig":false,
                                                    "doggo":true,
                                                    "fluffy":false,
                                                    "pug":true,
                                                    "poodle":true,
                                                    "turtle":true]

    private var defaultSliderValue = 2
    
    public func setSliderValue(_ value : Int){
        userDefaults.set(value, forKey: sliderValueKey)
    }
    
    public func getSliderValue() -> Int {
        if let value = userDefaults.value(forKey: sliderValueKey) as? Int {
            return value
        }
        return 2
    }
    
    ///returns all tags
    ///if no tags are saved yet, a default dictionary is returned
    public func getTags() -> [String:Bool] {
        if let tags = userDefaults.value(forKey: tagsKey) as? [String:Bool]{
            return tags
        }
        else {
            return defaultTags
        }
    }
    
    ///saves the given tags dictionary
    public func setTags(tags: [String:Bool]){
        userDefaults.set(tags, forKey: tagsKey)
        
        updateSelectedTags()
    }
    
    ///returns an array with only enabled tags
    public func getSelectedTags() -> [String]{
        if selectedTags == nil {
            updateSelectedTags()
        }
        
        return selectedTags!
    }
    
    ///adds all enabled tags to the selected tags array
    private func updateSelectedTags(){
        selectedTags = [String]()
        
        for tag in getTags(){
            if tag.value == true {
                selectedTags?.append(tag.key)
            }
        }
    }
}
