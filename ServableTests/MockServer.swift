//
//  MockServer.swift
//  Servable
//
//  Created by Florent Vilmart on 2015-06-27.
//  Copyright © 2015 flovilmart. All rights reserved.
//

import Foundation
import Servable

class MockServer:Server {
    
    var servables = [Servable]()
    
    func listen(port: Int) {
        print("Listening on \(port)")
    }
    
}