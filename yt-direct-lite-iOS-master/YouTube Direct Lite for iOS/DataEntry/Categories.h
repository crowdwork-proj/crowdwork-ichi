//
//  VideoData.h
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 10/21/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLYouTube.h"

@interface Categories : NSObject
    @property(nonatomic, strong) UIImage *thumbnail;
    @property(nonatomic, strong) UIImage *fullImage;
    @property(nonatomic, strong) NSString *title;
    @property(nonatomic, strong) NSString *categoriId;

-(NSString *)getThumbUri;
@end
