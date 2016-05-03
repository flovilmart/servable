//
//  HTTPRequest.swift
//  Servable
//
//  Created by Florent Vilmart on 16-05-02.
//  Copyright © 2016 flovilmart. All rights reserved.
//
import Servable
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
