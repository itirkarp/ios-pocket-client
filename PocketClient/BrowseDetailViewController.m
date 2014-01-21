//
//  BrowseDetailViewController.m
//  Ass11CustomApplication
//
//  Created by swin on 20/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import "BrowseDetailViewController.h"
#import "Article.h"
#import "PocketAPI.h"

@interface BrowseDetailViewController ()

@end

@implementation BrowseDetailViewController

@synthesize bodyTextView;
@synthesize headingTextView;
@synthesize activityIndicator;
@synthesize overlayView;
@synthesize article;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bodyTextView.text = self.article.body;
    self.headingTextView.text = self.article.heading;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareDetailView:(Article *)articleParam {
    self.article = articleParam;
}

- (void)showActivityIndicator {
    self.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:self.overlayView];
}

- (void)hideActivityIndicator {
    [self.activityIndicator removeFromSuperview];
    [self.overlayView removeFromSuperview];
}

- (IBAction)favouriteButton:(id)sender {
    [self showActivityIndicator];
    NSArray *actions = [NSArray arrayWithObject:@{@"action" : @"favorite", @"item_id" : self.article.itemId}];
    NSDictionary *arguments = @{@"actions": actions};
    [[PocketAPI sharedAPI] callAPIMethod:@"send"
                          withHTTPMethod:PocketAPIHTTPMethodPOST
                               arguments:arguments
                                 handler: ^(PocketAPI *api, NSString *apiMethod,NSDictionary *response, NSError *error){
                                     [self hideActivityIndicator];
                                     UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
                                                                                       message:@"Added to Favourites"
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"OK"
                                                                             otherButtonTitles:nil];
                                     [message show];
                                 }];
}

- (IBAction)share:(id)sender {
    // Email Subject
    NSString *emailTitle = self.headingTextView.text;
    // Email Content
    NSString *messageBody = self.bodyTextView.text;
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
