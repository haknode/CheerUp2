//
//  StorageServiceTest.swift
//  CheerUp
//
//  Created by stefan on 04/03/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import XCTest
@testable import CheerUp

class StorageServiceTest: XCTestCase {
    
    var storage = StorageService()

    override func setUp() {
        super.setUp()
        
        storage.save(image: Image(data: Data(bytes: [1,1]), id: "testId1", type: .gif, source: .giphy, shareUrl: ""))
        storage.save(image: Image(data: Data(bytes: [2,2]), id: "testId2", type: .other, source: .imgur, shareUrl: ""))
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLoad() {
        let image1 = storage.loadImage(withId: "testId1")
        
        assert(image1 != nil)
        assert(image1?.id == "testId1")
        assert(image1?.data == Data(bytes: [1,1]))
        assert(image1?.type == .gif)
        assert(image1?.source == .giphy)
        
        let image2 = storage.loadImage(withId: "testId2")
        
        assert(image2 != nil)
        assert(image2?.id == "testId2")
        assert(image2?.data == Data(bytes: [2,2]))
        assert(image2?.type == .other)
        assert(image2?.source == .imgur)
    }
    
    func testRemove() {
        storage.remove(withId: "testId1")
        let image1 = storage.loadImage(withId: "testId1")
        assert(image1 == nil)
        
        let image2 = storage.loadImage(withId: "testId2")
        storage.remove(image: image2!)
        let image3 = storage.loadImage(withId: "testId2")
        assert(image3 == nil)
    }
    
    func testLoadRandom() {
        let image1 = storage.loadRandom()
        
        assert(image1?.id == "testId1" || image1?.id == "testId2")
    }
}
