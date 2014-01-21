//
//  SearchViewController.m
//  Ass11CustomApplication
//
//  Created by swin on 20/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsViewController.h"
#import "PocketAPI.h"
#import "SearchedArticle.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize searchedArticles;
@synthesize keywordsTextField;
@synthesize activityIndicator;
@synthesize overlayView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)search:(id)sender {
    [self showActivityIndicator];
    [self fetchAllArticles];
}

- (void)handleGetResponse:(NSDictionary *)response {
    self.searchedArticles = [[NSMutableArray alloc] init];
    NSDictionary *list =  [response objectForKey:@"list"];
    SearchedArticle *article = nil;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];

    for (NSString *itemId in list) {
        NSDictionary *articleJSON = [list objectForKey:itemId];
        if ([[articleJSON objectForKey:@"status"] isEqual: @"0"]) {
            article = [[SearchedArticle alloc] initWithItemId:itemId heading:[articleJSON objectForKey:@"resolved_title"] body:[articleJSON objectForKey:@"excerpt"] favorite:[f numberFromString:[articleJSON objectForKey:@"favorite"]]];
            [self.searchedArticles addObject:article];
        }
    }
}

- (void)fetchAllArticles {
    NSDictionary *arguments = @{@"state" : @"all", @"since" : @"974874207", @"search": self.keywordsTextField.text};
    [[PocketAPI sharedAPI] callAPIMethod:@"get"
                          withHTTPMethod:PocketAPIHTTPMethodPOST
                               arguments:arguments
                                 handler: ^(PocketAPI *api, NSString *apiMethod,NSDictionary *response, NSError *error){
                                     [self hideActivityIndicator];
                                     if ([response count] == 0) {
                                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
                                                                                           message:@"Could not search. Please try again later."
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:@"OK"
                                                                                 otherButtonTitles:nil];
                                         [message show];
                                         return;
                                     }
                                     if ([[response objectForKey:@"list"] count] == 0) {
                                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
                                                                                           message:@"No matching articles found."
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:@"OK"
                                                                                 otherButtonTitles:nil];
                                         [message show];
                                         return;
                                     }
                                    [self handleGetResponse:response];
                                    [self performSegueWithIdentifier:@"search" sender:nil];
                                 }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] prepareTableView:self.searchedArticles];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.keywordsTextField) {
        [self.keywordsTextField resignFirstResponder];
    }
    return YES;
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

@end
