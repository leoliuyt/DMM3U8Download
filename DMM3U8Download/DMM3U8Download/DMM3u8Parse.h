//
//  DMM3u8Parse.h
//  DMM3U8Download
//
//  Created by lbq on 2017/8/23.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMM3u8Parse : NSObject

- (void)parseM3U8With:(NSURL *)url completionHandler:(void(^)(NSArray<NSString *>*infos ,NSError *error))completionHandler;

@end
