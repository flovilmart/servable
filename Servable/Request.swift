//
//  Request.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation

public enum Method:String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case HEAD = "HEAD"
    case ANY = "ANY"
}

public class Request {
    
    public var connection:Connection
    public var params:[String:String] = [String:String]()
    public var method:Method?
    
    public var path:String? {
        didSet {
            self.currentPath = path
        }
    }
    public var currentPath:String?
    public var body:String?
    public var data:NSData?
    
    public init(connection aConnection:Connection, path:String) {
        connection = aConnection
        self.path = path
        self.currentPath = path
        var data:NSData = NSData()
        connection.read(&data)
        self.parseData(data)
        
    }
    
    func parseData(data:NSData) {
        self.body = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
    }
}