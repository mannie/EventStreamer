//
//  main.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/21/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation



/*
 * Create an EventHub in Azure along with a shared access policy allowing for clients to send events.
 * Paste the `namespace` of the Azure EventHubs and the `name` (path) of the Azure EventHub in the `hub` object's initializtion.
 * Paste the `name` and `value` (key) of the Azure EventHub's shared access policy into the `policy` object's initialization.
 */
let policy = EventHub.SharedAccessPolicy(name: <#T##String#>, value: <#T##String#>)
let hub = EventHub(namespace: <#T##String#>, name: <#T##String#>, policy: policy)

/*
 `endpoint` references the Azure Function which will be used to generate the SAS token.
 Deploy `function.csx` into an Azure Function and paste the Azure Function URL below.
 */
let tokenAPI = AuthenticationAPI(endpoint: <#T##String#>)



/*
 * Events sent to Azure EventHubs are sent via `EventStreamer` as JSON objects similar to the following payloads:
    { "initial" : 7, "name" : "ping", "current" : 9 }
    { "initial" : 7, "name" : "ping", "current" : 9, "previous" : 11 }
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

//stream(event: "ping", to: hub, limit: 7, using: tokenAPI, completion: exit) // limited to 7 events
//wait()

//stream(event: "ping", to: hub, using: tokenAPI, completion: exit) // unbound number of streamed events
//wait()



/*
 * Send events with names "deposit", "withdrawal", and "purchase".
 * The initial values are pseudo-random, and a delay of <5 secs is added between each event.
 * Each event names acts as a unique stream of events; the delays and values are calculated independently in each stream.
 * The `limit` is shared across all active streams.
 */

//stream(events: [ "deposit", "withdrawal", "purchase" ], to: hub, limit: 21, using: tokenAPI, completion: exit) // limited to 21 events
//wait()

//stream(events: [ "deposit", "withdrawal", "purchase" ], to: hub, using: tokenAPI, completion: exit) // unbound number of streamed events
//wait()

/*
 * Send events with name "ping"; the initial value and max delay are defined.
 */



let ping: EventMetadata = (name: "ping", initialValue: 128, maxWait: 3)

//stream(event: ping, to: hub, limit: 3, using: tokenAPI, completion: exit) // limited to 3 events
//wait()

//stream(event: ping, to: hub, using: tokenAPI, completion: exit) // unbound number of streamed events
//wait()



/*
 * Send events with names "deposit", "withdrawal", and "purchase".
 * The initial values and max delays are defined per event stream.
 */

let deposit: EventMetadata = (name: "deposit", initialValue: 1000, maxWait: 14)
let withdrawal: EventMetadata = (name: "withdrawal", initialValue: 50, maxWait: 7)
let purchase: EventMetadata = (name: "purchase", initialValue: 10, maxWait: 3)

//stream(events: [ deposit, withdrawal, purchase ], to: hub, limit: 37, using: tokenAPI, completion: exit) // has upper limit
//wait()

stream(events: [ deposit, withdrawal, purchase ], to: hub, using: tokenAPI, completion: exit) // unbound number of streamed events
wait()

//stream(events: [ deposit, withdrawal, purchase ], to: hub, using: tokenAPI, connectivity: .offline, completion: exit) // unbound number of logged events; these aren't streamed to Azure
//wait()
