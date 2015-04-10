//
//  YouTubeAPILibs.h
//  YouTube Direct Lite for iOS
//
//  Created by lehoang on 4/7/15.
//  Copyright (c) 2015 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLYouTube.h"
#import "VideoData.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "GTLYouTube.h"
#import "YouTubeGetUploads.h"
#import "YouTubeUploadVideo.h"

typedef NS_OPTIONS(NSUInteger, YTRequestType) {
    YTRequestTypeShowMyListVideo = 1,
    YTRequestTypeGetMyChanel = 2,
    YTRequestTypeGetListLike = 3,
    YTRequestTypeShowMyPlayList = 4,
    
    /*例外アクセスに向かい*/
    YTRequestTypeCategories = 11,
    YTRequestTypeChannels = 12,
    YTRequestTypePlaylists = 13,
    YTRequestTypeVideos = 14
};

@protocol YouTubeAPILibsDelegate;

@interface YouTubeAPILibs : NSObject

@property(nonatomic, weak) id<YouTubeAPILibsDelegate> delegate;
@property (nonatomic, retain) GTLServiceYouTube *youtubeService;
@property(nonatomic, strong)  YouTubeGetUploads *getUploads;

+ (id)sharedManager; // Singletones 機能

/*
*参照リンク
*youtbue 3.0
*https://developers.google.com/youtube/v3/docs/
*API
*http://dev7dev.blogspot.jp/2014/07/videos-from-youtube-channel-in-ios-app.html
*動画一覧3 V3.0に対して
*https://developers.google.com/youtube/2.0/developers_guide_protocol_movies_and_shows?hl=ja
*http://stackoverflow.com/questions/19725950/youtube-related-videos-using-youtube-v3-api
*/

/*
*===================================================================================================
*=======                                    YOUTUBE 3.0 API                                =========
*===================================================================================================
*/

// ログイン機能ーOAuthを利用する
- (void)doLoginWithViewController:(UIViewController *) viewController;
// 動画一覧
- (void)getAll;
- (void)showMyListVideo;
// チャンネル
- (void)getMyChanel;
// お気に入る
- (NSString*)getListLike;
// プレイリスト
- (NSString*)showMyPlaylist;
// 検索
- (NSString*)searchVideo:(NSString*)_keyword;
// 後で見る
- (void)showListVideoViewLater;
// あなたへのおすすめ
- (NSString*)showlistRecommendationVideo;

/*
*===================================================================================================
*===================================================================================================
*/

/* Youtube のサポート機能 */
// 全てケテゴリを習得
- (void)getCategoriesWithRegionCode: (NSString *) regionCode andLanguage: (NSString *) lang;
// カテゴリの各チャネルを習得
- (void)getChannelsWithCategoryIdentifier: (NSString *) identifier andMaxResults: (int) maxResult;
// チャネルの全てプレイリストを習得
- (void)getPlaylistsWithChannelIdentifier: (NSString *) identifier andMaxResults: (int) maxResult;
// プレイリストの全てビデオを習得
- (void)getVideosWithPlaylistIdentifier: (NSString *) identifier andMaxResults: (int) maxResult;
// 認識されたか
- (BOOL)isAuthorized;
- (BOOL)isLogged;
/*
*===================================================================================================
*===================================================================================================
*/

@end

@protocol YouTubeAPILibsDelegate<NSObject>
// プロトコル　ー　コルバック機能を返す
- (void)getYouTubeUploads:(YouTubeAPILibs *)getUploads withRequestType:(YTRequestType) type
     didFinishWithResults:(NSArray *)results;

@end


