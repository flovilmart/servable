//
//  ServableTests.swift
//  ServableTests
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import XCTest
import Servable

class ServableTests: XCTestCase {
    
    var mockServer:MockServer?
    
    override func setUp() {
        super.setUp()
        
        mockServer = MockServer()
        mockServer?.listen(100)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMiddleWares() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expectation = expectationWithDescription("wait")
        let connection = MockConnection(string: "Hello Worlds")
        mockServer?.use(PassThrough())
        mockServer?.use(LongProcess.handle)
        mockServer?.use(PassThrough())
        mockServer?.handleConnection(connection) {
            expectation.fulfill()
            print("DONE!")
        }
        waitForExpectationsWithTimeout(20.0) { (error) -> Void in
            print("DONE!")
        }
    }
    
    func testGETRouter() {
        var router = MockRouter()
        router.get("/hello", RequestPrinter)
        router.post("/hello", RequestPrinter)
        mockServer?.use(router.handle)
        
        let expectation = expectationWithDescription("wait")
        let connection = GETConnection(string: "Hello Worlds", path:"/hello")
        connection.onWriteString = {(str) -> Void in
            
            XCTAssertEqual(str, connection.expected)
            expectation.fulfill()
            
        }
        
        mockServer?.handleConnection(connection) {}
        
        waitForExpectationsWithTimeout(20.0) { (error) -> Void in
            print("DONE!")
        }
    }
    
    func testPOSTRouter() {
        var router = MockRouter()
        router.get("hello", RequestPrinter)
        router.post("/hello2", RequestPrinter)
        router.post("/:a/:b/:c/:d", RequestPrinter)
        mockServer?.use(router.handle)
        
        let expectation = expectationWithDescription("wait")
        let connection = POSTConnection(string: "Hello Worlds", path:"/hello/world/I/love")
        connection.onWriteString = {(str) -> Void in
            
            XCTAssertEqual(str, "POST /hello/world/I/love Hello Worlds")

            
            
            expectation.fulfill()
        
        }
        mockServer?.handleConnection(connection) {}
        
        waitForExpectationsWithTimeout(20.0) { (error) -> Void in
            print("DONE!")
        }
    }
    
    func testRouterWithParameters() {
        var router = MockRouter()
        router.post("/:a/:b/:c/:d", RequestPrinter)
        mockServer?.use(router.handle)
        
        let expectation = expectationWithDescription("wait")
        let connection = POSTConnection(string: "Hello Worlds", path:"/hello/world/I/love")
        connection.onWriteString = {(str) -> Void in
            
            XCTAssertEqual(str, connection.expected)
            XCTAssertNotNil(connection.request.params)
            XCTAssertNotNil(connection.request.params["a"])
            XCTAssertNotNil(connection.request.params["b"])
            XCTAssertNotNil(connection.request.params["c"])
            XCTAssertNotNil(connection.request.params["d"])
            XCTAssertEqual(connection.request.params["a"]!, "hello")
            XCTAssertEqual(connection.request.params["b"]!, "world")
            XCTAssertEqual(connection.request.params["c"]!, "I")
            XCTAssertEqual(connection.request.params["d"]!, "love")
            expectation.fulfill()
            
        }
        mockServer?.handleConnection(connection) {}
        
        waitForExpectationsWithTimeout(20.0) { (error) -> Void in
            print("DONE!")
        }
    }
    
    func testNestedRouter() {
        var mockRouter = MockRouter()
        var nestedRouter = MockRouter()
        var nestedRouter2 = MockRouter()
        
        
        
        nestedRouter2.get("/love", RequestPrinter)
        nestedRouter.get("/:world", nestedRouter2.handle)
        nestedRouter.get("/a", nestedRouter2.handle)
        mockRouter.get("/hello", nestedRouter.handle)
        
        mockServer?.use(mockRouter.handle)
        
        let expectation = expectationWithDescription("wait")
        let connection = GETConnection(string: "Hello Worlds", path:"/hello/a/love")
        connection.onWriteString = {(str) -> Void in
            
            XCTAssertEqual(str, connection.expected)
            expectation.fulfill()
            
        }
        mockServer?.handleConnection(connection) {}
        
        waitForExpectationsWithTimeout(20.0) { (error) -> Void in
            print("DONE!")
        }
        
    }
    
    func testANYRouter() {
        var router = MockRouter()
        router.all("/hello", RequestPrinter)
        mockServer?.use(router.handle)
        
        let expectation = expectationWithDescription("wait")
        let connection = POSTConnection(string: "Hello Worlds", path:"/hello")
        connection.onWriteString = {(str) -> Void in
            
            XCTAssertEqual(str, connection.expected)
            expectation.fulfill()
            
        }
        mockServer?.handleConnection(connection) {}
        
        waitForExpectationsWithTimeout(20.0) { (error) -> Void in
            print("DONE!")
        }
    }
    
    func testComplexNesting() {
        var otherRouter = MockRouter()
        otherRouter.get("/world", RequestPrinter)
        
        
        var otherServer = MockServer()
        otherServer.use(otherRouter.handle)
        
        var router = MockRouter()
        router.all("/hello", otherServer.handle)
    
        mockServer?.use(router)
        let expectation = expectationWithDescription("wait")
        let connection = GETConnection(string: "Hello Worlds", path:"/hello/world")
        connection.onWriteString = {(str) -> Void in
            
            XCTAssertEqual(str, connection.expected)
            expectation.fulfill()
            
        }
        mockServer?.handleConnection(connection) {}
        
        waitForExpectationsWithTimeout(20.0) { (error) -> Void in
            print("DONE!")
        }
    }
    
}
