//
//  GCLAppDelegate.h
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 11/22/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouTubeAPILibs.h"
#import "Utils.h"
@interface GCLAppDelegate : UIResponder <UIApplicationDelegate,YouTubeAPILibsDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
