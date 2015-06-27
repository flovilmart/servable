//
//  Router.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation

public protocol Router:ServableStack { }

public extension Router {
    
    mutating func add(method:Method, path:String, servable:Servable) {
        stack.append(Route(method: method, path: path, servable:servable))
    }
    
    mutating func all(path:String, servable:Servable) {
        add(.ANY, path: path, servable: servable)
    }
    
    mutating func get(path:String, servable:Servable) {
        add(.GET, path: path, servable: servable)
    }
    mutating func post(path:String, servable:Servable){
        add(.POST, path: path, servable: servable)
    }
    mutating func put(path:String, servable:Servable){
        add(.PUT, path: path, servable: servable)
    }
    mutating func delete(path:String, servable:Servable){
        add(.DELETE, path: path, servable: servable)
    }
}