//
//  Request.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

//import Foundation

public enum Method: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case HEAD = "HEAD"
    case OPTION = "OPTION"
    case ANY = "ANY"
}

public protocol Request {
    var method: Method { get set }
    var path: String { get set }
    var currentPath: String { get set }
    var params: [String: String] { get set }
    var data: NSData? { get set }
    var body: String? { get set }
}
