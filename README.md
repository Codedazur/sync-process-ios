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
pod repo push bitbucket-cda-ios-pods CDASyncService.podspec --allow-warnings
```

## Author

tamarabernad, tamara@codedazur.es

## License

CDASyncService is available under the MIT license. See the LICENSE file for more info.


## Architecture
![Diagramm](https://github.com/Codedazur/sync-process-ios/blob/master/readme-resources/diagram.png)