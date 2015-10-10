//
//  thePoopBank.swift
//  Poop On Your Friends
//
//  Created by Robert Dunnette on 10/10/15.
//  Copyright © 2015 Jason Toff. All rights reserved.
//

import Foundation

struct poopBank {
    var poopsSent: Int = 0
    var poopsRemaining: Int = 100
    
    func canSendPoops(poopsToSend: Int) -> Bool {
        if poopsToSend > poopsRemaining {
            return(false)
        } else {
            return(true)
        }
    }
    
    mutating func sendPoops(poopsToSend: Int) {
        poopsRemaining -= poopsToSend
        poopsSent += poopsToSend
    }
}