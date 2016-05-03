//
//  Path2Regexp.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright (c) 2015 flovilmart. All rights reserved.
//

import Foundation

let pattern = [
    // Match escaped characters that would otherwise appear in future matches.
    // This allows the user to escape special characters that won't transform.
    "(\\\\.)",
    // Match Express-style parameters and un-named parameters with a prefix
    // and optional suffixes. Matches appear as:
    //
    // "/:test(\\d+)?" => ["/", "test", "\d+", undefined, "?", undefined]
    // "/route(\\d+)"  => [undefined, undefined, undefined, "\d+", undefined, undefined]
    // "/*"            => ["/", undefined, undefined, undefined, undefined, "*"]
    "([\\/.])?(?:(?:\\:(\\w+)(?:\\(((?:\\\\.|[^()])+)\\))?|\\(((?:\\\\.|[^()])+)\\))([+*?])?|(\\*))"
    ]

public struct TypeError:ErrorType {
    public var error:String!
    public var _domain:String = "com.flovilmart.path2regexp"
    public var _code:Int = 400
    
    init(error:String) {
        self.error = error
    }
    
    static func UndefinedKeyError(value:String) -> TypeError {
        var error = TypeError(error: "Expected \"\(value)\" to be defined")
        error._code = 101
        return error
    }
    
    static func NotRepeatingKeyError(value:String) -> TypeError {
        var error = TypeError(error: "Expected \"\(value)\" to be defined")
        error._code = 102
        return error
    }
    
    
    static func EmptyKeyError(value:String) -> TypeError {
        var error = TypeError(error: "Expected \"\(value)\" to be defined")
        error._code = 103
        return error
    }
    
    static func NotMatchingError(name:String, pattern:String) -> TypeError {
        var error = TypeError(error: "Expected all \"\(name)\" to match \"\(pattern)\"")
        error._code = 104
        return error
    }
    
    static func UnexpectedTypeError(name:String, type:String) -> TypeError {
        var error = TypeError(error: "Expected \"\(name)\" to be a \(type)")
        error._code = 105
        return error
    }
    
    static func NotImplementedError() -> TypeError {
        return TypeError(error: "Unimplemented")
    }
    
    // "Expected \"" + key.name + "\" to not repeat"
}

extension NSRegularExpression {
    func matches(string:String)  -> [NSTextCheckingResult] {
        return self.matchesInString(string, options: [], range: NSRange(location: 0, length: string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
    }
    
    func test(string:String) -> Bool {
        return self.matches(string).count > 0
    }
    
    convenience init(pattern:String) throws {
        try self.init(pattern:pattern, options: [])
    }
}

public struct RegularExpressionKeyed {
    public var re:NSRegularExpression
    public var keys:[Token]
    
    
    public func test(string:String) -> Bool {
        return re.test(string)
    }
    
    public func matches(string:String) -> [NSTextCheckingResult] {
        return re.matches(string)
    }
}

extension String {
    func replace(pattern:String, with replacement:String) -> String {
        do  {
            let rexp = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.AllowCommentsAndWhitespace)
            return rexp.stringByReplacingMatchesInString(self, options: [], range: NSRange(location: 0, length: self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)), withTemplate: replacement)
        }catch  _ {
            //return error
        }
        return self
    }
    
    func test(otherString:String) throws -> Bool {
        let regexp = try NSRegularExpression(pattern: self)
        return regexp.test(otherString)
    }
    
    func slice(start aStart:Int, end anEnd:Int) -> String {
        var end = anEnd
        if end < 0 {
            end = self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)+end
        }
        let startIndex = self.startIndex.advancedBy(aStart)
        let endIndex = self.startIndex.advancedBy(end)
        
        return self.substringWithRange(startIndex..<endIndex)
    }
}

public struct TokenResult {
    var path:String?
    var token:Token?

    init(path string:String) {
        self.path = string
    }
    
    init(token aToken:Token) {
        self.token = aToken
    }
    
