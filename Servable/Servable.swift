//
//  Servable.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-25.
//  Copyright © 2015 flovilmart. All rights reserved.
//

public protocol Servable:Any {
    func handle(request: Request, response: Response, next: dispatch_block_t)
}
