//
//  STYoutubeViewController.m
//  StoryTelling
//
//  Created by Aaswini on 01/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STYoutubeViewController.h"
#import <GTLUtilities.h>
#import <GTMHTTPUploadFetcher.h>
#import <GTMHTTPFetcherLogging.h>
#import <GTMOAuth2ViewControllerTouch.h>


@interface STYoutubeViewController ()

@end
NSString *const kKeychainItemName = @"Stroto: YouTube";
NSURL *uploadLocationURL;

@interface STYoutubeViewController ()
// Accessor for the app's single instance of the service object.
@property (nonatomic, readonly) GTLServiceYouTube *youTubeService;
@end

@implementation STYoutubeViewController{
    GTLServiceTicket *_uploadFileTicket;
}

@synthesize mainTitle,subTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	
    // Load the OAuth 2 token from the keychain, if it was previously saved.
    //    clientID = @"283801024967.apps.googleusercontent.com";
    //    clientSecret = @"K18TEG58lqLlR1AhpBEluY2B";
    
    clientID = @"847626307960.apps.googleusercontent.com";
    clientSecret = @"hKBN9pEi7Nm7dXD740-3MHmW";
    
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:clientID clientSecret:clientSecret];
    
    self.youTubeService.authorizer = auth;
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    
    if (![self isSignedIn]) {
        // Sign in.
        GTMOAuth2ViewControllerTouch *signin = [GTMOAuth2ViewControllerTouch controllerWithScope:kGTLAuthScopeYouTube clientID:clientID clientSecret:clientSecret keychainItemName:kKeychainItemName delegate:self finishedSelector:@selector(viewController:finishedWithAuth:error:)];
        
        [self presentViewController:signin animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)signIn:(id)sender {
//    
//    // Sign out.
//        GTLServiceYouTube *service = self.youTubeService;
//        
//        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
//        service.authorizer = nil;
//}

- (NSString *)signedInUsername {
    // Get the email address of the signed-in user.
    GTMOAuth2Authentication *auth = self.youTubeService.authorizer;
    BOOL isSignedIn = auth.canAuthorize;
    if (isSignedIn) {
        return auth.userEmail;
    } else {
        return nil;
    }
}

- (BOOL)isSignedIn {
    NSString *name = [self signedInUsername];
    return (name != nil);
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error{
    
    if (error == nil) {
        self.youTubeService.authorizer = auth;
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        NSLog(@"ERROR : %@",error);
    }
}

- (IBAction)upload:(id)sender {
    [self uploadVideoFile];
}

#pragma mark - Upload

- (void)uploadVideoFile {
    // Collect the metadata for the upload from the user interface.
    
    // Status.
    GTLYouTubeVideoStatus *status = [GTLYouTubeVideoStatus object];
    status.privacyStatus = @"private";
    
    // Snippet.
    GTLYouTubeVideoSnippet *snippet = [GTLYouTubeVideoSnippet object];
    NSString *text = [mainTitle text];
    snippet.title = text;
    
    NSString *desc = [subTitle text];
    if ([desc length] > 0) {
    snippet.descriptionProperty = desc;
    }
    //    NSString *tagsStr = [_uploadTagsField stringValue];
    //    if ([tagsStr length] > 0) {
    //        snippet.tags = [tagsStr componentsSeparatedByString:@","];
    //    }
    //    if ([_uploadCategoryPopup isEnabled]) {
    //        NSMenuItem *selectedCategory = [_uploadCategoryPopup selectedItem];
    //        snippet.categoryId = [selectedCategory representedObject];
    //    }
    
    GTLYouTubeVideo *video = [GTLYouTubeVideo object];
    video.status = status;
    video.snippet = snippet;
    
    [self uploadVideoWithVideoObject:video
             resumeUploadLocationURL:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [subTitle resignFirstResponder];
    [mainTitle resignFirstResponder];
    return  YES;
}


//- (void)restartUpload {
//    // Restart a stopped upload, using the location URL from the previous
//    // upload attempt
//    if (_uploadLocationURL == nil) return;
//
//    // Since we are restarting an upload, we do not need to add metadata to the
//    // video object.
//    GTLYouTubeVideo *video = [GTLYouTubeVideo object];
//
//    [self uploadVideoWithVideoObject:video
//             resumeUploadLocationURL:_uploadLocationURL];
//}

- (void)uploadVideoWithVideoObject:(GTLYouTubeVideo *)video
           resumeUploadLocationURL:(NSURL *)locationURL {
    // Get a file handle for the upload data.
    //    NSString *path = [_uploadPathField stringValue];
    
    NSString *moviePath = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@.mov", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [self.dbname stringByDeletingPathExtension]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:moviePath];
    if (fileHandle) {
        //        NSString *mimeType = [self MIMETypeForFilename:filename
        //                                       defaultMIMEType:@"video/mp4"];
        
        NSString *mimeType = @"video/quicktime";
        
        GTLUploadParameters *uploadParameters =
        [GTLUploadParameters uploadParametersWithFileHandle:fileHandle
                                                   MIMEType:mimeType];
        uploadParameters.uploadLocationURL = locationURL;
        
        GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosInsertWithObject:video
                                                                            part:@"snippet,status"
                                                                uploadParameters:uploadParameters];
        
        GTLServiceYouTube *service = self.youTubeService;
        _uploadFileTicket = [service executeQuery:query
                                completionHandler:^(GTLServiceTicket *ticket,
                                                    GTLYouTubeVideo *uploadedVideo,
                                                    NSError *error) {
                                    // Callback
                                    _uploadFileTicket = nil;
                                    NSString *alert = [NSString stringWithFormat:@"Uploaded file %@",uploadedVideo.snippet.title];
                                    if (error == nil) {
                                        [self displayAlert:@"Uploaded"
                                                    format:alert];
                                    } else {
                                        [self displayAlert:@"Upload Failed"
                                                    format:@"%@", error];
                                    }
                                    
                                    [uploadProgressIndicator setProgress:0];
                                    
                                    uploadLocationURL = nil;
                                }];
        
        UIProgressView *progressIndicator = uploadProgressIndicator;
        _uploadFileTicket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
                                                  unsigned long long numberOfBytesRead,
                                                  unsigned long long dataLength) {
            [progressIndicator setProgress:(double)numberOfBytesRead/(double)dataLength];
        };
        
        // To allow restarting after stopping, we need to track the upload location
        // URL.
        //
        // For compatibility with systems that do not support Objective-C blocks
        // (iOS 3 and Mac OS X 10.5), the location URL may also be obtained in the
        // progress callback as ((GTMHTTPUploadFetcher *)[ticket objectFetcher]).locationURL
        
        GTMHTTPUploadFetcher *uploadFetcher = (GTMHTTPUploadFetcher *)[_uploadFileTicket objectFetcher];
        uploadFetcher.locationChangeBlock = ^(NSURL *url) {
            uploadLocationURL = url;
        };
    } else {
        // Could not read file data.
        [self displayAlert:@"File Not Found" format:@"Path: %@", moviePath];
    }
}

//- (NSString *)MIMETypeForFilename:(NSString *)filename
//                  defaultMIMEType:(NSString *)defaultType {
//    NSString *result = defaultType;
//    NSString *extension = [filename pathExtension];
//    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
//                                                            (__bridge CFStringRef)extension, NULL);
//    if (uti) {
//        CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
//        if (cfMIMEType) {
//            result = CFBridgingRelease(cfMIMEType);
//        }
//        CFRelease(uti);
//    }
//    return result;
//}

- (void)displayAlert:(NSString *)title format:(NSString *)format, ... {
    NSString *result = format;
    if (format) {
        va_list argList;
        va_start(argList, format);
        result = [[NSString alloc] initWithFormat:format
                                        arguments:argList];
        va_end(argList);
    }
    [[[UIAlertView alloc]initWithTitle:title message:format delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
}

- (GTLServiceYouTube *)youTubeService {
    static GTLServiceYouTube *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLServiceYouTube alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    });
    return service;
}

@end
