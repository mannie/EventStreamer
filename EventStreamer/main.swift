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



let streamerNames = [ "qwerty", "asdf", "uiop" ]
let streamers = streamerNames.map { EventStreamer(name: $0, authenticationAPI: authAPI) }

let group = DispatchGroup()

for data in streamers {
    group.enter()
    data.stream(to: hub, using: key) {
        group.leave()
    }
}

group.wait()


