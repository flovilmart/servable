//
//  Servables.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-08-11.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation


public protocol Servables: Servable {
    var servables:[Servable] {get set}
}

public extension Servables {

    mutating func use(servable:Servable) {
        servables.append(servable)

    }

    func handle(request: Request, response: Response, next: dispatch_block_t) {
        return handleArray(servables, request: request, response: response, next: next)
    }
}

public func handleArray(array: [Servable], request: Request, response: Response, next: dispatch_block_t) {
    if array.count == 0 {
        next()
        return
    }
    var this = array
    let servable = this.removeAtIndex(0)
    servable.handle(request, response: response, next: {
        handleArray(this, request: request, response: response, next: next)
    })
}
