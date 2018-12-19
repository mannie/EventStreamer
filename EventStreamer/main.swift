//
//  main.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/21/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation



let hub = EventHub()
let key = AuthenticationAPI.AccessKey()
let authAPI = AuthenticationAPI()



typealias TerminationCondition = ()->Bool

func stream(events: [String], to hub: EventHub, authenticatingVia authAPI: AuthenticationAPI, until condition: @escaping TerminationCondition) {
    // Creating EventStreamer objects in this way randomizes the initial value for underlying EventSequence objects
    let streamers = events.map { EventStreamer(name: $0, authenticationAPI: authAPI) }
    
    let group = DispatchGroup()
    group.enter()

    for streamer in streamers {
        streamer.stream(to: hub, using: key, invoking: {
            print($0)
            let _ = $0
            
            if condition() {
                group.leave()
            }
        })
    }
    
    group.wait()
}

func stream(event: String, to hub: EventHub, authenticatingVia authAPI: AuthenticationAPI, until condition: @escaping TerminationCondition) {
    stream(events: [ event ], to: hub, authenticatingVia: authAPI, until: condition)
}

typealias Event = (name: String, initialValue: Int, maxWait: UInt32)
func stream(events definitions: [Event], to hub: EventHub, authenticatingVia authAPI: AuthenticationAPI, until condition: @escaping TerminationCondition) {
    typealias SleepingStreamer = (streamer: EventStreamer, maxWait: UInt32)
    
    let streamers: [SleepingStreamer] = definitions.map {
        let sequence = EventSequence(name: $0.name, initialValue: $0.initialValue)
        let streamer = EventStreamer(sequence: sequence, authenticationAPI: authAPI)
        return (streamer: streamer, maxWait: $0.maxWait)
    }
    
    let group = DispatchGroup()
    group.enter()

    let onStream = { (event: EventSequence.Event) in
        print(event)
        
        if condition() {
            group.leave()
        }
    }
    
    for s in streamers {
        s.streamer.stream(to: hub, sleeping: s.maxWait, using: key, invoking: onStream)
    }
    
    group.wait()
}

func stream(event definition: Event, to hub: EventHub, authenticatingVia authAPI: AuthenticationAPI, until condition: @escaping TerminationCondition) {
    stream(events: [ definition ], to: hub, authenticatingVia: authAPI, until: condition)
}


var count = Int.max
func countReachesZero() -> Bool {
    count -= 1
    return count <= 0
}

//stream(event: "ping", to: hub, authenticatingVia: authAPI, until: countReachesZero)

//stream(events: [ "deposit", "withdrawal", "purchase" ], to: hub, authenticatingVia: authAPI, until: countReachesZero)

//let ping: Event = (name: "ping", initialValue: 128, maxWait: 3)
//stream(event: ping, to: hub, authenticatingVia: authAPI, until: countReachesZero)

let deposit: Event = (name: "deposit", initialValue: 100, maxWait: 10)
let withdrawal: Event = (name: "withdrawal", initialValue: 7, maxWait: 3)
let purchase: Event = (name: "purchase", initialValue: 5, maxWait: 3)
stream(events: [ deposit, withdrawal, purchase ], to: hub, authenticatingVia: authAPI, until: countReachesZero)
