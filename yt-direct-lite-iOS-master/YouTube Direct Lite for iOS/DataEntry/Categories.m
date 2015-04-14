//
//  VideoData.m
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 10/21/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "Categories.h"

@implementation Categories

-(NSString *)getWatchUri {
    return [@"http://www.youtube.com/watch?v=" stringByAppendingString:self.categoriId];
}

@end
