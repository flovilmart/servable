//
//  Route.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-27.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation

public struct Route:Servable {
    var method:Method
    var servable:Servable
    var path:String {
        didSet {
            self.updateRexp()
        }
    }
    
    mutating private func updateRexp() {
        do {
            var tokens = [Token]()
            try self.rexp = Path2RegExp.stringToRegexp(self.path, keys: &tokens, options: [String:AnyObject]())
        }catch let error{
            print("\(error)")
        }
    }
    
    init(method:Method, path:String, servable:Servable) {
        self.method = method
        self.path = path
        self.servable = servable
        self.updateRexp()
    }
    
    private var rexp:RegularExpressionKeyed?
    
    func match(request:Request) -> [NSTextCheckingResult]? {
        if method == .ANY || request.method == method {
            print("Is any or method")
            if let rexp = rexp, let path = request.currentPath {
                let matches = rexp.matches(path)
                let keys = rexp.keys
                for match in matches {
                    for i in 1..<match.numberOfRanges {
                        let range = match.rangeAtIndex(i)
                        
                        let str = path.slice(start: range.location, end: range.location+range.length)
                        let name = keys[i-1].name
                        request.params[name] = str
                    }
                }
                return matches
            }
        }
        return nil
    }
    
    public func handle(request: Request,response: Response, next: dispatch_block_t) {
        if let matches = self.match(request) where matches.count > 0 {
            if let path = request.currentPath {
                let index = matches[0].rangeAtIndex(0).location + matches[0].rangeAtIndex(0).length
                request.currentPath = (path as NSString).substringFromIndex(index)
            }
            
            print("Matches \(method.rawValue) \(path)")
            print("Loaded Params \(request.params)")
            request.connection.request = request
            self.servable.handle(request, response: response, next: next)
        }else{
            print("Skipping \(method.rawValue) \(path)")
            next()
        }
    }
}

public func ==(lhs: Route, rhs: Route) -> Bool {
    return lhs.method == rhs.method && lhs.path == rhs.path
}

extension Route:Hashable {
    public var hashValue: Int {
        return "\(method)-\(path)".hashValue
    }
}
