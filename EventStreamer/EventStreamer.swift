//
//  EventStreamer.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/22/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

typealias CompletionHandler = (()->Void)
typealias TerminationCondition = ()->Bool

/**
 * This class acts as the local API for the Azure EventHubs HTTP Client.
 */
final class EventStreamer {
    
    enum Connectivity {
        case offline, online
    }
    
    private var sequence: EventSequence
    private let authenticationAPI: AuthenticationAPI
    private let connectivity: Connectivity
    
    init(sequence: EventSequence, authenticationAPI: AuthenticationAPI, connectivity: Connectivity) {
        self.sequence = sequence
        self.authenticationAPI = authenticationAPI
        self.connectivity = connectivity
    }
    
    convenience init(name: String, authenticationAPI: AuthenticationAPI, connectivity: Connectivity) {
        let sequence = EventSequence(name: name)
        self.init(sequence: sequence, authenticationAPI: authenticationAPI, connectivity: connectivity)
    }
    
    func stream(to hub: EventHub, until condition: @escaping TerminationCondition, invoking onStream: ((EventSequence.Event)->Void)?=nil, maxWait duration: UInt32 = 5, completion: CompletionHandler?=nil) {
        DispatchQueue.global().async {
            switch self.connectivity {
            case .offline:
                self.stream(until: condition, invoking: onStream, maxWait: duration, completion: completion)
                
            case .online:
                self.authenticationAPI.requestToken(for: hub) { (token) in
                    guard let token = token else {
                        return
                    }
                    
                    DispatchQueue.global().async {
                        self.stream(using: token, until: condition, invoking: onStream, maxWait: duration, completion: completion)
                    }
                }
            }
        }
    }
    
    private func stream(using token: String?=nil, until condition: @escaping TerminationCondition, invoking onStream: ((EventSequence.Event)->Void)?=nil, maxWait duration: UInt32, completion: CompletionHandler?=nil) {
        var request: URLRequest? = nil
        
        if let token = token {
            request = URLRequest(url: hub.messageEndpoint)
            request?.httpMethod = "POST"
            request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request?.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        repeat {
            defer {
                Thread.sleep(forTimeInterval: TimeInterval(arc4random() % duration))
            }
            
            let event = sequence.current
            
            guard var request = request else {
                onStream?(event)
                continue
            }
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: sequence.dictionary, options: .prettyPrinted)
            
            let sendEvent = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("*** \(error) ***")
                }
                onStream?(event)
            }
            sendEvent.resume()
        } while condition() == false && sequence.next() != nil

        completion?()
    }
    
}
