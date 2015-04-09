    //
//  YouTubeAPILibs.m
//  YouTube Direct Lite for iOS
//
//  Created by lehoang on 4/7/15.
//  Copyright (c) 2015 Google. All rights reserved.
//

#import "YouTubeAPILibs.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "VideoData.h"
#import "UploadController.h"
#import "VideoListViewController.h"
#import "Utils.h"
static const CGFloat kCropDimension = 44;
@implementation YouTubeAPILibs

@synthesize youtubeService;

+ (id)sharedManager {
    static YouTubeAPILibs *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

// =================================================================
// Thực hiện login vào Youtube, dùng cơ chế OAuth của nó để xác thực
// Anh viết mẫu chứ chưa chạy đâu
// =================================================================


- (void)doLoginWithViewController: (UIViewController *) viewController
{
    NSLog(@"---doLogin---");
    // Initialize the youtube service & load existing credentials from the keychain if available
    self.youtubeService = [[GTLServiceYouTube alloc] init];
    self.youtubeService.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
     
                                                      clientSecret:kClientSecret];
    if (![self isAuthorized]) {
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        [[viewController navigationController] pushViewController:[self createAuthController] animated:YES];
    }
}

/// Helper to check if user is authorized
- (BOOL)isAuthorized {
    return [((GTMOAuth2Authentication *)self.youtubeService.authorizer) canAuthorize];
}

// Creates the auth controller for authorizing access to YouTube.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeYouTube
                                                                clientID:kClientID
                                                            clientSecret:kClientSecret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and updates the YouTube service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [Utils showAlert:@"Authentication Error" message:error.localizedDescription];
        self.youtubeService.authorizer = nil;
    } else {
        self.youtubeService.authorizer = authResult;
    }
}

- (NSMutableArray*)showMyListVideo
{
    // Construct query
    GTLQueryYouTube *channelsListQuery = [GTLQueryYouTube
                                          
                                          queryForChannelsListWithPart:@"contentDetails"];
    
    channelsListQuery.mine = YES;
    
    // This callback uses the block syntax
    
    [self.youtubeService executeQuery:channelsListQuery
     
        completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeChannelListResponse
                            
                            *response, NSError *error) {
            
            if (error) {
                //[self.delegate getYouTubeUploads:self didFinishWithResults:nil];
                return;
            }
            
            NSLog(@"Finished API call");
            
            if ([[response items] count] > 0) {
                
                GTLYouTubeChannel *channel = response[0];
                
                NSString *uploadsPlaylistId =
                
                channel.contentDetails.relatedPlaylists.uploads;
                
                GTLQueryYouTube *playlistItemsListQuery = [GTLQueryYouTube queryForPlaylistItemsListWithPart:@"contentDetails"];
                playlistItemsListQuery.maxResults = 20l;
                playlistItemsListQuery.playlistId = uploadsPlaylistId;
                
                // This callback uses the block syntax
                
                [self.youtubeService executeQuery:playlistItemsListQuery
                 
                    completionHandler:^(GTLServiceTicket *ticket, GTLYouTubePlaylistItemListResponse
                                        
                                        *response, NSError *error) {
                        
                        if (error) {
                            //[self.delegate getYouTubeUploads:self didFinishWithResults:nil];
                            return;
                        }
                        
                        NSLog(@"Finished API call");
                        
                        NSMutableArray *videoIds = [NSMutableArray arrayWithCapacity:response.items.count];
                        
                        for (GTLYouTubePlaylistItem *playlistItem in response.items) {
                            
                            [videoIds addObject:playlistItem.contentDetails.videoId];
                            
                        }
                        
                        GTLQueryYouTube *videosListQuery = [GTLQueryYouTube queryForVideosListWithPart:@"id,contentDetails,snippet,status,statistics"];
                        videosListQuery.identifier = [videoIds componentsJoinedByString: @","];
                        
                        
                        [self.youtubeService executeQuery:videosListQuery
                         
                            completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeVideoListResponse
                                                
                                                *response, NSError *error) {
                                if (error) {
                                    //[self.delegate getYouTubeUploads:self didFinishWithResults:nil];
                                    return;
                                }
                                
                                NSLog(@"Finished API call");
                                NSMutableArray *videos = [NSMutableArray arrayWithCapacity:response.items.count];
                                VideoData *vData;
                                
                                for (GTLYouTubeVideo *video in response.items){
                                    if ([@"public" isEqualToString:video.status.privacyStatus]){
                                        NSLog(@"----video:%@",video);
                                        vData = [VideoData alloc];
                                        vData.video = video;
                                        [videos addObject:vData];
                                    }
                                }
                                
                                // Schedule an async job to fetch the image data for each result and
                                // resize the large image in to a smaller thumbnail.
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                    NSMutableArray *removeThese = [NSMutableArray array];
                                    
                                    for (VideoData *vData in videos) {
                                        // Fetch synchronously the full sized image.
                                        NSURL *url = [NSURL URLWithString:vData.getThumbUri];
                                        NSData *imageData = [NSData dataWithContentsOfURL:url];
                                        UIImage *image = [UIImage imageWithData:imageData];
                                        if (!image) {
                                            [removeThese addObject:vData];
                                            continue;
                                        }
                                        vData.fullImage = image;
                                        // Create a thumbnail from the fullsized image.
                                        UIGraphicsBeginImageContext(CGSizeMake(kCropDimension,
                                                                               kCropDimension));
                                        [image drawInRect:
                                         CGRectMake(0, 0, kCropDimension, kCropDimension)];
                                        vData.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                                        UIGraphicsEndImageContext();
                                    }
                                    
                                    // Remove images that has no image data.
                                    [videos removeObjectsInArray:removeThese];
                                    
                                    // Once all the images have been fetched and cached, call
                                    // our delegate on the main thread.
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        //[self.delegate getYouTubeUploads:self
                                        //            didFinishWithResults:videos];
                                        NSLog(@"video data %@",videos);
                                        for (int i =0 ; i < [videos count]; i++) {
                                            VideoData *data = [videos objectAtIndex:i];
                                            NSLog(@"=====================================\n");
                                            NSLog(@" thumbnail data [%@] \n",data.thumbnail);
                                            NSLog(@" title          [%@] \n",[data getTitle]);
                                            NSLog(@" view           [%@] \n",data.getViews);
                                            NSLog(@" duration       [%@] \n",[Utils humanReadableFromYouTubeTime:data.getDuration]);
                                            NSLog(@"=====================================\n");
                                        }
                                    });
                                });
                                
                            }];
                    }];
            }
        }];
    
    return nil;
}

@end
