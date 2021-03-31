//
//  MainViewController.m
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 3/29/21.
//

#import <AVKit/AVKit.h>
#import "MainViewController.h"
#import "MainViewModel.h"
#import "UIViewController+Category.h"

@interface MainViewController () <UICollectionViewDelegate>
@property (strong, atomic) MainViewModel *viewModel;
@property (strong, atomic) UICollectionView *collectionView;
@property (strong, atomic) UICollectionViewCellRegistration *cellRegistration;
@end

@implementation MainViewController

- (void)dealloc {
    [_viewModel release];
    [_collectionView release];
    [_cellRegistration release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAttributes];
    [self configureCollectionView];
    [self configureViewModel];
    [self bind];
}

- (void)requestFromVideoID:(NSString *)videoID {
    NSLog(@"%@", videoID);
    [self.viewModel requestFromVideoID:videoID];
}

- (void)configureViewModel {
    MainViewModel *viewModel = [MainViewModel new];
    self.viewModel = viewModel;
    [viewModel release];
    
    viewModel.dataSource = [self makeDataSource];
}

- (void)setAttributes {
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.title = NSBundle.mainBundle.infoDictionary[@"CFBundleName"];
}

- (void)bind {
    if (self.viewModel) {
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(errorOccuredNotification:)
                                                   name:MainViewModelRequestErrorNotification
                                                 object:self.viewModel];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(requestSuccessfulNotificaion:)
                                                   name:MainViewModelRequestSuccessfulNotification
                                                 object:self.viewModel];
    }
}

- (void)errorOccuredNotification:(NSNotification * _Nonnull)notification {
    NSError *error = notification.userInfo[@"error"];
    if (error == nil) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showErrorAlertWithError:error];
    });
}

- (void)requestSuccessfulNotificaion:(NSNotification * _Nonnull)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showSuccessfulAlert];
    });
}

- (void)configureCollectionView {
    UICollectionLayoutListConfiguration *layoutConfiguration = [[UICollectionLayoutListConfiguration alloc] initWithAppearance:UICollectionLayoutListAppearanceSidebar];
    UICollectionViewCompositionalLayout *layout = [UICollectionViewCompositionalLayout layoutWithListConfiguration:layoutConfiguration];
    [layoutConfiguration release];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView = collectionView;
    [collectionView release];
    [self.view addSubview:collectionView];
    [collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
    
    collectionView.delegate = self;
    
    self.cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:[UICollectionViewCell class]
                                                                   configurationHandler:^(__kindof UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        MainResultIem *resultItem;
        if ([item isKindOfClass:[MainResultIem class]]) {
            resultItem = (MainResultIem *)item;
        } else {
            return;
        }
        UIListContentConfiguration *configuration = [UIListContentConfiguration sidebarCellConfiguration];
        configuration.text = resultItem.mainText;
        configuration.secondaryText = resultItem.secondaryText;
        cell.contentConfiguration = configuration;
    }];
}

- (MainDataSource *)makeDataSource {
    __weak typeof(self) weakSelf = self;
    MainDataSource *dataSource = [[MainDataSource alloc] initWithCollectionView:self.collectionView
                                                                   cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, id  _Nonnull itemIdentifier) {
        UICollectionViewCell *cell = [collectionView dequeueConfiguredReusableCellWithRegistration:weakSelf.cellRegistration
                                                                                      forIndexPath:indexPath
                                                                                              item:itemIdentifier];
        return cell;
    }];
    return dataSource;
}

- (void)playVideoWithURL:(NSURL *)url {
    AVPlayer *player = [[AVPlayer alloc] initWithURL:url];
    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
    vc.player = player;
    [player release];
    [self presentViewController:vc animated:YES completion:^{}];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MainResultIem * _Nullable resultItem = [self.viewModel resultItemFromIndexPath:indexPath];
    NSURL * _Nullable url = resultItem.url;
    if (url) {
        [self playVideoWithURL:url];
    }
}

@end
