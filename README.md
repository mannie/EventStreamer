# EventStreamer
A sample app showing how to stream data to Azure Event Hubs.

This app will generate events and stream them to Azure Event Hubs. It uses [AzureCocoaSAS](https://github.com/mannie/AzureCocoaSAS) to generate SAS tokens for authorization with Azure. 

## Getting Started
 * Create an EventHub in Azure along with a shared access policy allowing for clients to send events.
 * Open `main.swift` and find the editor placeholders.
 * Paste the `namespace` of the Azure EventHubs and the `name` (path) of the Azure EventHub in the `hub` object's initializtion.
 * Paste the `name` and `key` of the Azure EventHub's shared access policy into the `policy` object's initialization.
 * Run the app.
 
 It's also possible to run the app without streaming to Azure; to do so, simply set `token` to `nil` in `main.swift` and run the app.
