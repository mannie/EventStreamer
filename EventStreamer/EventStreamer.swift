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
    
    init(sequence: EventSequence, authenticationAPI: AuthenticationAPI) {
        self.sequence = sequence
        self.authenticationAPI = authenticationAPI
    }
    
    convenience init(name: String, authenticationAPI: AuthenticationAPI) {
        let sequence = EventSequence(name: name)
        self.init(sequence: sequence, authenticationAPI: authenticationAPI)
    }
    
    func stream(to hub: EventHub, sleeping duration: UInt32 = 5, using key: AuthenticationAPI.AccessKey, invoking onStream: ((EventSequence.Event)->Void)?=nil, completion: (()->Void)?=nil) {
        authenticationAPI.requestToken(for: hub, with: key) { (token) in
            guard let token = token else {
                return
            }
            
            DispatchQueue.global().async {
                self.stream(sleeping: duration, using: token, invoking: onStream, completion: completion)
            }
        }
    }
    
    private func stream(sleeping duration: UInt32, using token: String, invoking onStream: ((EventSequence.Event)->Void)?=nil, completion: (()->Void)?=nil) {
        var request = URLRequest(url: hub.messageEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        repeat {
            request.httpBody = try? JSONSerialization.data(withJSONObject: sequence.dictionary, options: .prettyPrinted)
            
            let event = sequence.current
            let sendEvent = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("*** \(error) ***")
                }
                onStream?(event)
            }
            sendEvent.resume()
            
            Thread.sleep(forTimeInterval: TimeInterval(arc4random() % duration))
        } while sequence.next() != nil
        
        completion?()
    }
    
}
