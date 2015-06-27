//
//  Connection.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation


public protocol Connection {
    func read(inout data:NSData) -> Bool
    func write(data:NSData) -> Bool
    var ready:dispatch_block_t? {get set}
    var request:Request {get set}
    var response:Response {get set}
}