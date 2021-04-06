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

- (NSArray<NSDictionary *> * _Nullable)videoStreamingURLsFromResultInfo:(NSDictionary *)resultInfo
                                                                  error:(NSError ** _Nullable)error {
    NSArray<NSDictionary *> *formats = resultInfo[@"streamingData"][@"formats"];
    NSArray<NSDictionary *> *adaptiveFormats = resultInfo[@"streamingData"][@"adaptiveFormats"];
    
    NSMutableArray<NSDictionary *> *results = [[@[] mutableCopy] autorelease];
    if (formats) [results addObjectsFromArray:formats];
    if (adaptiveFormats) [results addObjectsFromArray:adaptiveFormats];
    
    if (((results.count == 0)) && (error != NULL)) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                     code:VideoInfoServiceErrorNoAvailableStreamingData
                                 userInfo:@{NSLocalizedDescriptionKey: @"No available streamingData formats!"}];
        return nil;
    }
    return [[results copy] autorelease];
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
