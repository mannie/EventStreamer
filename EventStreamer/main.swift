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
 * Change `count` to limit the number of events being generated and streamed to Azure EventHubs.
 */
var count = Int.max
func countReachesZero() -> Bool {
    count -= 1
    return count <= 0
}

/*
 * Events sent to Azure EventHubs are sent via `EventStreamer` as JSON objects similar to the following payloads:
 
 {
    "initial" : 7,
    "name" : "ping",
    "current" : 9
 }
 
 {
    "initial" : 7,
    "name" : "ping",
    "current" : 9,
    "previous" : 11
 }
 */

/*
 * Send events with name "ping", with a pseudo-random initial value, and a delay of <5 secs between each event
 */
stream(event: "ping", to: hub, until: countReachesZero, using: tokenAPI)

/*
 * Send events with names "deposit", "withdrawal", and "purchase".
 * The initial values are pseudo-random, and a delay of <5 secs is added between each event.
 * Each event names acts as a unique stream of events; the delays and values are calculated independently in each stream.
 */
//stream(events: [ "deposit", "withdrawal", "purchase" ], to: hub, until: countReachesZero, using: tokenAPI)

/*
 * Send events with name "ping"; the initial value and max delay are defined.
 */
//let ping: EventMetadata = (name: "ping", initialValue: 128, maxWait: 3)
//stream(event: ping, to: hub, until: countReachesZero, using: tokenAPI)

/*
 * Send events with names "deposit", "withdrawal", and "purchase".
 * The initial values and max delays are defined per event stream.
 */
//let deposit: EventMetadata = (name: "deposit", initialValue: 100, maxWait: 10)
//let withdrawal: EventMetadata = (name: "withdrawal", initialValue: 7, maxWait: 3)
//let purchase: EventMetadata = (name: "purchase", initialValue: 5, maxWait: 3)
//stream(events: [ deposit, withdrawal, purchase ], to: hub, until: countReachesZero, using: tokenAPI)
