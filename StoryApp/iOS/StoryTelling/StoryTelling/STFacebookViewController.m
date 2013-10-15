//
//  STFacebookViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 04/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STFacebookViewController.h"
#import <Social/Social.h>

#define ST_FACEBOOK_APP_ID @"530535203701796"
@interface STFacebookViewController ()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;

@end

@implementation STFacebookViewController

@synthesize storyTitle;
@synthesize storySubTitle;
@synthesize uploadButton;
@synthesize uploadProgressBar;
@synthesize filepath;
@synthesize storySubTitleString;
@synthesize storyTitleString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
//    NSLog(@"FB isOpen : %@ ",FBSession.activeSession.isOpen?@"Yes":@"No");
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.uploadProgressBar.progress = 0.0f;
	// Do any additional setup after loading the view.
    self.storyTitle.text = storyTitleString;
    self.storySubTitle.text = storySubTitleString;
    
//social framework ios
    if(!_accountStore)
        _accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *facebookTypeAccount = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    //read request

        [_accountStore requestAccessToAccountsWithType:facebookTypeAccount
                                           options:@{ACFacebookAppIdKey: ST_FACEBOOK_APP_ID, ACFacebookPermissionsKey: @[@"basic_info"]}
                                        completion:^(BOOL granted, NSError *error) {
                                            if(granted){
                                                NSArray *accounts = [_accountStore accountsWithAccountType:facebookTypeAccount];
                                                _facebookAccount = [accounts lastObject];
                                                NSLog(@"Read Success");
                                                //do nothing, as here we dont want user info.
                                            }else{
                                                // ouch
                                                NSLog(@"Fail");
                                                NSLog(@"Error: %@", error);
                                            }
                                        }];

}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)upload
{
    //social framework ios
    NSURL *videourl = [NSURL URLWithString:@"https://graph.facebook.com/me/videos"];
    
    NSURL *pathURL = [[NSURL alloc]initFileURLWithPath:filepath isDirectory:NO];
    
    NSData *videoData = [NSData dataWithContentsOfFile:filepath];
    
    
    NSDictionary *params = @{@"title": storyTitle.text,
                             @"description":storySubTitle.text};
    
    SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                              requestMethod:SLRequestMethodPOST
                                                        URL:videourl
                                                 parameters:params];
    NSLog(@"FILE: %@", [pathURL absoluteString]);
    [merequest addMultipartData:videoData
                       withName:@"source"
                           type:@"video/quicktime"
                       filename:[pathURL absoluteString]];
    
    merequest.account = _facebookAccount;
    NSURLRequest *request = [merequest preparedURLRequest];
    NSURLConnection *reConnect = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [reConnect scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.uploadProgressBar setHidden:NO];
    [reConnect start];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
//    NSLog(@"bytesWritten :%d",bytesWritten);
//    NSLog(@"totalBytesWritten :%d",totalBytesWritten);
//    NSLog(@"totalBytesExpectedToWrite :%d",totalBytesExpectedToWrite);
//    [self.uploadProgressBar setHidden:NO];
    float progress =(float) totalBytesWritten/totalBytesExpectedToWrite;
    NSLog(@"progress :%f",progress);
    self.uploadProgressBar.progress = progress;
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Video Upload Complete" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.uploadProgressBar setHidden:NO];
    NSLog(@"response: %@",response);
    NSLog(@"response.expectedContentLength: %lld",response.expectedContentLength);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error: %@",error);

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField

{
    [storyTitle resignFirstResponder];
    [storySubTitle resignFirstResponder];
    return  YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//upload button click
- (IBAction)uploadStory:(UIButton *)sender {
    [self.uploadProgressBar setHidden:NO];
    
    //video upload using social framework.
    ACAccountType *facebookTypeAccount = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];    [_accountStore requestAccessToAccountsWithType:facebookTypeAccount
                                           options:@{ACFacebookAppIdKey:ST_FACEBOOK_APP_ID, ACFacebookPermissionsKey: @[@"publish_stream"], ACFacebookAudienceKey: ACFacebookAudienceFriends}
                                        completion:^(BOOL granted, NSError *error) {
                                            if(granted){
                                                NSArray *accounts = [_accountStore accountsWithAccountType:facebookTypeAccount];
                                                _facebookAccount = [accounts lastObject];
                                                NSLog(@"Success, upload starting");
                                                //upload video.
                                                [self.uploadProgressBar setHidden:NO];
                                                [self upload];
                                                
                                            }else{
                                                // ouch
                                                NSLog(@"Fail");
                                                NSLog(@"Error: %@", error);
                                            }
                                        }];

    
}

@end
