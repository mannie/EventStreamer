//
//  EventStreamer.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/22/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

final class EventStreamer {
    
    private var sequence: EventSequence
    private let authenticationAPI: AuthenticationAPI
    
    init(name: String, authenticationAPI: AuthenticationAPI) {
        sequence = EventSequence(name: name)
        self.authenticationAPI = authenticationAPI
    }
    
    func stream(to hub: EventHub, using key: AuthenticationAPI.AccessKey, completion: (()->Void)?) {
        authenticationAPI.requestToken(for: hub, with: key) { (token) in
            guard let token = token else {
                return
            }
            
            DispatchQueue.global().async {
                self.stream(using: token, completion: completion)
            }
        }
    }
    
    private func stream(using token: String, completion: (()->Void)?) {
        var request = URLRequest(url: hub.messageEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        repeat {
            let payload = sequence.dictionary
            print(payload)
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            let sendEvent = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error)
                }
            }
            sendEvent.resume()
            
            Thread.sleep(forTimeInterval: TimeInterval(arc4random() % 5))
        } while sequence.next() != nil
        
        completion?()
    }
    
}
