# EventStreamer
A sample app showing how to stream data to Azure Event Hubs. 

## Getting Started
 * Open the Xcode project (`EventStreamer.xcodeproj`).
 * Navigate to `main.swift` and find the editor placeholders; they should be located around `line 18`.
 ```swift
 let policy = AzureCocoaSAS.SharedAccessPolicy(name: <#T##String#>, key: <#T##String#>)
 let hub = EventHub(namespace: <#String#>, name: <#String#>) // => http://$namespace.servicebus.windows.net/$name
 ```
 * Paste the `namespace` of the Azure EventHubs and the `name` (path) of the Azure EventHub in the `hub` object's initializtion.
 * Paste the `name` and `key` of the Azure EventHub's shared access policy into the `policy` object's initialization.

 Your updated source code should look something like
 ```swift
 let policy = AzureCocoaSAS.SharedAccessPolicy(name: "SharedAccessKey", key: "Jp9cUB1iCF=")
 let hub = EventHub(namespace: "divergent", name: "streamer") // => http://divergent.servicebus.windows.net/streamer
```



 * Run the app; you should notice events being printed in your console output:
 ```sh
2019-02-20 23:37:11 +0000	 Event(name: "deposit", value: 1000)
2019-02-20 23:37:12 +0000	 Event(name: "withdrawal", value: 50)
2019-02-20 23:37:13 +0000	 Event(name: "purchase", value: 10)
2019-02-20 23:37:13 +0000	 Event(name: "purchase", value: 10)
2019-02-20 23:37:14 +0000	 Event(name: "deposit", value: 999)
2019-02-20 23:37:14 +0000	 Event(name: "purchase", value: 12)
2019-02-20 23:37:14 +0000	 Event(name: "purchase", value: 14)
2019-02-20 23:37:15 +0000	 Event(name: "withdrawal", value: 48)
2019-02-20 23:37:16 +0000	 Event(name: "withdrawal", value: 53)
2019-02-20 23:37:17 +0000	 Event(name: "purchase", value: 14)
2019-02-20 23:37:19 +0000	 Event(name: "purchase", value: 16)
2019-02-20 23:37:19 +0000	 Event(name: "withdrawal", value: 49)
2019-02-20 23:37:22 +0000	 Event(name: "deposit", value: 999)
2019-02-20 23:37:22 +0000	 Event(name: "purchase", value: 25)
2019-02-20 23:37:23 +0000	 Event(name: "purchase", value: 25)
```
 
 It's also possible to run the app *without* streaming to Azure; to do so, simply set `token` to `nil` in `main.swift` and run the app.
