//
//  YSLSearchViewController.h
//  YahooSearchKit
//
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSLSearchResult.h"

@class YSLSearchViewController;

/**
 Including these constants in the array of strings that is passed to the setSearchResultTypes:
 method will display web, image, or video search result tabs in the search view
 controller.
 */
extern NSString *const YSLSearchResultTypeWeb;
extern NSString *const YSLSearchResultTypeImage;
extern NSString *const YSLSearchResultTypeVideo;

/**
 Return one of these options from the searchViewController:actionForQueryString: delegate method to control the
 action that you want the search view controller to perform for the given query string.
 */
typedef NS_ENUM(NSUInteger, YSLQueryAction) {
    /**
     Performs search for the query string. If query string is empty, shows the keyboard
    */
    YSLQueryActionDefault,
    
    /** Performs search for the query string */
    YSLQueryActionSearch,
    
    /** Shows suggestions for the query string */
    YSLQueryActionShowSuggestions
};

@interface YSLSearchViewControllerSettings : NSObject

/**
 * This toggles the consumption mode in search view controller.
 * Default is YES.
 *
 * Consumption mode is a popular mobile app paradigm in which the header
 * and footer elements are automatically hidden when scrolling down a
 * content feed (i.e., when you are "consuming" content). This allows more
 * content to be seen on the screen. The header and footer are displayed
 * when scrolling up or when tapping the status bar.
 */
@property (nonatomic, assign, getter = isConsumptionModeEnabled) BOOL enableConsumptionMode;

/**
 * This controls tracking user location in search results.
 * Default is YES.
 */
@property (nonatomic, assign, getter = isLocationServiceEnabled) BOOL enableLocationService;

/**
 * This toggles the Search-to-Link experience in search view controller.
 * Default is NO.
 *
 * When set to YES, the search view controller passes the search result data
 * back to the application when the user clicks on any link. Your application must
 * implement the searchViewController:didSearchToLink: delegate method to be
 * notified.
 */
@property (nonatomic, assign, getter = isSearchToLinkEnabled) BOOL enableSearchToLink;

/**
 * This toggles the Copyright Header visibility in Image and Video search
 * results for the Search-to-Link experience in the search view controller.
 * Default is YES.
 
 * When set to NO, the Copyright Header will not be shown on top of Image
 * and Video search results page when the Search-to-Link experience is
 * enabled. If Search-to-Link is disabled, this flag has no effect on the
 * search experience.
 */
@property (nonatomic, assign, getter = isCopyrightHeaderEnabled) BOOL enableCopyrightHeader;

/**
 * This toggles showing suggestions for the search query string.
 * Default is YES.
 */
@property (nonatomic, assign, getter = isSearchSuggestionsEnabled) BOOL enableSearchSuggestions;
@end

@protocol YSLSearchViewControllerDelegate <NSObject>

@optional

/**
 *  Asks the delegate to specify the action that should be performed. See YSLQueryAction for all available actions
 *
 *  @discussion When you present the search view controller, it will by default show the search results for the specified query string.
 *  You can override this behavior and show search suggestions instead, which will display a list of suggestions for the same query string.
 *  The user can choose to search using the initial query string or select one of the suggested terms.
 *
 *  @param searchViewController search view controller instance
 *  @param queryString          query string for which the action will be performed
 *
 *  @return YSLQueryAction Action that needs to be performed. Default action is YSLQueryActionDefault.
 */
- (YSLQueryAction)searchViewController:(YSLSearchViewController *)searchViewController actionForQueryString:(NSString *)queryString;

/**
 *  Tells the delegate that the left button on the search header view was tapped
 *
 *  @discussion Implement this delegate method to be notified when the user taps the left button on the search view header.
 *  You can use this to typically dismiss the search view controller and return the user back to your app.
 *
 *  @param searchViewController search view controller instance
 */
- (void)searchViewControllerDidTapLeftButton:(YSLSearchViewController*)searchViewController;

