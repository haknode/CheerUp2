//
//  SettingsUITest.swift
//  CheerUp
//
//  Created by stefan on 04/03/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import XCTest

class SettingsUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        let image = elementsQuery.scrollViews.children(matching: .image).element
        image.swipeRight()
        
        XCTAssert(elementsQuery.buttons["Only Images"].exists)
        XCTAssert(elementsQuery.buttons["Both"].exists)
        XCTAssert(elementsQuery.buttons["Only Gifs"].exists)

        elementsQuery.buttons["add"].tap()
        app.alerts["Add Tags"].collectionViews.textFields["your tags"].typeText("test")
        app.alerts["Add Tags"].buttons["OK"].tap()
        
        XCTAssert(elementsQuery.collectionViews.staticTexts["test"].exists)
        
        let dustinButton = elementsQuery.buttons["dustin"]
        dustinButton.tap() 
    }
    
}
