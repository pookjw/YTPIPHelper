//
//  MainResultIem.m
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 4/1/21.
//

#import "MainResultIem.h"

@implementation MainResultIem

- (void)dealloc {
    [_mainText release];
    [_secondaryText release];
    [_url release];
    [super dealloc];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[MainResultIem class]]) {
        MainResultIem *compareObject = (MainResultIem *)object;
        return ([self.mainText isEqualToString:compareObject.mainText] &&
                [self.secondaryText isEqualToString:compareObject.secondaryText]);
    } else {
        return NO;
    }
}

@end
