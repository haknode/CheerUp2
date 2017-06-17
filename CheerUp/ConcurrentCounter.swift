//
//  ConcurrentCounter.swift
//  CheerUp
//
//  Created by stefan on 13/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

///a threadsave counter
class ConcurrentCounter {
    private var queue = DispatchQueue(label: "concurrent.counter.1")
    private (set) var value: Int = 0
    
    func increment() {
        queue.sync {
            value += 1
            print("inc: \(value)")
        }
    }
    
    func decrement() {
        queue.sync {
            value -= 1
            print("dec: \(value)")
        }
    }
}
