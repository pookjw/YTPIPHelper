//
//  MainViewModel.h
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 4/1/21.
//

#import <UIKit/UIKit.h>
#import "MainResultIem.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const MainViewModelRequestSuccessfulNotification = @"MainViewModelRequestSuccessfulNotification";
static NSString * const MainViewModelRequestErrorNotification = @"MainViewModelRequestErrorNotification";
typedef UICollectionViewDiffableDataSource<NSNumber *, MainResultIem *> MainDataSource;
typedef NSDiffableDataSourceSnapshot MainSnapshot;

@interface MainViewModel : NSObject
@property (strong) MainDataSource *dataSource;
- (void)requestFromVideoID:(NSString *)videoID;
- (MainResultIem * _Nullable)resultItemFromIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
