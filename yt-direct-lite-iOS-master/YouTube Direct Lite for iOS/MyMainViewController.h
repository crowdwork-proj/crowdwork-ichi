//
//  MyMainViewController.h
//  YouTube Direct Lite for iOS
//
//  Created by imybags.com on 9/4/15.
//  Copyright (c) 2015 Google. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouTubeAPILibs.h"
#import "Utils.h"

@interface MyMainViewController : UIViewController <YouTubeAPILibsDelegate>
{
    IBOutlet UIButton *loginButton;
    IBOutlet UIButton *categoryVideo;
    IBOutlet UIButton *getMyUploadButton;
    IBOutlet UIButton *getMyChanelButton;
    IBOutlet UIButton *getListVideoButton;
    IBOutlet UIButton *getListLikeButton;
    IBOutlet UIButton *getMyPlaylistButton;
    IBOutlet UIButton *viewAfterButton;
    
}

- (IBAction)onLogin:(id)sender;
- (IBAction)docategoryVideo:(id)sender;
- (IBAction)doGetMyUpload:(id)sender;
- (IBAction)doGetMyChanel:(id)sender;
- (IBAction)doGetListVideo:(id)sender;
- (IBAction)doGetListLike:(id)sender;
- (IBAction)doGetMyPlayList:(id)sender;
- (IBAction)doViewAfter:(id)sender;

@end
