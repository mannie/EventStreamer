//
//  main.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/21/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation
import AzureCocoaSAS



/**
 Events sent to Azure EventHubs are sent via `EventStreamer` as JSON objects similar to the following payloads:
 - `{ "timestamp" : 1549566851, "name" : "ping", "initial" : 7, "current" : 9 }`
 - `{ "timestamp" : 1549566851, "name" : "ping", "initial" : 7, "current" : 9, "previous" : 11 }`
*/



var hub: EventHub? = nil
var token: String? = nil



/**
 Create an EventHub in Azure along with a shared access policy allowing for clients to send events.
 Paste the `namespace` of the Azure EventHubs and the `path` of the Azure EventHub in the `hub` object's initializtion.
 Paste the `name` and `key` of the Azure EventHub's shared access policy into the `policy` object's initialization.
*/
let env = ProcessInfo.processInfo.environment
if let name = env["SASPolicyName"], let key = env["SASPolicyKey"], let namespace = env["EventHubNamespace"], let path = env["EventHubPath"] {
    if !name.isEmpty, !key.isEmpty, !namespace.isEmpty, !path.isEmpty {
        let policy = AzureCocoaSAS.SharedAccessPolicy(name: name, key: key)
        let _hub = EventHub(namespace: namespace, path: path) // => http://$namespace.servicebus.windows.net/$path

        if let _token = try? AzureCocoaSAS.token(for: _hub.endpoint.absoluteString, using: policy, lifetime: 60 * 60 * 24 * 7) {
            token = _token
            hub = _hub
        }
    }
}




/// Here are a few helpers to make sure that code is run to completion and program doesn't terminate prematurely without sending events.

func shouldTerminate(sequence: EventSequence) -> Bool {
    return false
}

let formatter = DateFormatter()
formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
func dump(sequence: EventSequence) {
    let event = sequence.current
    print("\(formatter.string(from: Date()))\t\t\(event.name.prefix(4))...\t\(event.value) \t\t\(sequence.dictionary)")
}




/// Send events with the specified names. The initial values and delays between each event are defined per event stream.

typealias Stream = (name: String, initialValue: Int, maxWait: Int)

let deposit: Stream = (name: "deposit", initialValue: 1000, maxWait: 14)
let withdrawal: Stream = (name: "withdrawal", initialValue: 50, maxWait: 7)
let purchase: Stream = (name: "purchase", initialValue: 10, maxWait: 3)

let streams = [ deposit, withdrawal, purchase ]

let group = DispatchGroup()
for s in streams {
    let sequence = EventSequence(name: s.name, initialValue: s.initialValue)
    let streamer = EventStreamer(sequence: sequence)

    group.enter()
    // a nil `token` or `hub` will result in no data being sent to Azure (i.e. offline mode)
    streamer.stream(to: hub, using: token, until: shouldTerminate, invoking: dump, maxWait: s.maxWait) {
        group.leave()
        Thread.sleep(forTimeInterval: 7)
    }
}
group.wait() // Let's make sure that the app doesn't exit before the streamers have finished streaming.

 
