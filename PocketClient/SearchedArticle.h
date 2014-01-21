//
//  SearchedArticle.h
//  Ass11CustomApplication
//
//  Created by swin on 23/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchedArticle : NSObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * heading;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * itemId;
- (id)initWithItemId:(NSString *)itemId heading:(NSString *)heading body:(NSString *)body
            favorite:(NSNumber *)favorite;

@end