    var isPath:Bool {
        return self.path != nil
    }
    
    var isToken:Bool {
        return self.token != nil
    }
}

public struct Token {
    var name:String
    var prefix: String
    var delimiter: String
    var optional:Bool
    var repeats:Bool
    var pattern:String
}


let patternString = (pattern as NSArray).componentsJoinedByString("|")

public struct Path2RegExp {
    private static var _PATH_REGEXP:NSRegularExpression?
    private static var PATH_REGEXP:NSRegularExpression {
        
        guard let a = Path2RegExp._PATH_REGEXP else {
            do {
                Path2RegExp._PATH_REGEXP = try NSRegularExpression(pattern: patternString , options: NSRegularExpressionOptions.UseUnixLineSeparators)
            }catch let error {
                print("\(error)")
            }
            return Path2RegExp._PATH_REGEXP!
        }
        return a
    }
    
    public static func parse (str:String) -> [TokenResult] {
        //    var tokens = []
        var key = 0
        var index = 0
        var path = ""
        var tokens = [TokenResult]()
        let matches = Path2RegExp.PATH_REGEXP.matchesInString(str, options: [], range: NSMakeRange(0, str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
            
        matches.forEach({ (result) -> Void in
            var res = [String?]()
            for i in 0..<result.numberOfRanges {
                let range = result.rangeAtIndex(i)
                if range.location != NSNotFound {
                    let subString = (str as NSString).substringWithRange(range)
                    res.append(subString)
                }else{
                    res.append(nil)
                }
            }
            
            
            let m = res[0]!
            let offset = result.range.location-index
            path += (str as NSString).substringWithRange(NSRange(location: index, length: offset))
            index = result.range.location + m.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            
            if let escaped = res[1] {
                path+=String(escaped[escaped.startIndex.advancedBy(1)])
                return
            }
            
            if path.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                tokens.append(TokenResult(path:path))
                path = ""
            }
            
            
            let name = res[3] ?? "\(key += 1)"
            let capture = res[4]
            let group = res[5]
            let asterisk = res[7]
            
            var optional:Bool = false
            var isRepeating:Bool = false
            if let suffix = res[6] {
                switch suffix {
                    case "*":
                        optional = true
                        isRepeating = true
                    case "?":
                        optional = true
                    case "+":
                        isRepeating = true
                    default:
                        break
                }

            }
            
            let prefix = res[2] ??  ""
            let delimiter = res[2] ?? "/"
            let pattern = capture ?? group ?? (asterisk != nil ? ".*" : "[^" + delimiter + "]+?")
 
            let tokenResult = TokenResult(token:Token(name: name, prefix: prefix, delimiter: delimiter, optional: optional, repeats: isRepeating, pattern: pattern))
            
            tokens.append(tokenResult)
            return
        })
        
        if (index < str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) {
            path += str.substringFromIndex(str.startIndex.advancedBy(index))
        }
        
        if path.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0  {
            tokens.append(TokenResult(path:path))
        }
        
        return tokens
    }
    
    static func escapeGroup (group:String) -> String {
        return group.replace("/([=!:$\\/()])/g", with: "\\$1")
    }
    
    static func escapeString (str:String) -> String {
        return str.replace("/([.+*?=^!:${}()[\\]|\\/])/g", with:"\\$1")
    }

    static func tokensToFunction(tokens:[TokenResult]) -> ((obj:AnyObject) throws -> String) {
        var matches = [NSRegularExpression?]()
        
        for token in tokens {
            var regexp:NSRegularExpression? = nil
            if let t = token.token {
                do{
                    try regexp = NSRegularExpression(pattern: "^"+t.pattern+"$", options: [])
                }catch{}
            }
            matches.append(regexp)
        }
        
        return { (obj:AnyObject) throws -> String in
            var path = ""
            var i = 0
            for token in tokens {
                
                if let aPath = token.path {
                    path+=aPath
                    continue
                }
                
                guard let key = token.token else {continue}
                guard let regexp = matches[i] else {
                    throw TypeError(error: "We should have a regexp here")
                }
                
                
                guard let value = obj[key.name] else {
                    if (key.optional) {
                        continue
                    } else {
                        throw TypeError.UndefinedKeyError(key.name)
                    }
                }
                
                if let value = value as? [String] {
                    if (!key.repeats) {
                        throw TypeError.NotRepeatingKeyError(key.name)
                    }
                    
                    if value.count == 0 {
                        if  key.optional  {
                            continue
                        } else {
                            throw TypeError.EmptyKeyError(key.name)
                        }
                    }
                    
                    var j = 0
                    for val in value {
                        if !regexp.test(val) {
                            throw TypeError.NotMatchingError(key.name, pattern: key.pattern)
                        }
                        path += (j == 0 ? key.prefix : key.delimiter) + encodeURIComponent(val)
                        j += 1
                    }
                }
                
                guard let stringValue = value as? String else {
                    throw TypeError.UnexpectedTypeError(key.name, type:"String")
                }
                if (!regexp.test(stringValue)) {
                    throw TypeError.NotMatchingError(key.name, pattern: key.pattern)
                }
                
                path += key.prefix + encodeURIComponent(stringValue)
                
                i+=1
                
            }
        
            return path
        }
    }
    
    static func flags(options:[String:AnyObject]) -> NSRegularExpressionOptions {
        if let sensitive = options["sensitive"] as? Bool where sensitive == true {
            return []
        }
        return NSRegularExpressionOptions.CaseInsensitive
    }
    
    static func encodeURIComponent(value:String) -> String {
        return value
    }
    
    static func tokensToRegexp(tokens:[TokenResult], options someOptions:[String:AnyObject]?) throws -> NSRegularExpression {
        let options = someOptions ?? [String:AnyObject]()
        
        let strict = options["strict"] as? Bool ?? false
        let end = options["end"] as? Bool ?? false !== false
        var route = ""
        let lastToken = tokens.last
        var endsWithSlash = false
        
        if let lastToken  = lastToken?.path {
            do {
                endsWithSlash = try String("/\\/$/").test(lastToken)
            }catch _ {}
        }
        
        for token in tokens
        {
            if let path = token.path {
                route += escapeString(path)
            }
            if let token = token.token {
                let prefix = escapeString(token.prefix)
                var capture = token.pattern
                
                if  token.repeats {
                    capture += "(?:\(prefix)\(capture))*"
                }
                
                if (token.optional) {
                    if  prefix.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                        capture = "(?:\(prefix)(\(capture)))?"
                    } else {
                        capture = "(\(capture))?"
                    }
                } else {
                    capture = prefix + "(\(capture))"
                }
                
                route += capture
            }
            
        }
        
        if strict != true {
            route = (endsWithSlash ? route.slice(start: 0, end: -2) : route) + "(?:\\/(?=$))?"
        }
        
        if end {
            route += "$"
        }else{
            route += strict && endsWithSlash ? "" : "(?=\\/|$)"
        }
        
        return try NSRegularExpression(pattern: "^"+route, options: flags(options))
    }
    
    static func attachKeys(regularExpression:NSRegularExpression, keys:[Token]) -> RegularExpressionKeyed {
        return RegularExpressionKeyed(re: regularExpression, keys: keys)
    }
    
    public static func stringToRegexp(path:String, options:[String:AnyObject] = [:]) throws -> RegularExpressionKeyed {
        var keys = [Token]()
        let tokens = parse(path)
        let re = try tokensToRegexp(tokens, options: options)
        for token in tokens {
            if let t  = token.token {
                keys.append(t)
            }
        }
        return attachKeys(re, keys: keys)
    }
    
    public static func pathToRegexp (path:String, options:[String:AnyObject]) throws -> RegularExpressionKeyed {
        return try stringToRegexp(path, options: options)
        
    }
}