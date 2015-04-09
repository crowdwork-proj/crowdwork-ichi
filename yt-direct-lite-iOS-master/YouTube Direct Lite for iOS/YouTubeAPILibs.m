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




- (void)getAll
{
    
    GTLQueryYouTube *query;
    
    query = [GTLQueryYouTube queryForGuideCategoriesListWithPart:@"snippet"];
    query.regionCode = @"US";
    query.hl = @"en-US";
    
    
    //__block NSMutableArray *blockVideos = self.videos;
    
    // let's get the categories
    [self.youtubeService executeQuery:query completionHandler:^(GTLServiceTicket *blockTicket, GTLYouTubeGuideCategoryListResponse *list, NSError *error) {
        
        GTLYouTubeGuideCategory *cat = [list.items objectAtIndex:0];
        
        GTLQueryYouTube *channelsQuery = [GTLQueryYouTube queryForChannelsListWithPart:@"id,snippet"];
        channelsQuery.categoryId = cat.identifier;
        channelsQuery.maxResults = 10; // only need one, but maxresults = 1 is slower than 10
        
        
        // let's get the channels for the given category
        __unused GTLServiceTicket *channelsTicket = [self.youtubeService executeQuery:channelsQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeChannelListResponse *channelList, NSError *videoError) {
            
            // we are only interested in one channel: the best of the best
            [channelList.items enumerateObjectsUsingBlock:^(GTLYouTubeChannel *channel, NSUInteger idx, BOOL *stop) {
                
                if( [channel.snippet.title isEqualToString:@"Popular on YouTube - Worldwide"] )
                {
                    // get related playlists for our channel
                    
                    GTLQueryYouTube *playlistsQuery = [GTLQueryYouTube queryForPlaylistsListWithPart:@"id,snippet"];
                    playlistsQuery.channelId = channel.identifier;
                    playlistsQuery.maxResults = 20;
                    
                    __unused GTLServiceTicket *playlistsTicket = [self.youtubeService executeQuery:playlistsQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubePlaylistListResponse *playlistsResponse, NSError *error) {
                        
                        // list of related playlists: only 1
                        [playlistsResponse.items enumerateObjectsUsingBlock:^(GTLYouTubePlaylistItem *playlist, NSUInteger idx, BOOL *stop) {
                            NSLog(@"obj: %@", playlist.identifier);
                            
                            GTLQueryYouTube *videosQuery = [GTLQueryYouTube queryForPlaylistItemsListWithPart:@"id,snippet"];
                            videosQuery.playlistId = playlist.identifier;
                            videosQuery.maxResults = 20;
                            
                            __unused GTLServiceTicket *videosTicket = [self.youtubeService executeQuery:videosQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubePlaylistItemListResponse *playlistItemsResponse, NSError *error) {
                                
                                
                                [playlistItemsResponse.items enumerateObjectsUsingBlock:^(GTLYouTubePlaylistItem *playlistItem, NSUInteger idx, BOOL *stop) {
                                    GTLYouTubeVideo *video = (GTLYouTubeVideo *)playlistItem.snippet.resourceId;
                                    NSString *videoTitle = playlistItem.snippet.title;
                                    NSString *videoId = [video.JSON valueForKey:@"videoId"];
                                    
                                    NSLog(@"videoid: %@", videoId);
                                    NSLog(@"title: %@", videoTitle);
                                    
                                    
                                    //[blockVideos addObject:@{@"title":videoTitle,@"identifier":videoId}];
                                }];
                                
                                //[self.tableView reloadData];
                                
                            }];
                        }];
                    }];
                    
                    return;
                }
                
            }];
        }];
    }];
    
    
}


// =================================================================
// 動画一覧
// Hiển thị các list video của người dùng
// Anh viết mẫu chứ chưa chạy đâu
// =================================================================

- (NSString*)showMyListVideo
{
    self.youtubeService = [[GTLServiceYouTube alloc] init];
    self.youtubeService.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:kClientSecret];
    
    GTLQueryYouTube *query = [GTLQueryYouTube queryForPlaylistsListWithPart:@"id, snippet, contentDetails"];
    [self.youtubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (!error) {
            GTLYouTubePlaylistListResponse *items = object;
            for (GTLYouTubePlaylist * item in items) {
                NSLog(@"------%@",item);
            }
            
        } else {
            NSLog(@"%@", error);
        }
    }];
    return nil;
}

// =================================================================
// Hàm kiểm tra đăng nhập
//
// =================================================================

// Helper to check if user is authorized
- (BOOL)isAuthorized {
    return [((GTMOAuth2Authentication *)self.youtubeService.authorizer) canAuthorize];
}

// Creates the auth controller for authorizing access to YouTube.


- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}
@end
