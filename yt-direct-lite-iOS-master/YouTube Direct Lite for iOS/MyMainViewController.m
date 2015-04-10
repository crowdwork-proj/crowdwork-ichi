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
#import "MyMainViewController.h"

@interface MyMainViewController ()

@end

@implementation MyMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    /*YouTubeAPILibs *youtubeApiLibs = [YouTubeAPILibs sharedManager];
    youtubeApiLibs.delegate = self;
    [youtubeApiLibs doLoginWithViewController:self];
    */
    
    //[youtubeApiLibs showMyListVideo];
    //[youtubeApiLibs getAll];
    
    //Lấy tất cả các category từ yoututbe
    //[youtubeApiLibs getCategoriesWithRegionCode:@"US" andLanguage:@"en-US"];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ( [[YouTubeAPILibs sharedManager] isLogged ] == true ) {
        loginButton.hidden = YES;
    }
}

- (IBAction)onLogin:(id)sender
{
    YouTubeAPILibs *youtubeApiLibs = [YouTubeAPILibs sharedManager];
    youtubeApiLibs.delegate = self;
    [youtubeApiLibs doLoginWithViewController:self];
}


- (IBAction)doGetMyUpload:(id)sender
{
    VideoListViewController *videoListController = [[VideoListViewController alloc]init];
    [self.navigationController  pushViewController:videoListController animated:YES];
}

- (IBAction)doGetMyChanel:(id)sender
{
    ChanelListViewController *chanelListViewController = [[ChanelListViewController alloc]init];
    [self.navigationController pushViewController:chanelListViewController animated:YES];
}

- (IBAction)doGetListVideo:(id)sender
{

}

- (IBAction)doGetListLike:(id)sender
{
    
}

- (IBAction)doGetMyPlayList:(id)sender
{
    
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
    
    //Đầu tiên là lấy hết categories về
    if (type == YTRequestTypeCategories) {
        NSLog(@"categories data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            GTLYouTubeGuideCategory *data = [results objectAtIndex:i];
            
            NSLog(@"=====================================\n");
            NSLog(@"CATEGORIES                           \n");
            NSLog(@" title          [%@] \n",data.snippet.title);
            NSLog(@" identifier     [%@] \n",[data identifier]);
            NSLog(@"=====================================\n");
            
            //dùng identifier để lấy hết các kênh của 1 category
            [[YouTubeAPILibs sharedManager] getChannelsWithCategoryIdentifier:data.identifier andMaxResults:1];
        }
    }
    
    
    //Bước 2: lấy hết channels của 1 category nào đó
    if (type == YTRequestTypeChannels) {
        NSLog(@"chanels data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            GTLYouTubeChannel *data = [results objectAtIndex:i];
            
            NSLog(@"=====================================\n");
            NSLog(@"CHANNELS                             \n");
            NSLog(@" title          [%@] \n",data.snippet.title);
            NSLog(@" identifier     [%@] \n",[data identifier]);
            NSLog(@"=====================================\n");
            
            //Mỗi channel có nhiều playlist, lấy hết nó về
            [[YouTubeAPILibs sharedManager] getPlaylistsWithChannelIdentifier:data.identifier andMaxResults:1];
        }
    }
    
    //Bước 3: lấy hết playlist của 1 channel về
    if (type == YTRequestTypePlaylists) {
        NSLog(@"playlists data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            GTLYouTubePlaylistItem *data = [results objectAtIndex:i];
            NSLog(@"=====================================\n");
            NSLog(@"PLAYLIST_LIST                        \n");
            NSLog(@" title          [%@] \n",data.snippet.title);
            NSLog(@" identifier     [%@] \n",[data identifier]);
            NSLog(@"=====================================\n");
            
            //mỗi channel có nhiều videos, hãy lấy hết các video đó về
            [[YouTubeAPILibs sharedManager] getVideosWithPlaylistIdentifier:data.identifier andMaxResults:1];
        }
    }
    
    //Bước 4: lấy hết videos của 1 playlist về
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
