//
//  Article.h
//  Ass11CustomApplication
//
//  Created by swin on 20/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Article : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * heading;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * itemId;

@end
