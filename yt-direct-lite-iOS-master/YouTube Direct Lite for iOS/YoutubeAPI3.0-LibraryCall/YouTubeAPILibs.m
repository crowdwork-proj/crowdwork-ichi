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
#import "VideoListViewController.h"
#import "Utils.h"
#import "ChannelData.h"

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

// ログイン

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

/* APIを呼ぶ*/
- (void)callYoutubeAPI_MyYoutube:(NSUInteger)requestType
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
                            /*==================Delegate=============*/
                            /*=======================================*/
                            [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypeShowMyListVideo didFinishWithResults:nil];
                            return;
                        }
                        
                        NSLog(@"Finished API call");
                        
                        if ([[response items] count] > 0) {
                            
                            GTLYouTubeChannel *channel = response[0];
                            NSString *uploadsPlaylistId = nil;
                            switch (requestType) {
                                case YTRequestTypeGetListLike:
                                    uploadsPlaylistId = channel.contentDetails.relatedPlaylists.likes;
                                    break;
                                case YTRequestTypeShowMyListVideo:
                                    uploadsPlaylistId = channel.contentDetails.relatedPlaylists.uploads;
                                    break;
                                case YTRequestTypePlaylists:
                                    uploadsPlaylistId = channel.contentDetails.relatedPlaylists.watchHistory;
                                    break;
                                case YTRequestTypeViewVideoLater:
                                    uploadsPlaylistId = channel.contentDetails.relatedPlaylists.watchLater;
                                    break;
                                default:
                                    break;
                            }
                            
                            GTLQueryYouTube *playlistItemsListQuery = [GTLQueryYouTube queryForPlaylistItemsListWithPart:@"contentDetails"];
                            playlistItemsListQuery.maxResults = 20l;
                            playlistItemsListQuery.playlistId = uploadsPlaylistId;
                            
                            // This callback uses the block syntax
                            
                            [self.youtubeService executeQuery:playlistItemsListQuery
                             
                                            completionHandler:^(GTLServiceTicket *ticket, GTLYouTubePlaylistItemListResponse
                                                                
                                                                *response, NSError *error) {
                                                
                                                if (error) {
                                                    [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypeShowMyListVideo didFinishWithResults:nil];
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
                                                                        /*==================Delegate=============*/
                                                                        /*=======================================*/
                                                                        [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypeShowMyListVideo didFinishWithResults:nil];
                                                                        return;
                                                                    }
                                                                    
                                                                    NSLog(@"Finished API call");
                                                                    NSMutableArray *videos = [NSMutableArray arrayWithCapacity:response.items.count];
                                                                    VideoData *vData;
                                                                    
                                                                    for (GTLYouTubeVideo *video in response.items){
                                                                        if ([@"public" isEqualToString:video.status.privacyStatus]){
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
                                                                            /*==================Delegate=============*/
                                                                            /*=======================================*/
                                                                            [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypeShowMyListVideo didFinishWithResults:videos];
                                                                            return;
                                                                        });
                                                                    });
                                                                    
                                                                }];
                                            }];
                        }
                    }];
    
    return;

}

/* 画像一覧 */

- (void)getMyUploadVideo
{
    [self callYoutubeAPI_MyYoutube:YTRequestTypeShowMyListVideo];
    return;
}

/*後で見る*/

- (void)getMyListSeeVideoLater{
    
    [self callYoutubeAPI_MyYoutube:YTRequestTypeViewVideoLater];
    return ;
}

/*自分のプレイリストーHistory*/

- (void)getMyPlayList{
    
    [self callYoutubeAPI_MyYoutube:YTRequestTypePlaylists];
    return ;
}

// 気になる一覧

- (void)getListLike{

    [self callYoutubeAPI_MyYoutube:YTRequestTypeViewVideoLater];
    return;
}

/*マイチャンネル*/

- (void)getMyChanel {
    
    GTLQueryYouTube * query = [GTLQueryYouTube queryForSubscriptionsListWithPart:@"id,snippet"];
    query.mine = YES;
    query.maxResults = 50;
    
    // let's get the categories
    [self.youtubeService executeQuery:query completionHandler:^(GTLServiceTicket *blockTicket, GTLYouTubeSubscriptionListResponse *list, NSError *error) {
        
        if (error) {
            [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypeGetMyChanel  didFinishWithResults:nil];
            return;
        }
        
        NSMutableArray *channelData = [NSMutableArray arrayWithCapacity:list.items.count];
        ChannelData *channel;
        
        for (GTLYouTubeSubscription *sub in list.items){
             channel = [ChannelData alloc];
             channel.subChannel = sub;
             [channelData addObject:channel];
        }
        
        // Schedule an async job to fetch the image data for each result and
        // resize the large image in to a smaller thumbnail.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableArray *removeThese = [NSMutableArray array];
            
            for (ChannelData *vData in channelData) {
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
            [channelData removeObjectsInArray:removeThese];
            
            // Once all the images have been fetched and cached, call
            // our delegate on the main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                /*==================Delegate=============*/
                /*=======================================*/
                [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypeGetMyChanel didFinishWithResults:channelData];
                return;
            });
        });
        
    }];

}

/*youtubeから全てケテゴリを習得*/
/*グロバルビデオからビデオを習得する*/

