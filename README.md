# EventStreamer
A sample app showing how to stream data to Azure Event Hubs.

## Getting Started
### Run The Streamer Locally
Ensure that you have Xcode installed, otherwise this sequence of steps won't work.

* Run the `PrepareXCodeProj.sh` script via CLI which will prepare the build the project and create an Xcode project file.
    ```sh
    ./PrepareXCodeProj.sh
    ```
* When prompted to open the EventStreamer project, select `Open`.
* Edit the target's scheme, adding the following `Environment Variables` with the corresponding values:
  * `SASPolicyName`
  * `SASPolicyKey`
  * `EventHubNamespace`
  * `EventHubPath`

  If these environment variables are not set, the app will still run; it just won't stream anything to Azure.
 * Run the app; you should notice events being printed in your console output:
    ```sh
    2019-02-22 14:29:33		depo...	1000 		["current": 1000, "name": "deposit", "initial": 1000]
    2019-02-22 14:29:33		with...	50 		["current": 50, "name": "withdrawal", "initial": 50]
    2019-02-22 14:29:33		purc...	10 		["current": 10, "name": "purchase", "initial": 10]
    2019-02-22 14:29:34		purc...	12 		["current": 12, "initial": 10, "name": "purchase", "previous": 10]
    2019-02-22 14:29:35		purc...	14 		["current": 14, "initial": 10, "name": "purchase", "previous": 12]
    2019-02-22 14:29:37		depo...	1003 		["current": 1003, "initial": 1000, "name": "deposit", "previous": 1000]
    2019-02-22 14:29:38		with...	56 		["current": 56, "initial": 50, "name": "withdrawal", "previous": 50]
    2019-02-22 14:29:38		purc...	14 		["current": 14, "initial": 10, "name": "purchase", "previous": 14]
    2019-02-22 14:29:39		purc...	14 		["current": 14, "initial": 10, "name": "purchase", "previous": 14]
    ...
    ```

    ![Running in Xcode](Xcode.gif)

### Run The App In A Docker Container
Ensure that you have Docker installed and running, otherwise this sequence of steps won't work.

* Update the `Dockerfile` with the following configuration:
    ```yml
    FROM swift
    ENV SASPolicyName="SharedAccessKey"
    ENV SASPolicyKey="Jp9cUB1iCF="
    ENV EventHubNamespace="divergent"
    ENV EventHubPath="streamer"
    WORKDIR /temp
    COPY . ./
    CMD swift package clean
    CMD swift run
    ```
* Build the Docker image and tag it using:
    ```sh
    docker build --tag streamer .
    ```
#### Local
* Run and cleanup the image on completion. To stop the streamer, hit  `Ctrl + C`.
    ```sh
    docker run --interactive --tty --rm streamer
    ```

    ![Running in Docker container](Container.gif)

#### Azure Container Instances
* Create an Azure Container Registry via the portal; the script assumes a registry of name `` so feel free to update the following commands with the appropriate reference.
* Run the following commands to push the container into Azure:
    ```sh
    registry=address.to.registry # example streamer.azurecr.io

    sudo docker login $registry
    sudo docker tag streamer $registry/streamer
    sudo docker push $registry/streamer
    ```
* Create an Azure Container Instance resource in Azure and provide the details for your private registry.
    Upon deployment, the container should automatically start executing.

## How the Streamer Works
It's all about the `EventStreamer.stream(to:using:until:invoking:maxWait:completion:)` method. Lets see some examples.

### Example A

```swift
let policy = AzureCocoaSAS.SharedAccessPolicy(name: "SharedAccessKey", key: "Jp9cUB1iCF=")
let hub = EventHub(namespace: "divergent", name: "streamer") // => http://divergent.servicebus.windows.net/streamer
let token = try? AzureCocoaSAS.token(for: hub.endpoint.absoluteString, using: policy, lifetime: 60 * 60) // expires after 1 hour

let streamer = EventStreamer(name: "myevent")
streamer.stream(to: hub, // `hub` being `nil` will result in no data being sent to Azure (i.e. offline mode)
    using: token, // `token` being `nil` will result in no data being sent to Azure (i.e. offline mode)
    until: { _ in true == false }, // only stop when this condition is met; this is a function mathing signature: (EventSequence)->Bool
    invoking: { print("\($0.current)") }, // execute this block on each event begin streamed; this is a function mathing signature: (EventSequence)->Void
    maxWait: 5, // wait, at most, 5 seconds before streaming out the next event
    completion: { print("Done streaming.") }) // execute this block when the termination condition is met; this is a function mathing signature: (Void)->Void
```

Expect to see something like the following in your console output:

```sh
Event(name: "myevent", value: 112)
Event(name: "myevent", value: 111)
Event(name: "myevent", value: 113)
...
```

**Note:** your initial value will differand so will the subsequent values; the sequence generator `EventSequence` is designed such that the next value in the sequence is based on the current value of that sequence.

### Example B

```swift
let policy = AzureCocoaSAS.SharedAccessPolicy(name: "SharedAccessKey", key: "Jp9cUB1iCF=")
let hub = EventHub(namespace: "divergent", name: "streamer") // => http://divergent.servicebus.windows.net/streamer
let token = try? AzureCocoaSAS.token(for: hub.endpoint.absoluteString, using: policy, lifetime: 60 * 60) // expires after 1 hour

let sequence = EventSequence(name: "myevent", initialValue: 500)
let streamer = EventStreamer(sequence: sequence)
streamer.stream(to: hub, // `hub` being `nil` will result in no data being sent to Azure (i.e. offline mode)
    using: token, // `token` being `nil` will result in no data being sent to Azure (i.e. offline mode)
    until: { $0.current.value < 495 || $0.current.value > 505 }, // only stop when this condition is met; this is a function mathing signature: (EventSequence)->Bool
    invoking: { print("\($0.current)\t \($0.dictionary)") }, // execute this block on each event begin streamed; this is a function mathing signature: (EventSequence)->Void
    maxWait: 1, // wait, at most, 7 seconds before streaming out the next event
    completion: { print("Done streaming.") }) // execute this block when the termination condition is met; this is a function mathing signature: (Void)->Void
```

Expect to see something like the following in your console output:

```sh
Event(name: "myevent", value: 500)	 ["initial": 500, "name": "myevent", "current": 500]
Event(name: "myevent", value: 499)	 ["initial": 500, "name": "myevent", "current": 499, "previous": 500]
Event(name: "myevent", value: 507)	 ["initial": 500, "name": "myevent", "current": 507, "previous": 499]
Done streaming.
```

**Note:** your initial value will be `500` but subsequent values may differ; the sequence generator `EventSequence` is designed such that the next value in the sequence is based on the current value of that sequence.
