//
//  Response.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation


public protocol Response {
    var connection:Connection {get set}
    var flushed:Bool {get set}
    func success()
    func error()
    func write(string:String)
    func send(string:String)
    func flush()
}

public class HTTPResponse:Response {
    var status:Int = 200
    var body:String = "" 
    public var connection:Connection
    
    public var flushed:Bool = false
    public init(connection aConnection:Connection) {
        connection = aConnection
    }
    
    public func write(string:String) {
        body+=string
    }
    
    public func send(string:String) {
        body = string
        status = 200
        self.flush()
    }
    
    public func flush() {
        if flushed { return }
        flushed = true
        let data = ("\(body)" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        self.connection.write(data)
    }
    
    public func success() {
        status = 200
        self.flush()
    }
    
    public func error() {
        status = 500
        self.flush()
        
    }
}


public extension HTTPResponse {
    public func sendStatus(aStatus:Int) {
        status = aStatus
        self.flush()
    }
}