//
//  Router.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation

public protocol Router: Servables {}

public extension Router {

    mutating func route(method:Method, path:String, servable:Servable) {
        route(method, path: path, handler: servable.handle)
    }
    
    mutating func all(path:String, _ servable:Servable) {
        all(path, servable.handle)
    }
    
    mutating func get(path:String, _ servable:Servable) {
        get(path, servable.handle)
    }
    mutating func post(path:String, _ servable:Servable){
        post(path, servable.handle)
    }
    mutating func put(path:String, _ servable:Servable){
        put(path, servable.handle)
    }
    mutating func delete(path:String, _ servable:Servable){
        delete(path, servable.handle)
    }

    mutating func all(path:String, _ handler:ServableHandler) {
        route(.ANY, path: path, handler: handler)
    }
    mutating func get(path:String, _ handler:ServableHandler) {
        route(.GET, path: path, handler: handler)
    }
    mutating func post(path:String, _ handler:ServableHandler) {
        route(.POST, path: path, handler: handler)
    }
    mutating func put(path:String, _ handler:ServableHandler) {
        route(.PUT, path: path, handler: handler)
    }
    mutating func delete(path:String, _
        handler:ServableHandler) {
        route(.DELETE, path: path, handler: handler)
    }

    private mutating func route(method:Method, path:String, handler:ServableHandler) {
        use(_Route(method: method, path: path, handler:handler).handle)
    }
}

// Thin struct for routes
private struct _Route: Route {
    var method: Method
    var path: String
    var handler: ServableHandler
}