/**
 *  Sent when enableSearchToLink is set to YES and the user taps on any search result
 *
 *  @discussion Implement this delegate method to allow users of your application to search, select, and share web links, images, and videos.
 *
 *  @param searchViewController search view controller instance
 *  @param result               the search result that is being shared
 */
- (void)searchViewController:(YSLSearchViewController *)searchViewController didSearchToLink:(YSLSearchToLinkResult *)result;

/**
 *  Sent when enableSearchToLink is set to NO and the user taps on a web search result
 *
 *  @discussion Important: If you return NO, you are assuming responsibility for handling what
 *  happens in your application UI in response to the tap (e.g. open a web view).
 *
 *  If you only want the search result data, but do not want to handle loading the result, return
 *  YES.
 *
 *  @param searchViewController search view controller instance
 *  @param result               the web search result that was tapped
 *
 *  @return boolean indicating if the search view controller should load the web result. 
 *          YES if the search view controller should load the web result; otherwise, NO.
 */
- (BOOL)shouldSearchViewController:(YSLSearchViewController *)searchViewController loadWebResult:(YSLSearchWebResult *)result;

/**
 *  Sent when enableSearchToLink is set to NO and the user taps on an image search result
 *
 *  @discussion Important: If you return NO, you are assuming responsibility for handling what
 *  happens in your application UI in response to the tap (e.g. open an image viewer).
 *
 *  If you only want the search result data, but do not want to handle loading the result, return
 *  YES.
 *
 *  @param searchViewController search view controller instance
 *  @param result               the image search result that was tapped
 *
 *  @return boolean indicating if the search view controller should load the image result.
 *          YES if the search view controller should load the image result; otherwise, NO.
 */
- (BOOL)shouldSearchViewController:(YSLSearchViewController *)searchViewController loadImageResult:(YSLSearchImageResult *)result;

/**
 *  Sent when enableSearchToLink is set to NO and the user taps on a video search result
 *
 *  @discussion Important: If you return NO, you are assuming responsibility for handling what
 *  happens in your application UI in response to the tap (e.g. open video player).
 *
 *  If you only want the search result data, but do not want to handle loading the result, return
 *  YES.
 *
 *  @param searchViewController search view controller instance
 *  @param result               the video search result that was tapped
 *
 *  @return boolean indicating if the search view controller should load the video result.
 *          YES if the search view controller should load the video result; otherwise, NO.
 */
- (BOOL)shouldSearchViewController:(YSLSearchViewController *)searchViewController loadVideoResult:(YSLSearchVideoResult *)result;

@end

@interface YSLSearchViewController : UIViewController

/**
 *  This is the query in the search input box.
 *
 *  @discussion This is the query for which the search view controller will display search results or suggestions.
 */
@property (nonatomic, copy) NSString *queryString;

/**
 *  The search view controller’s delegate object.
 *
 *  @discussion The delegate must adopt the YSLSearchViewControllerDelegate protocol. The delegate is not retained.
 */
@property (nonatomic, weak) id<YSLSearchViewControllerDelegate> delegate;

/**
 *  Initializer that takes a custom settings object to configure the search experience
 *
 *  @param settings settings instance
 *  @return an instance of the search view controller
 */
- (instancetype)initWithSettings:(YSLSearchViewControllerSettings *)settings;

/**
 *  Sets the search result types to be displayed
 *
 *  @discussion The search view controller uses the values in the searchResultTypes argument to display the different search result types for any query.
 *  It will preserve the order of the result types in the array during display. By default, the first result type in the array is selected for display.
 *  If you don’t call this API, the search view controller will display web, image, and video search results, in that order, and will set YSLWebSearchResultType as the selected result type.
 *
 *  @param searchResultTypes an array containing any combination of YSLSearchResultTypeWeb, YSLSearchResultTypeImage, or YSLSearchResultTypeVideo.
 *
 */
- (void)setSearchResultTypes:(NSArray*)searchResultTypes;

/**
 * The selected result type
 *
 * @discussion When set, the search view controller will display the result type specified by this property. 
 *  This property is updated when the user selects other search result types through the UI.
 */
@property (nonatomic, copy) NSString *selectedResultType;

@end
