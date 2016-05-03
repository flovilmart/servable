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
