//
//  EventStreamer.swift
//  EventStreamer
//
//  Created by Mannie Tagarira on 5/22/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

typealias CompletionHandler = (()->Void)
typealias OnStreamHandler = (EventSequence)->Void
typealias TerminationCondition = (EventSequence)->Bool

/**
 * This class acts as the local API for the Azure EventHubs HTTP Client.
 */
final class EventStreamer {
    
    private var sequence: EventSequence
    
    init(sequence: EventSequence) {
        self.sequence = sequence
    }
    
    convenience init(name: String) {
        let sequence = EventSequence(name: name)
        self.init(sequence: sequence)
    }
    
    private func request(for hub: EventHub?, using token: String?) -> URLRequest? {
        guard let hub = hub, let token = token else {
            return nil
        }
        
        var request = URLRequest(url: hub.messageEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func logStreamInfo(for hub: EventHub?, using token: String?) {
        let name = sequence.current.name
        
        var endpoint = "n/a"
        if let hub = hub, let _ = token {
            endpoint = hub.endpoint.absoluteString
        }

        print("STREAM INFO\n\tendpoint\t \(endpoint)\n\tname\t\t \(name)\n")
    }
    
    internal func stream(to hub: EventHub?,
                         using token: String?,
                         until condition: @escaping TerminationCondition,
                         invoking onStream: OnStreamHandler?,
                         maxWait duration: Int=5,
                         completion: CompletionHandler?=nil) {
        
        func stream() {
            logStreamInfo(for: hub, using: token)
            
            repeat {
                let sequence = self.sequence
                
                if var request = request(for: hub, using: token) {
                    var payload = sequence.dictionary
                    payload["timestamp"] = UInt64(Date().timeIntervalSince1970)
                    
                    request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
                    
                    let sendEvent = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        if let error = error {
                            print("*** \(error) ***")
                        }
                        onStream?(sequence)
                    }
                    sendEvent.resume()
                } else {
                    onStream?(sequence)
                }
                
                let sleep = TimeInterval(Int.random(in: 1...duration))
                Thread.sleep(forTimeInterval: sleep)
            } while condition(sequence) == false && sequence.next() != nil
            
            completion?()
        }
        
        DispatchQueue.global().async {
            stream()
        }
    }
    
}
