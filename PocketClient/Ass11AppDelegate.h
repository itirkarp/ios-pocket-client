//
//  Ass11AppDelegate.h
//  Ass11CustomApplication
//
//  Created by swin on 20/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Ass11AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) UIStoryboard* storyboard ;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
