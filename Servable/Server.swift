//
//  Server.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation

public protocol Server:Servables {
    func listen(port:Int)
    func handleConnection(connection:Connection, next: dispatch_block_t)
}


public extension Server {
    func handleConnection(connection:Connection, next: dispatch_block_t) {
        return handle(connection.request, response:connection.response, next: next)
    }
}

