# Yodel Sample App - iOS

This project showcases some of the new mobile development tools released by Yahoo during the 2015 
[Mobile Developer Conference](http://yahoomobiledevcon.tumblr.com/)

## Features

- Showcases integration of Gemini ads through Flurry Native SDK, along with best practices for integrating native 
ads in your iOS app.
- Showcases the Yahoo! Search SDK and some use cases for the Search SDK.
- Showcases basic use cases for Flurry Analytics with event logging.

## Requirements for working with the source:

- Xcode 6+
- iOS 7.0+

Open YodelSample.xcworkspace in Xcode to begin working with the project.

This repository comes bundled with the following libraries:

- Flurry SDK v6.2.0
- Search SDK Developer Preview v0.1.0
- Tumblr SDK v2.0.2 via Cocoapods. Includes the following dependencies:
  - Spectacles v1.0.1
  - JXHTTP v1.0.4

You can adjust the Pod versions by using [Cocoapods](http://cocoapods.org/).

## Gemini native ads
To see best practices for integrating native ads into your app, look through the following classes:

- [AdManager](YodelSample/Helpers/AdManager.m): This class manages ads coming from the Flurry SDK and ensures
that they are prepared and ready in advance of when they are needed.
- [CardTableViewController](YodelSample/ViewControllers/CardTableViewController.m):
This class shows how native ads can be interspersed seamlessly into a table view.

For more info on getting started with Flurry for Android, see
[here](https://developer.yahoo.com/flurry/docs/analytics/gettingstarted/ios/).

## Yahoo Search SDK
To see example integration techniques for Yahoo Search SDK, look through the following classes:

- [CarouselCollectionViewController](YodelSample/ViewControllers/CarouselCollectionViewController.m) - Method learnMoreButtonPressed.
- [SearchBarViewController](YodelSample/ViewControllers/SearchBarViewController.m) - Method moreOnWebButtonPressed.

