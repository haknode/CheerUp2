//
//  ArrayExtension.swift
//  CheerUp
//
//  Created by stefan on 08/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

extension Array {
    
    ///enqueues element at the back of the array
    mutating func enqueue(_ item: Element) {
        self.append(item)
    }
    
    ///dequeues elemnt from the front of the array
    mutating func dequeue() -> Element? {
        return self.isEmpty ? nil : self.remove(at: 0)
    }
    
    func randomElement() -> Element? {
        if self.count == 0 {
            return nil
        }
        
        let randomIndex = Int(arc4random_uniform(UInt32(self.count)))
        
        return self[randomIndex]
    }
    
    mutating func getAndRemoveRandomElement() -> Element? {
        if self.count == 0 {
            return nil
        }
        
        let randomIndex = Int(arc4random_uniform(UInt32(self.count)))
        
        let item = self[randomIndex]
        
        self.remove(at: randomIndex)
        
        return item
    }
}
