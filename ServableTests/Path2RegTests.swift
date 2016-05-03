//
//  Path2RegTests.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import XCTest
import Servable
class Path2RegTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        
        //Path2RegExp.parse("/hello/:world")
        //Path2RegExp.parse("/hello/*")
        
        let path = "/hello/:world/*"
        let options =  [String:AnyObject]()
        do{
            let result = try Path2RegExp.stringToRegexp(path, options: options)
            print(result.re)
            print(result.keys)
            XCTAssert(!result.test("/hello/a"))
            XCTAssert(result.test("/hello/a/b"))
            XCTAssert(result.test("/hello/a/b/c"))
            XCTAssert(result.test("/hello/world/"))
            //print(result)
        }catch let error {
            print(error)
        }
        //Path2RegExp.pathToRegexp("", keys: &keys, options: options)
        //Path2RegExp.pathToRegexp("/hello/:world/bla/bli", &keys, [String:AnyObject]())
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
