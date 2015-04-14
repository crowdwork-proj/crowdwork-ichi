//
//  MyMainViewController.m
//  YouTube Direct Lite for iOS
//
//  Created by imybags.com on 9/4/15.
//  Copyright (c) 2015 Google. All rights reserved.
//

#import "MyMainViewController.h"
#import "ShowMyListVideoController.h"
#import "VideoListViewController.h"
#import "ChanelListViewController.h"
#import "LikeListViewController.h"
#import "MyPlayListViewController.h"
#import "ViewAfterListViewController.h"
#import "MyMainViewController.h"
#import  "CategoriesViewController.h"
@interface MyMainViewController ()

@end

@implementation MyMainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

// ログイン
- (IBAction)onLogin:(id)sender
{
    YouTubeAPILibs *youtubeApiLibs = [YouTubeAPILibs sharedManager];
    youtubeApiLibs.delegate = self;
    [youtubeApiLibs doLoginWithViewController:self];
    
    
}

// 画像一覧
- (IBAction)docategoryVideo:(id)sender{
    
    CategoriesViewController *category = [[CategoriesViewController alloc]init];
    [self.navigationController pushViewController:category animated:YES];
   
}

// マイアップロード
- (IBAction)doGetMyUpload:(id)sender
{
    VideoListViewController *videoListController = [[VideoListViewController alloc]init];
    [self.navigationController  pushViewController:videoListController animated:YES];
}
// マイチャネル
- (IBAction)doGetMyChanel:(id)sender
{
    ChanelListViewController *chanelListViewController = [[ChanelListViewController alloc]init];
    [self.navigationController pushViewController:chanelListViewController animated:YES];
}
// 後で見る
- (IBAction)doViewAfter:(id)sender
{
    ViewAfterListViewController *viewAfterViewController = [[ViewAfterListViewController alloc]init];
    [self.navigationController pushViewController:viewAfterViewController animated:YES];
}
// 気になる
- (IBAction)doGetListLike:(id)sender
{
    LikeListViewController *liveViewController = [[LikeListViewController alloc]init];
    [self.navigationController pushViewController:liveViewController animated:YES];
}
// プレイ一人
- (IBAction)doGetMyPlayList:(id)sender
{
    MyPlayListViewController *playListViewController = [[MyPlayListViewController alloc]init];
    [self.navigationController pushViewController:playListViewController animated:YES];
}

#pragma mark - YouTubeAPILibsDelegate methods

- (void)getYouTubeUploads:(YouTubeAPILibs *)getUploads withRequestType:(YTRequestType)type didFinishWithResults:(NSArray *)results {
    if (type == YTRequestTypeShowMyListVideo) {
        NSLog(@"video data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            VideoData *data = [results objectAtIndex:i];
            NSLog(@"=====================================\n");
            NSLog(@" thumbnail data [%@] \n",data.thumbnail);
            NSLog(@" title          [%@] \n",[data getTitle]);
            NSLog(@" view           [%@] \n",data.getViews);
            NSLog(@" duration       [%@] \n",[Utils humanReadableFromYouTubeTime:data.getDuration]);
            NSLog(@"=====================================\n");
        }
    }
    
    //[1] 全てカテゴリを習得
    if (type == YTRequestTypeCategories) {
        NSLog(@"categories data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            GTLYouTubeGuideCategory *data = [results objectAtIndex:i];
            
            NSLog(@"=====================================\n");
            NSLog(@"CATEGORIES                           \n");
            NSLog(@" title          [%@] \n",data.snippet.title);
            NSLog(@" identifier     [%@] \n",[data identifier]);
            NSLog(@"=====================================\n");
            
            // identifierでカテゴリの全てチャネルを習得
            [[YouTubeAPILibs sharedManager] getChannelsWithCategoryIdentifier:data.identifier andMaxResults:1];
        }
    }
    
    
    //[2]: カテゴリの全てチャネルを習得
    if (type == YTRequestTypeChannels) {
        NSLog(@"chanels data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            GTLYouTubeChannel *data = [results objectAtIndex:i];
            
            NSLog(@"=====================================\n");
            NSLog(@"CHANNELS                             \n");
            NSLog(@" title          [%@] \n",data.snippet.title);
            NSLog(@" identifier     [%@] \n",[data identifier]);
            NSLog(@"=====================================\n");
            
            // チャネルに対して全てプレイリストを習得
            [[YouTubeAPILibs sharedManager] getPlaylistsWithChannelIdentifier:data.identifier andMaxResults:1];
        }
    }
    
    //[3]: チャネルに対して全てプレイリストを習得
    if (type == YTRequestTypePlaylists) {
        NSLog(@"playlists data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            GTLYouTubePlaylistItem *data = [results objectAtIndex:i];
            NSLog(@"=====================================\n");
            NSLog(@"PLAYLIST_LIST                        \n");
            NSLog(@" title          [%@] \n",data.snippet.title);
            NSLog(@" identifier     [%@] \n",[data identifier]);
            NSLog(@"=====================================\n");
            
            //チャネルのビデオ一覧を習得
            [[YouTubeAPILibs sharedManager] getVideosWithPlaylistIdentifier:data.identifier andMaxResults:1];
        }
    }
    
    //[4]: プレイリストのビデオを習得
    if (type == YTRequestTypeVideos) {
        NSLog(@"playlist data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            GTLYouTubePlaylistItem *data = [results objectAtIndex:i];
            NSLog(@"=====================================\n");
            NSLog(@"VIDEOS                               \n");
            NSLog(@" title          [%@] \n",data.snippet.title);
            NSLog(@" identifier     [%@] \n",[data identifier]);
            NSLog(@"=====================================\n");
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
