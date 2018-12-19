//
//  EventHub.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/22/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

/**
 * This model contains the components identifying an Azure EventHub along with the required shared access policy.
 */
struct EventHub {
    
    struct SharedAccessPolicy {
        let name: String
        let value: String
    }

    let namespace: String
    let name: String
    let policy: SharedAccessPolicy
    
    private var resourcePath: String {
        return "https://\(namespace).servicebus.windows.net/\(name)".lowercased()
    }
    
    var tokenEndpoint: URL {
        guard let url = URL(string: resourcePath) else {
            fatalError("Cannot generate token endpoint for EventHub \(self)")
        }
        return url
    }
    
    var messageEndpoint: URL {
        guard let url = URL(string: "\(resourcePath)/messages?api-version=2014-01") else {
            fatalError("Cannot generate endpoint for EventHub \(self)")
        }
        return url
    }
    
}
