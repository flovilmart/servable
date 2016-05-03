//
//  Route.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-27.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation

public protocol Route: Servable, Hashable {
    var method: Method { get set }
    var servable: Servable { get set }
    var path: String { get set }

    init(method: Method, path: String, servable: Servable)
}

extension Route {

    private func match(inout request:Request) -> [NSTextCheckingResult]? {
        if method == .ANY || request.method == method {
            var rexp: RegularExpressionKeyed?
            do {
                try rexp = Path2RegExp.stringToRegexp(self.path)
            } catch {}
            let path = request.currentPath
            if let rexp = rexp {
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

    public func handle(request: Request, response: Response, next: dispatch_block_t) {
        var req = request
        if let matches = match(&req) where matches.count > 0 {
            let path = request.currentPath
            let index = matches[0].rangeAtIndex(0).location + matches[0].rangeAtIndex(0).length
            req.currentPath = (path as NSString).substringFromIndex(index)
            servable.handle(request, response: response, next: next)
        }else{
            next()
        }
    }

    public var hashValue: Int {
        return "\(method)-\(path)".hashValue
    }
}

public func ==<T where T:Route>(lhs: T, rhs: T) -> Bool {
    return lhs.method == rhs.method && lhs.path == rhs.path
}
