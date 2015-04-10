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
    YTRequestTypeShowMyPlayList = 4
    
};

@protocol YouTubeAPILibsDelegate;

@interface YouTubeAPILibs : NSObject

@property(nonatomic, weak) id<YouTubeAPILibsDelegate> delegate;
@property (nonatomic, retain) GTLServiceYouTube *youtubeService;
@property(nonatomic, strong)  YouTubeGetUploads *getUploads;

+ (id)sharedManager;



// link tham khảo
// youtbue 3.0
// https://developers.google.com/youtube/v3/docs/
// các api liên quan
// http://dev7dev.blogspot.jp/2014/07/videos-from-youtube-channel-in-ios-app.html
// đối ứng việc hiển thị video ở bản Youtube API 3.0
// https://developers.google.com/youtube/2.0/developers_guide_protocol_movies_and_shows?hl=ja
// http://stackoverflow.com/questions/19725950/youtube-related-videos-using-youtube-v3-api

// =================================================================
// =================================================================
//                                                           =======
//                 Các thư viện cần thực hiện                =======
//                                                           =======
// =================================================================
// =================================================================
// Thực hiện login vào Youtube, dùng cơ chế OAuth của nó để xác thực
// =================================================================
- (void)doLoginWithViewController:(UIViewController *) viewController;
// =================================================================
// 動画一覧
// Hiển thị các list video của người dùng
// =================================================================
- (void)getAll;
- (void)showMyListVideo;
// =================================================================
// チャンネル
// Hiển thị các kênh của người dùng
// =================================================================
- (void)getMyChanel;
// =================================================================
// お気に入る
// Hiển thị các danh sách like video của người dùng
// =================================================================
- (NSString*)getListLike;
// =================================================================
// プレイリスト
// Hiển thị các list video người dùng play
// =================================================================
- (NSString*)showMyPlaylist;
// =================================================================
// 検索
// Tìm kiếm video theo từ khoá
// =================================================================
- (NSString*)searchVideo:(NSString*)_keyword;
// =================================================================
// 後で見る
// Hiển thị các kênh người dùng xem sau
// =================================================================
- (void)showListVideoViewLater;
// =================================================================
// あなたへのおすすめ
// Hiển thị các video , có thể người dùng thích xem, kiểu recomandation
// =================================================================
- (NSString*)showlistRecommendationVideo;
// Hàm hỗ trợ
- (BOOL)isAuthorized;
@end

@protocol YouTubeAPILibsDelegate<NSObject>

- (void)getYouTubeUploads:(YouTubeAPILibs *)getUploads withRequestType:(YTRequestType) type
     didFinishWithResults:(NSArray *)results;
/* Ứng với mỗi hàm thì add thêm một protocol để truyền dữ liệu cho người dùng khi gọi thư viện */

@end


