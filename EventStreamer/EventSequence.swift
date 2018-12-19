//
//  EventSequence.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/22/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

protocol CustomDictionaryConvertible {
    var dictionary: [String:CustomStringConvertible] { get }
}

struct EventSequence: Sequence, IteratorProtocol {
    
    struct Event {
        let name: String
        let value: Int
    }
    
    private let initial: Event
    private var previous: Event?
    var current: Event
    
    init(name: String, initialValue value: Int = Int(arc4random() % 256)) {
        initial = Event(name: name, value: value)
        current = initial
        previous = nil
    }
    
    mutating func next() -> Event? {
        let signer: Int = (arc4random() % 7) % 2 == 0 ? -1 : 1
        
        let value = current.value
        let divisor = Int(value) == 0 ? 1 : Double(arc4random() % UInt32(value))
        let delta = 1.0 / divisor * Double(value)
        let next = 1 + value + (Int(delta.isFinite ? delta : 0) * signer)
        
        let event = Event(name: current.name, value: next)
        previous = current
        current = event
        return event
    }
    
    var dictionary: [String : CustomStringConvertible] {
        var output: [String : CustomStringConvertible] = [ "name" : current.name, "initial" : initial.value, "current" : current.value ]
        if let previous = previous {
            output["previous"] = previous.value
        }
        return output
    }
    
}
