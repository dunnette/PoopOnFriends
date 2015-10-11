//
//  thePoopBank.swift
//  Poop On Your Friends
//
//  Created by Robert Dunnette on 10/10/15.
//  Copyright © 2015 Jason Toff. All rights reserved.
//

import Foundation

class poopBank: NSObject, NSCoding {
    var poopsSent: Int
    var poopsRemaining: Int
    
    func canSendPoops(poopsToSend: Int) -> Bool {
        if poopsToSend > poopsRemaining {
            return(false)
        } else {
            return(true)
        }
    }
    
    func sendPoops(poopsToSend: Int) {
        poopsRemaining -= poopsToSend
        poopsSent += poopsToSend
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(poopsSent, forKey: "poopsSent")
        aCoder.encodeObject(poopsRemaining, forKey: "poopsRemaining")
    }
    
    required init?(coder aDecoder: NSCoder) {
        poopsSent = aDecoder.decodeObjectForKey("poopsSent") as! Int
        poopsRemaining = aDecoder.decodeObjectForKey("poopsRemaining") as! Int
        super.init()
    }
    
    override init() {
        poopsSent = 0
        poopsRemaining = 100
        super.init()
    }
    
    
}