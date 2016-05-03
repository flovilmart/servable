//
//  Servables.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-08-11.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation

public protocol Servables: Servable {
    var handlers:[ServableHandler] {get set}
}

public extension Servables {

    mutating func use(servable: Servable) {
        handlers.append(servable.handle)
    }

    mutating func use(servable: ServableHandler) {
        handlers.append(servable)
    }

    func handle(request: Request, response: Response, next: dispatch_block_t) {
        return handleArray(handlers, request: request, response: response, next: next)
    }
}

private func handleArray(handlers: [ServableHandler], request: Request, response: Response, next: dispatch_block_t) {
    if handlers.count == 0 {
        next()
        return
    }
    var nextHandlers = handlers
    nextHandlers.removeAtIndex(0)(request: request, response: response) {
        handleArray(nextHandlers, request: request, response: response, next: next)
    }
}
