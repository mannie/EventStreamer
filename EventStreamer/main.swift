//
//  main.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/21/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

import AzureCocoaSAS

/*
 * Create an EventHub in Azure along with a shared access policy allowing for clients to send events.
 * Paste the `namespace` of the Azure EventHubs and the `name` (path) of the Azure EventHub in the `hub` object's initializtion.
 * Paste the `name` and `key` of the Azure EventHub's shared access policy into the `policy` object's initialization.
 */
let policy = AzureCocoaSAS.SharedAccessPolicy(name: <#T##String#>, key: <#T##String#>)
let hub = EventHub(namespace: <#String#>, name: <#String#>)

var token: String? = nil // a nil token will result in no data being sent to Azure (i.e. offline mode)
token = try? AzureCocoaSAS.generateToken(for: hub.endpoint.absoluteString, using: policy, lifetime: 60 * 60 * 24)


/*
 * Events sent to Azure EventHubs are sent via `EventStreamer` as JSON objects similar to the following payloads:
 { "timestamp" : 1549566851, "name" : "ping", "initial" : 7, "current" : 9 }
 { "timestamp" : 1549566851, "name" : "ping", "initial" : 7, "current" : 9, "previous" : 11 }
 */



/*
 * Here are a few helpers to make sure that code is run to completion and program doesn't terminate prematurely without sending events.
 */
let group = DispatchGroup()

func wait() {
    group.enter()
    group.wait()
}

func exit() {
    group.leave()
    Thread.sleep(forTimeInterval: 5)
    exit(0)
}



/*
 * Send events with name "ping", with a pseudo-random initial value, and a delay of <5 secs between each event.
 * Only 7 events are sent, as per `limit`; removing this paramater removes the limit, keeping the stream active.
 */

//stream(event: "ping", to: hub, using: token, limit: 7, completion: exit) // limited to 7 events
//wait()

//stream(event: "ping", to: hub, using: token, completion: exit) // unbound number of streamed events
//wait()



/*
 * Send events with names "deposit", "withdrawal", and "purchase".
 * The initial values are pseudo-random, and a delay of <5 secs is added between each event.
 * Each event names acts as a unique stream of events; the delays and values are calculated independently in each stream.
 * The `limit` is shared across all active streams.
 */

//stream(events: [ "deposit", "withdrawal", "purchase" ], to: hub, using: token, limit: 21, completion: exit) // limited to 21 events
//wait()

//stream(events: [ "deposit", "withdrawal", "purchase" ], to: hub, using: token, completion: exit) // unbound number of streamed events
//wait()



/*
 * Send events with name "ping"; the initial value and max delay are defined.
 */

//let ping: EventMetadata = (name: "ping", initialValue: 128, maxWait: 3)

//stream(event: ping, to: hub, using: token, limit: 5, completion: exit) // limited to 5 events
//wait()

//stream(event: ping, to: hub, using: token, completion: exit) // unbound number of streamed events
//wait()



/*
 * Send events with names "deposit", "withdrawal", and "purchase".
 * The initial values and max delays are defined per event stream.
 */

let deposit: EventMetadata = (name: "deposit", initialValue: 1000, maxWait: 14)
let withdrawal: EventMetadata = (name: "withdrawal", initialValue: 50, maxWait: 7)
let purchase: EventMetadata = (name: "purchase", initialValue: 10, maxWait: 3)

//stream(events: [ deposit, withdrawal, purchase ], to: hub, using: token, limit: 37, completion: exit) // has upper limit
//wait()

stream(events: [ deposit, withdrawal, purchase ], to: hub, using: token, completion: exit) // unbound number of streamed events
wait()


