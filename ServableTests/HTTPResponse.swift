//
//  HTTPResponse.swift
//  Servable
//
//  Created by Florent Vilmart on 16-05-02.
//  Copyright © 2016 flovilmart. All rights reserved.
//

import Servable

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
