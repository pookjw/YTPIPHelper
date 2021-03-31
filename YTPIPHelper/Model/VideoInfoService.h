//
//  VideoInfoService.h
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 3/29/21.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VideoInfoServiceError) {
    VideoInfoServiceErrorEmptyPlayerResponse,
    VideoInfoServiceErrorNoAvailableStreamingData,
    VideoInfoServiceErrorNoAvailableStreamingURL,
    VideoInfoServiceErrorInvalidStreamingURL
};

NS_ASSUME_NONNULL_BEGIN

@interface VideoInfoService : NSObject
- (void)requestUsingVideoID:(NSString *)videoID
         completionHandler:(void (^)(NSDictionary * _Nullable resultInfo, NSError * _Nullable error))completionHandler;
- (void)requestGreatestQualityVideoStreamingURLUsingVideoID:(NSString *)videoID
                                          completionHandler:(void (^)(NSURL * _Nullable streamingURL, NSError * _Nullable error))completionHandler;
- (void)requestVideoStreamingURLsUsingVideoID:(NSString *)videoID
                            completionHandler:(void (^)(NSArray<NSDictionary *> *  _Nullable formats, NSError * _Nullable error))completionHandler;


- (NSArray<NSDictionary *> * _Nullable)videoStreamingURLsFromResultInfo:(NSDictionary *)resultInfo
                                                                  error:(NSError ** _Nullable)error;

- (NSURL * _Nullable)greatestQualityVideoStreamingURLFromResultInfo:(NSDictionary *)resultInfo
                                                              error:(NSError ** _Nullable)error;
@end

NS_ASSUME_NONNULL_END
