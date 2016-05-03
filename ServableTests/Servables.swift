//
//  Servables.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-27.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation
import Servable

class PassThrough:Servable {
    func handle(request: Request, response: Response, next: dispatch_block_t) {
        print("Do Nothing")
        next()
    }
}

class SayHello:Servable {
    func handle(request: Request,response: Response, next: dispatch_block_t) {
        response.send("Hello!")
        next()
    }
}

class LongProcess:Servable {
    func handle(request: Request,response: Response, next: dispatch_block_t) {
        print("Wait...")
        let time:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(3)*Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            print("FIRE!")
            next()
        }
    }
}

class OtherLongProcess:Servable {
    func handle(request: Request,response: Response, next: dispatch_block_t) {
        print("Other Wait...")
        let time:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(3)*Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            print("Other FIRE!")
            next()
        }
    }
}

class Appender:Servable {
    func handle(request: Request,response: Response, next: dispatch_block_t) {
        response.write(request.body!)
        next()
    }
}

class RequestPrinter:Servable {
    func handle(request: Request,response: Response, next: dispatch_block_t) {
        response.write("\(request.method.rawValue) \(request.path) \(request.body!)")
        response.success()
        next()
    }
}

class RequestParamsPrinter:Servable  {
    func handle(request: Request,response: Response, next: dispatch_block_t) {
        var str = [String]()
        for p in request.params.sort({ $0.0 < $1.0 }) {
            str.append("\(p.0):\(p.1)")
        }
        
        let string = (str as NSArray).componentsJoinedByString(" ")
        response.send("\(request.method.rawValue) \(string) \(request.body!)")
        next()
    }
}
