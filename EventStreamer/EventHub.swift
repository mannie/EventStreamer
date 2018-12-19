//
//  EventHub.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/22/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

struct EventHub {
    
    let namespace: String
    let name: String
    
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
