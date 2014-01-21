//
//  SearchedArticle.m
//  Ass11CustomApplication
//
//  Created by swin on 23/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import "SearchedArticle.h"

@implementation SearchedArticle


- (id)initWithItemId:(NSString *)itemId heading:(NSString *)heading body:(NSString *)body
            favorite:(NSNumber *)favorite {
    self = [super init];
    if (self) {
        _itemId = itemId;
        _body = body;
        _heading = heading;
        _favorite = favorite;
        return self;
    }
    return nil;
}

@end
