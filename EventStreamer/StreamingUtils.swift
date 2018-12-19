//
//  StreamingUtils.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 12/19/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

typealias TerminationCondition = ()->Bool

func stream(events: [String], to hub: EventHub, until condition: @escaping TerminationCondition, using authAPI: AuthenticationAPI) {
    // Creating EventStreamer objects in this way randomizes the initial value for underlying EventSequence objects
    let streamers = events.map { EventStreamer(name: $0, authenticationAPI: authAPI) }
    
    let group = DispatchGroup()
    group.enter()
    
    for streamer in streamers {
        streamer.stream(to: hub, invoking: {
            print($0)
            let _ = $0
            
            if condition() {
                group.leave()
            }
        })
    }
    
    group.wait()
}

func stream(event: String, to hub: EventHub, until condition: @escaping TerminationCondition, using authAPI: AuthenticationAPI) {
    stream(events: [ event ], to: hub, until: condition, using: authAPI)
}

typealias EventMetadata = (name: String, initialValue: Int, maxWait: UInt32)
func stream(events definitions: [EventMetadata], to hub: EventHub, until condition: @escaping TerminationCondition, using authAPI: AuthenticationAPI) {
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
        s.streamer.stream(to: hub, invoking: onStream, maxWait: s.maxWait)
    }
    
    group.wait()
}

func stream(event definition: EventMetadata, to hub: EventHub, until condition: @escaping TerminationCondition, using authAPI: AuthenticationAPI) {
    stream(events: [ definition ], to: hub, until: condition, using: authAPI)
}
