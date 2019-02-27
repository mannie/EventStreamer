//
//  EventHub.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/22/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

/**
 * This model contains the components identifying an Azure EventHub.
 */
struct EventHub {
    
    let namespace: String
    let path: String
    
    private var resourcePath: String {
        return "https://\(namespace).servicebus.windows.net/\(path)".lowercased()
    }
    
    var endpoint: URL {
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
