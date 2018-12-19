//
//  AuthenticationAPI.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/22/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

/**
 * This struct acts as the local API for the Azure Function generating the SAS token for accessing the Azure EventHub.
 */
struct AuthenticationAPI {
        
    private let endpoint: URL
    
    init(endpoint: String) {
        guard let url = URL(string: endpoint) else {
            fatalError("Invalid auth endpoint")
        }
        self.endpoint = url
    }
    
    func requestToken(for hub: EventHub, completion: ((String?)->Void)?) {
        let body = [ "uri": hub.tokenEndpoint.absoluteString, "name" : hub.policy.name, "value" : hub.policy.value ]
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let token = String(data: data, encoding: .utf8) else {
                completion?(nil)
                return
            }
            completion?(token)
        }
        task.resume()
    }
    
}
