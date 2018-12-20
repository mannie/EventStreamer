//
//  StreamingUtils.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 12/19/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

func stream(events: [String], to hub: EventHub, limit: UInt=UInt.max, using authAPI: AuthenticationAPI, completion handler: CompletionHandler?=nil) {
    var count = 0
    func limitReached() -> Bool {
        return count >= limit
    }

    func printEventAndIncrementCount(event: EventSequence.Event) {
        print(event)
        count += 1
    }

    // Creating EventStreamer objects in this way randomizes the initial value for underlying EventSequence objects
    let streamers = events.map { EventStreamer(name: $0, authenticationAPI: authAPI) }
    for streamer in streamers {
        streamer.stream(to: hub, until: limitReached, invoking: printEventAndIncrementCount, completion: handler)
    }
}

func stream(event: String, to hub: EventHub, limit: UInt=UInt.max, using authAPI: AuthenticationAPI, completion handler: CompletionHandler?=nil) {
    stream(events: [ event ], to: hub, limit: limit, using: authAPI, completion: handler)
}



typealias EventMetadata = (name: String, initialValue: Int, maxWait: UInt32)

func stream(events definitions: [EventMetadata], to hub: EventHub, limit: UInt=UInt.max, using authAPI: AuthenticationAPI, completion handler: CompletionHandler?=nil) {
    var count = 0
    func limitReached() -> Bool {
        return count >= limit
    }
    
    func printEventAndIncrementCount(event: EventSequence.Event) {
        print(event)
        count += 1
    }

    typealias SleepingStreamer = (streamer: EventStreamer, maxWait: UInt32)
    
    let streamers: [SleepingStreamer] = definitions.map {
        let sequence = EventSequence(name: $0.name, initialValue: $0.initialValue)
        let streamer = EventStreamer(sequence: sequence, authenticationAPI: authAPI)
        return (streamer: streamer, maxWait: $0.maxWait)
    }
    
    for s in streamers {
        s.streamer.stream(to: hub, until: limitReached, invoking: printEventAndIncrementCount, maxWait: s.maxWait, completion: handler)
    }
}

func stream(event definition: EventMetadata, to hub: EventHub, limit: UInt=UInt.max, using authAPI: AuthenticationAPI, completion handler: CompletionHandler?=nil) {
    stream(events: [ definition ], to: hub, limit: limit, using: authAPI, completion: handler)
}