- (void)getCategoriesWithRegionCode: (NSString *) regionCode andLanguage: (NSString *) lang {
    GTLQueryYouTube *query;
    
    query = [GTLQueryYouTube queryForGuideCategoriesListWithPart:@"snippet"];
    query.regionCode = regionCode; //@"US"
    query.hl = lang; //@"en-US"
    
    //__block NSMutableArray *blockVideos = self.videos;
    // let's get the categories
    [self.youtubeService executeQuery:query completionHandler:^(GTLServiceTicket *blockTicket, GTLYouTubeGuideCategoryListResponse *list, NSError *error) {
        
        if (error) {
            [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypeCategories  didFinishWithResults:nil];
            return;
        }
        
        NSMutableArray *categories = [NSMutableArray arrayWithCapacity:list.items.count];
        
        [list.items enumerateObjectsUsingBlock:^(GTLYouTubeGuideCategory *category, NSUInteger idx, BOOL *stop) {
            [categories addObject:category];
        }];
        // our delegate on the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            /*==================Delegate=============*/
            /*=======================================*/
            [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypeCategories didFinishWithResults:categories];
            return;
        });

    }];
}

/*各ケテゴリに対して全てチャネルを習得*/

- (void)getChannelsWithCategoryIdentifier: (NSString *) identifier andMaxResults: (int) maxResult {
    GTLQueryYouTube *channelsQuery = [GTLQueryYouTube queryForChannelsListWithPart:@"id,snippet"];
    channelsQuery.categoryId = identifier;
    channelsQuery.maxResults = maxResult;
    
    // let's get the channels for the given category
    __unused GTLServiceTicket *channelsTicket = [self.youtubeService executeQuery:channelsQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeChannelListResponse *channelList, NSError *error) {
        
        if (error) {
            [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypeChannels didFinishWithResults:nil];
            return;
        }
        
        NSMutableArray *chanels = [NSMutableArray arrayWithCapacity:channelList.items.count];
        
        // we are only interested in one channel: the best of the best
        [channelList.items enumerateObjectsUsingBlock:^(GTLYouTubeChannel *channel, NSUInteger idx, BOOL *stop) {
            [chanels addObject:channel];            
        }];
        // our delegate on the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            /*==================Delegate=============*/
            /*=======================================*/
            [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypeChannels didFinishWithResults:chanels];
            return;
        });
        
    }];
}


/*各チャネルに対して全てプレイシストを習得*/

- (void)getPlaylistsWithChannelIdentifier: (NSString *) identifier andMaxResults: (int) maxResult {
    
    GTLQueryYouTube *playlistsQuery = [GTLQueryYouTube queryForPlaylistsListWithPart:@"id,snippet"];
    
    playlistsQuery.channelId = identifier;
    playlistsQuery.maxResults = maxResult;
    
    __unused GTLServiceTicket *playlistsTicket = [self.youtubeService executeQuery:playlistsQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubePlaylistListResponse *playlistsResponse, NSError *error) {
        
        if (error) {
            [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypePlaylists didFinishWithResults:nil];
            return;
        }
        
        NSMutableArray *playlists = [NSMutableArray arrayWithCapacity:playlistsResponse.items.count];
        
        // list of related playlists: only 1
        [playlistsResponse.items enumerateObjectsUsingBlock:^(GTLYouTubePlaylistItem *playlist, NSUInteger idx, BOOL *stop) {
            [playlists addObject:playlist];
        }];
        // our delegate on the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            /*==================Delegate=============*/
            /*=======================================*/
            [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypePlaylists didFinishWithResults:playlists];
            return;
        });
    }];

}

/*プレイリストに対して全てプレイイテムリストを習得*/

- (void)getVideosWithPlaylistIdentifier: (NSString *) identifier andMaxResults: (int) maxResult {
    
    GTLQueryYouTube *videosQuery = [GTLQueryYouTube queryForPlaylistItemsListWithPart:@"id,snippet"];
    videosQuery.playlistId = identifier;
    videosQuery.maxResults = 20;
    
    __unused GTLServiceTicket *videosTicket = [self.youtubeService executeQuery:videosQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubePlaylistItemListResponse *playlistItemsResponse, NSError *error) {
        
        if (error) {
            /*==================Delegate=============*/
            /*=======================================*/
            [self.delegate getYouTubeUploads:self withRequestType:YTRequestTypeVideos didFinishWithResults:nil];
            return;
        }
        
        [playlistItemsResponse.items enumerateObjectsUsingBlock:^(GTLYouTubePlaylistItem *playlistItem, NSUInteger idx, BOOL *stop) {
            
            /*習得されたビデオデータ*/
            GTLYouTubeVideo *video = (GTLYouTubeVideo *)playlistItem.snippet.resourceId;
            NSString *videoTitle = playlistItem.snippet.title;
            NSString *videoId = [video.JSON valueForKey:@"videoId"];
            NSLog(@"==============================================");
            NSLog(@"videoid: [%@]\n", videoId);
            NSLog(@"title:   [%@]\n", videoTitle);
            NSLog(@"==============================================");
        }];
        
    }];
}

/* -------------------- YOUTUBE OAUTH CALLBACK --------
   ---------------------------------------------------- */
- (BOOL)isAuthorized {
    return [((GTMOAuth2Authentication *)self.youtubeService.authorizer) canAuthorize];
}

// OAuthを呼ぶ
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
// OAuthコルバック
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


@end
