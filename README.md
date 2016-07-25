# CDASyncService

[![CI Status](http://img.shields.io/travis/tamarabernad/CDASyncService.svg?style=flat)](https://travis-ci.org/tamarabernad/CDASyncService)
[![Version](https://img.shields.io/cocoapods/v/CDASyncService.svg?style=flat)](http://cocoapods.org/pods/CDASyncService)
[![License](https://img.shields.io/cocoapods/l/CDASyncService.svg?style=flat)](http://cocoapods.org/pods/CDASyncService)
[![Platform](https://img.shields.io/cocoapods/p/CDASyncService.svg?style=flat)](http://cocoapods.org/pods/CDASyncService)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CDASyncService is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CDASyncService"
```

## Dev
To create new versions of thsi library run:
```unix
git add -A && git commit -m "Release 0.0.19"
git tag '0.0.1'
git push --tags
pod repo push bitbucket-cda-ios-pods CDASyncService.podspec --allow-warnings --use-libraries
```

## Author

tamarabernad, tamara@codedazur.es

## License

CDASyncService is available under the MIT license. See the LICENSE file for more info.


## Architecture
![Diagramm](https://github.com/Codedazur/sync-process-ios/blob/master/readme-resources/diagram.png)

## How to work with it
Best would be to have an instance of `CDASyncManager` in the AppDelegate and in `applicationDidBecomActive` call the `run` function
```swift
func applicationDidBecomeActive(application: UIApplication){
	syncManager.sync()
}
```

To run the syc process each certain time you can add an instance of `CDASyncChron` this one will send every specified time interval the `kSyncNotificationChronPull` and `CDASyncManager`is going to call the `sync` function


## How to configure sync modules
The library comes with several useful modules, but new ones can be create as needed (please see section "How to extend").
The sync process is configured with several `CDASyncModel` configuration objects. Each one of those represents a step in the sync process. Each one of those steps can have sub steps needed to complete the specific step. Ideally you create a Configuration class where all those `CDASyncModel` objects are created and then passed to the `CDASynManager`'s constructor. `CDASyncModel` is a protocol, the library comes with the specific `CDASimpleSyncModel` which can be used.

For example:
We have a sync module that parses the data from a REST request into CoreData. Then your Sync Model would contain 2 steps:
1. Reaching a resource in the API
2. Parsing  

So we would need to create 3 SyncModels 1 for each of the substeps and one to combine them in one.

1. Connecting to API

```swift
 let smConnect = CDASimpleSyncModel(uid: "connector", moduleClass: CDARestModule.self, userInfo: ["baseUrl":"http://api.example.com","resource":"examples","connectorClass":CDAAFNetworkingConnector.self, "basicAuthUser":"user", "basicAuthPassword":"pass"] as [NSObject : AnyObject], timeInterval: 0)
 ```
Here we a using the `CDARestModule` class that comes with the library this one is going to connect via de Connector to the api and retrieve data and store it in `result`. In this case we are using `CDAAFNetworkingConnector` as connector. If you don't want to use AFNetworking, you can create a connector with any HTTP library you prefer.
The CDARestModule expects in user info "baseUrl", "resource" and "connectorClass" you can provide "basicAuthUser" and "basicAuthPassword" only if you need it

2. Parsing data

```swift
let smParse = CDASimpleSyncModel(uid: "parser", moduleClass: CDACoreDataParserSyncModule.self, userInfo: ["parserClass":CDARestKitCoreDataParser.self,"coreDataStack":coreDataStack,"mapping":mapper] as [NSObject : AnyObject], timeInterval: 0)
```
In this case we want to parse the data into Core Data and we want to use the `CDARestKitCoreDataParser`, if you don't want to use RestKit you could implement one of your own.
`coreDataStack` is an instance of `<CDACoreDataStackProtocol>` the library comes with an implementation `CDACoreDataStack`. Ideally you create one coreDataStack to use on your whole app in the `AppDelegate` 
`mapper` mapper is an instance of `CDAMapper` used to map attributes from your Model to the models coming from the server.
Since the parser is going to have the connector as dependency, it is going to receive the data to parse from the connector.

3. Combining

Now that we have the submodules we need to combine them to make one.

```swift
let smSyncService = CDASimpleSyncModel(uid: "some-unique-identifier", moduleClass: CDAAbstractSyncService.self, userInfo: nil, subModuleModels: [smConnect, smParse]], timeInterval: 60*60*24)
```
The utility class `CDAAbstractSyncService` is responsible for running teh subModules sequencially. The parameter timeinterval is used to specify the frequency this sync process needs to run 24h in our example.


## Available modules
#### CDARestModule
#### CDACoreDataParserSyncModule
#### CDADownloadableContentAnalyzerModule
#### CDADownloadableContentRetrieverModule
#### CDADownloadedArchiveProcessor
#### CDAAbstractSyncService

## Utilities
#### CDAAFNetworkingConnector
#### CDARestKitCoreDataParser
#### CDABackgroundDownloadManager


## How to extend

## Mapper

```Objective-c
@interface CDAMapper : NSObject
@property (nonatomic, strong) NSString *destinationClassName;
@property (nonatomic, strong) NSDictionary *attributesMapping;
@property (nonatomic, strong) NSArray *relationsMapping;
@property (nonatomic, strong) NSString *rootKey;
@property (nonatomic, strong) NSString *localIdentifierKey;
@property (nonatomic, strong) NSString *remoteIdentifierKey;
@end
```

