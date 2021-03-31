//
//  MainViewModel.m
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 4/1/21.
//

#import "MainViewModel.h"
#import "VideoInfoService.h"

@implementation MainViewModel

- (void)dealloc {
    [_dataSource release];
    [super dealloc];
}

- (MainResultIem * _Nullable)resultItemFromIndexPath:(NSIndexPath *)indexPath {
    NSArray<NSNumber *> *sections = [self.dataSource.snapshot sectionIdentifiers];
    if (sections.count <= indexPath.section) return nil;
    NSNumber *section = self.dataSource.snapshot.sectionIdentifiers[indexPath.section];
    NSArray<MainResultIem *> *resultItems = [self.dataSource.snapshot itemIdentifiersInSectionWithIdentifier:section];
    if (resultItems.count <= indexPath.row) return nil;
    return resultItems[indexPath.row];
}

- (void)requestFromVideoID:(NSString *)videoID {
    __weak typeof(self) weakSelf = self;
    VideoInfoService *service = [VideoInfoService new];
    [service requestVideoStreamingURLsUsingVideoID:videoID
                                 completionHandler:^(NSArray<NSDictionary *> * _Nullable formats, NSError * _Nullable error) {
        if (error) {
            [NSNotificationCenter.defaultCenter postNotificationName:MainViewModelRequestErrorNotification
                                                              object:self
                                                            userInfo:@{@"error": error}];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateResultItems:formats];
        });
        
        [service release];
    }];
}

- (void)updateResultItems:(NSArray<NSDictionary *> *)formats {
    MainSnapshot *snapshot = [self.dataSource snapshot];
    
    NSNumber *sectionNumber = snapshot.sectionIdentifiers.firstObject;
    
    if (sectionNumber == nil) {
        sectionNumber = @0;
        [snapshot appendSectionsWithIdentifiers:@[sectionNumber]];
    }
    
    [snapshot deleteAllItems];
    [snapshot appendSectionsWithIdentifiers:@[sectionNumber]];
    
    NSMutableArray<MainResultIem *> *results = [@[] mutableCopy];
    
    [formats enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *qualityLabel = obj[@"qualityLabel"];
        NSNumber *fps = obj[@"fps"];
        NSString *mimeType = obj[@"mimeType"];
        NSURL *url;
        if ((obj[@"url"] != nil) && ([obj[@"url"] isKindOfClass:[NSString class]])) {
            url = [NSURL URLWithString:obj[@"url"]];
        } else {
            url = nil;
        }
        
        MainResultIem *resultItem = [MainResultIem new];
        resultItem.mainText = [NSString stringWithFormat:@"%@ (%ld)", qualityLabel, (long)[fps integerValue]];
        resultItem.secondaryText = mimeType;
        resultItem.url = url;
        [results addObject:resultItem];
        [resultItem release];
    }];
    
    [snapshot appendItemsWithIdentifiers:[[results copy] autorelease]
               intoSectionWithIdentifier:sectionNumber];
    [results release];
    [self.dataSource applySnapshot:snapshot animatingDifferences:NO];
    
    [NSNotificationCenter.defaultCenter postNotificationName:MainViewModelRequestSuccessfulNotification
                                                      object:self
                                                    userInfo:@{}];
}

@end
