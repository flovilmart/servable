//
//  Request.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

//import Foundation

public enum Method:String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case HEAD = "HEAD"
    case OPTION = "OPTION"
    case ANY = "ANY"
}

public protocol Request {
    var connection: Connection { get set }
    var params: [String: String] { get set }
    var method: Method { get set }
    var path: String { get set }
    var currentPath: String { get set }
    var data: NSData? { get set }
    var body:String? { get set }
}

public class HTTPRequest: Request {
    
    public var connection:Connection
    public var params:[String:String] = [String:String]()
    public var method:Method = .GET
    
    public var path:String {
        didSet {
            self.currentPath = path
        }
    }
    private var _currentPath: String?
    public var currentPath:String {
        get {
            guard let _currentPath = _currentPath else {
                return path
            }
            return _currentPath
        }
        set {
            _currentPath = newValue
        }
    }
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