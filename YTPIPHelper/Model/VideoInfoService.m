//
//  VideoInfoService.m
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 3/29/21.
//

#import "VideoInfoService.h"

@implementation VideoInfoService

- (void)requestUsingVideoID:(NSString *)videoID
         completionHandler:(void (^)(NSDictionary * _Nullable resultInfo, NSError * _Nullable error))completionHandler {
    NSString *stringURL = [NSString stringWithFormat:@"https://www.youtube.com/get_video_info?video_id=%@", videoID];
    NSURL *url = [NSURL URLWithString:stringURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    
    NSURLSessionDataTask *task = [session
                                  dataTaskWithRequest:[[request copy] autorelease]
                                  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        //
        
        NSString *playerResponse = [self playerResponseFromData:data];
        
        if (playerResponse == nil) {
            NSError *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                                 code:VideoInfoServiceErrorEmptyPlayerResponse
                                             userInfo:@{NSLocalizedDescriptionKey: @"player_response is empty!"}];
            completionHandler(nil, error);
            return;
        }
        
        //
        
        NSError * _Nullable jsonError = nil;
        NSDictionary *resultInfo = [NSJSONSerialization JSONObjectWithData:[playerResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&jsonError];
        if (jsonError) {
            completionHandler(nil, jsonError);
            return;
        }
        
        if (resultInfo) {
            completionHandler(resultInfo, nil);
        }
    }];
    
    [request release];
    [task resume];
    [session finishTasksAndInvalidate];
}

- (void)requestGreatestQualityVideoStreamingURLUsingVideoID:(NSString *)videoID
                                          completionHandler:(void (^)(NSURL * _Nullable streamingURL, NSError * _Nullable error))completionHandler {
    [self requestUsingVideoID:videoID
            completionHandler:^(NSDictionary * _Nullable resultInfo, NSError * _Nullable error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSError * _Nullable greatestQualityError = nil;
        NSURL * _Nullable streamingURL = [self greatestQualityVideoStreamingURLFromResultInfo:resultInfo
                                                       error:&greatestQualityError];
        if (greatestQualityError) {
            completionHandler(nil, greatestQualityError);
            return;
        }
        completionHandler(streamingURL, nil);
    }];
}

- (void)requestVideoStreamingURLsUsingVideoID:(NSString *)videoID
                            completionHandler:(void (^)(NSArray<NSDictionary *> *  _Nullable formats, NSError * _Nullable error))completionHandler {
    [self requestUsingVideoID:videoID
            completionHandler:^(NSDictionary * _Nullable resultInfo, NSError * _Nullable error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSError * _Nullable formatsError = nil;
        NSArray<NSDictionary *> * _Nullable formats = [self videoStreamingURLsFromResultInfo:resultInfo
                                                       error:&formatsError];
        if (formatsError) {
            completionHandler(nil, formatsError);
            return;
        }
        completionHandler(formats, nil);
    }];
}

- (NSURL * _Nullable)greatestQualityVideoStreamingURLFromResultInfo:(NSDictionary *)resultInfo
                                               error:(NSError ** _Nullable)error {
    NSArray<NSDictionary *> *formats = resultInfo[@"streamingData"][@"formats"];
    if ((formats == nil) && (*error != NULL)) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                     code:VideoInfoServiceErrorNoAvailableStreamingData
                                 userInfo:@{NSLocalizedDescriptionKey: @"No available streamingData formats!"}];
        return nil;
    }
    
    NSString * _Nullable __block tempString = nil;
    NSInteger width = -1;
    
    [formats enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull format, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *stringURL = format[@"url"];
        NSNumber *widthNumber = format[@"width"];
        if ((stringURL == nil) || (widthNumber == nil)) return;
        if ([widthNumber integerValue] > width) {
            tempString = stringURL;
        }
    }];
    
    if ((tempString == nil) && (*error != NULL)) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                     code:VideoInfoServiceErrorNoAvailableStreamingURL
                                 userInfo:@{NSLocalizedDescriptionKey: @"No available streaming URL!"}];
        return nil;
    }
    
    NSURL *resultURL = [[[NSURL alloc] initWithString:(NSString * _Nonnull)tempString] autorelease];
    
    if (resultURL == nil) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                     code:VideoInfoServiceErrorInvalidStreamingURL
                                 userInfo:@{NSLocalizedDescriptionKey: @"Invalid streaming URL!"}];
        return nil;
    }
    
    return resultURL;
}

- (NSArray<NSDictionary *> * _Nullable)videoStreamingURLsFromResultInfo:(NSDictionary *)resultInfo
                                                                  error:(NSError ** _Nullable)error {
    NSArray<NSDictionary *> *formats = resultInfo[@"streamingData"][@"formats"];
    if (((formats == nil) || (formats.count == 0)) && (*error != NULL)) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                     code:VideoInfoServiceErrorNoAvailableStreamingData
                                 userInfo:@{NSLocalizedDescriptionKey: @"No available streamingData formats!"}];
        return nil;
    }
    return formats;
}

- (NSString * _Nullable)playerResponseFromData:(NSData *)data {
    NSString *stringFromData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray<NSString *> *componentsFromString = [stringFromData componentsSeparatedByString:@"&"];
    [stringFromData release];
    
    for (NSString *s in componentsFromString) {
        NSArray<NSString *> *componentsFromS = [s componentsSeparatedByString:@"="];
        if (componentsFromS.count < 2) {
            continue;
        }
        if ([componentsFromS[0] isEqualToString:@"player_response"]) {
            return componentsFromS[1].stringByRemovingPercentEncoding;
        }
    }
    
    return nil;
}

@end
