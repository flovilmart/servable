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

// Struct for wrapping array of servables and process all
public struct Servables {
    var array = [Servable]()
    
    public init(){}
    
    mutating func append(servable:Servable) {
        array.append(servable)
    }
    
    mutating func doAll(request:Request,response:Response, next:dispatch_block_t) {
        if array.count > 0 {
            let servable = array.first
            array.removeAtIndex(0)
            servable?.handle(request, response: response, next: { () -> Void in
                self.doAll(request, response: response, next: next)
            })
        }else{
            next()
        }
    }
}

// Stack of servables base of router and server
public protocol ServableStack : Servable {
    var stack:Servables {get set}
}

public extension ServableStack {
    
    mutating func use(servable:Servable) {
        stack.append(servable)
    }
    
    func handle(request: Request,response: Response, next: dispatch_block_t) {
        var theStack = stack
        theStack.doAll(request, response: response, next: {() -> Void in
            if response.flushed == false {
                response.error()
            }
            next()
        })
    }
}