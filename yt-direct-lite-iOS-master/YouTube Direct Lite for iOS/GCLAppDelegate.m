//
//  GCLAppDelegate.m
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 11/22/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "GCLAppDelegate.h"
#import "MainViewController.h"
#import "MyMainViewController.h"

@implementation GCLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    
//    MyMainViewController *viewController = [[MyMainViewController alloc]init];
//    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
//    navController.toolbarHidden = NO;
//    [[self window] setRootViewController:navController];
//    
//    
//    
//    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
    
    return YES;
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
