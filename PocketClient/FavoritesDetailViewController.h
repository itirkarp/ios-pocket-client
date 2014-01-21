//
//  FavoritesDetailViewController.h
//  Ass11CustomApplication
//
//  Created by swin on 20/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import <MessageUI/MessageUI.h> 

@interface FavoritesDetailViewController : UIViewController<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;

@property (weak, nonatomic) IBOutlet UITextView *headingTextView;
- (void)prepareDetailView:(Article *)article;
- (IBAction)share:(id)sender;
@property (retain) Article *article;
@end
