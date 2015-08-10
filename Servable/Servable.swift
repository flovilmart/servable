//
//  Servable.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation

public protocol Servable {
    func handle(request:Request,response:Response, next:dispatch_block_t)
}

extension Array:Servable {
    public func handle(request: Request, response: Response, next: dispatch_block_t) {
        var a = self
        if a.count > 0 , let servable = a.removeAtIndex(0) as? Servable  {
            servable.handle(request, response: response, next: {() -> Void in
                a.handle(request, response: response, next: next)
                return
            })
        }else{
            next()
        }
    }
}

public protocol ServablesType:Servable {
    var servables:[Servable] {get set}
}

public extension ServablesType {

    mutating func use(servable:Servable) {
        servables.append(servable)
    }

    func handle(request: Request, response: Response, next: dispatch_block_t) {
        self.servables.handle(request, response: response, next: next)
    }

}

// Struct for wrapping array of servables and process all
public struct Servables:ServablesType {
    public var servables = [Servable]()
    
    public init(){}
    
    public init(servables array:[Servable]) {
        servables = array
    }
    
    mutating func use(servable:Servable) {
        self.append(servable)
    }
    
    mutating func append(servable:Servable) {
        servables.append(servable)
    }
    
    public func handle(request:Request,response:Response, next:dispatch_block_t) {
        if servables.count > 0 {
            // Copy the array
            var a = servables
            // Pop
            let servable = a.removeAtIndex(0)
            // New S with current array
            let s = Servables(servables: a)
            servable.handle(request, response: response, next: { () -> Void in
                s.handle(request, response: response, next: next)
            })
        }else{
            next()
        }
    }
}
