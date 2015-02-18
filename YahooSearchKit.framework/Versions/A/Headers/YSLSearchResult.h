//
//  YSLSearchResult.h
//  YahooSearchKit
//
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Base class for a search result. All search results
 have a source URL, title, and the query string that
 was used to perform the search.
 */
@interface YSLSearchResult : NSObject

/**
 *  URL for the search result
 */
@property (nonatomic, readonly, copy) NSURL *sourceURL;

/**
 *  Title for the search result. This can be empty.
 */
@property (nonatomic, readonly, copy) NSString *title;

/**
 *  Query string that was used to perform the search
 *  that produced this search result
 */
@property (nonatomic, readonly, copy) NSString *queryString;

@end

/**
 A web search result
 Note: The web search result does not currently contain any
 additional properties, but may be extended in the future.
 */
@interface YSLSearchWebResult : YSLSearchResult

@end

/**
 An image search result. Image search results contain
 a thumbnail URL in addition to source URL, title, and query string
 */
@interface YSLSearchImageResult : YSLSearchResult

/**
 *  Thumbnail URL for the image search result
 */
@property (nonatomic, readonly, copy) NSURL *thumbnailURL;

@end

/**
 A video search result. Video search results contain many
 additional properties that are specific to the video as
 described below.
 */
@interface YSLSearchVideoResult : YSLSearchResult

/**
 *  URL for the video. This can be empty.
 */
@property (nonatomic, readonly, copy) NSString *originalVideoURL;

/**
 *  URL for streaming the video. This can be empty.
 */
@property (nonatomic, readonly, copy) NSString *streamingVideoURL;

/**
 *  Thumbnail image URL for the video
 */
@property (nonatomic, readonly, copy) NSString *thumbnailURL;

/**
 *  Creation date returned as a friendly string (e.g "1 year ago").
 *  This can be empty.
 */
@property (nonatomic, readonly, copy) NSString *createdDate;

/**
 *  Duration of the video returned as a string in hh:mm:ss format
 *  Note: The duration value drops the hour component if it is zero 
 *  (e.g "01:25" should be read as 1 minute and 25 seconds. Hour component
 *  is dropped because it is zero. However, minutes component is retained
 *  even if it is zero - for example "00:30" is used to denote 30 seconds)
 */
@property (nonatomic, readonly, copy) NSString *duration;

/**
 *  Description for the video. This can be empty.
 */
@property (nonatomic, readonly, copy) NSString *videoDescription;

@end

/**
 A Search-to-Link result. Search-to-Link results contain many
 additional properties as shown below.
 */
@interface YSLSearchToLinkResult : YSLSearchResult

/**
 *  Description for the Search-to-Link result. This can be empty.
 */
@property (nonatomic, readonly, copy) NSString *linkDescription;

/**
 *  A shortened URL for the Search-to-Link result
 */
@property (nonatomic, readonly, copy) NSURL *shortURL;

/**
 *  Attribution URL (for Web only). This can be empty.
 *
 *  The attribution URL is provided for any links that you
 *  can receive attribution for - such as an ad. If this property is
 *  not empty, it is recommended that you render it in a
 *  webview or browser to receive attribution.
 */
@property (nonatomic, readonly, copy) NSURL *attributionURL;

/**
 *  Full/Original Image URL (for Image results only).
 *  This will be empty for web and video results.
 */
@property (nonatomic, readonly, copy) NSURL *fullURL;

/**
 *  Thumbnail URL (for Image and Video results only)
 *  This will be empty for web results.
 */
@property (nonatomic, readonly, copy) NSURL *thumbnailURL;

/**
 *  Address of a location or POI (for Local search results only)
 */
@property (nonatomic, readonly, copy) NSString *address;

@end