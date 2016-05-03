//
//  MockConnection.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-27.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation

import Servable

class MockConnection:Connection {
    
    var ready:dispatch_block_t?
    lazy var request:Request =  HTTPRequest(connection: self, path:self.path)
    lazy var response:Response = HTTPResponse(connection: self)
    
    var contents:String
    var path:String
    var onWrite:((NSData) -> Void)?
    var onWriteString:((String) -> Void)?
    init(string:String, path aPath:String = "") {
        contents = string
        path = aPath
    }
    
    func read(inout data:NSData) -> Bool {
        data = (contents as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        return true
    }
    func write(data:NSData) -> Bool {
        let str = NSString(data: data, encoding: NSUTF8StringEncoding)
        print("\(str)")
        if let onWrite = onWrite {
            onWrite(data)
        }
        if let onWriteString = onWriteString {
            onWriteString(str as! String)
        }
        return true
    }
    
    var expected:String {
        return "\(self.request.method.rawValue) \(self.request.path) \(self.contents)"
    }
}

class GETConnection:MockConnection {
    override init(string: String, path:String = "") {
        super.init(string: string, path:path)
        self.request.method = .GET
    }
}

class POSTConnection:MockConnection {
    override init(string: String, path:String = "") {
        super.init(string: string, path:path)
        self.request.method = .POST
    }
}