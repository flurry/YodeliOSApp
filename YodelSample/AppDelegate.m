//
//  AppDelegate.m
//  YodelSample
//
//  Copyright 2015 Yahoo! Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <CoreLocation/CoreLocation.h>
#import <YahooSearchKit/YSLSetting.h>
#import "AdManager.h"
#import "AppDelegate.h"
#import "Configuration.h"
#import "ContainerViewController.h"
#import "Flurry.h"

@interface AppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    Configuration* config = [Configuration sharedInstance];
    
    [YSLSetting setupWithAppId:[config yahooSearchAppId]];
    [YSLSetting sharedSetting].developerMode = NO;
    [YSLSetting sharedSetting].safeSearchMode = YSLSafeSearchModeStrict;
    
    // Uncomment the below lines for console logs from the Flurry SDK
    //[Flurry setDebugLogEnabled:YES];
    //[Flurry setLogLevel:FlurryLogLevelDebug];
    
    [Flurry startSession:[config flurryApiKey]];
    
    // Start up the AdManager to fetch our ads in advance
    [AdManager sharedInstance];
    
    ContainerViewController *searchBarController = [[ContainerViewController alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = searchBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
