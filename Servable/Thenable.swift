//
//  Thenable.swift
//  Servable
//
//  Created by Florent Vilmart on 16-05-02.
//  Copyright © 2016 flovilmart. All rights reserved.
//

public typealias ThenableCallback = (Any?) -> Thenable?

public protocol Thenable: Any {
    func then(success:(ThenableCallback)?, error:(ThenableCallback)?) -> Thenable?
}