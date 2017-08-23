//
//  DMGoodsModel.h
//  DMM3U8Download
//
//  Created by lbq on 2017/8/22.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <Foundation/Foundation.h>
//"title": "99%\u6d53\u7f29\u5373\u98df",
//"link": "9138559",
//"type": "1",
//"image": "http:\/\/pic.ghs.net\/public\/images\/1c\/7e\/f0\/b947ae20c86edf2ddbcfaeeed13ee887237c59bd.jpg",
//"starttime": 1502672400,
//"endtime": 1534176000,
//"videourl": "http:\/\/cdn.video.ghs.net\/%E5%85%88%E5%AF%BC750-510\/138559%20%E7%9A%87%E5%B8%9D%E7%87%95%E7%AA%9D%E4%BE%9B%E7%BB%84\/v.m3u8",
//"is_login": "0",
//"wap_image": "",
//"sort_order": "10",
//"share_title": "",
//"share_content": "",
//"adv_icon": "",
//"name": "\u7687\u5e1d\u71d5\u7a9d99%\u71d5\u7a9d\u73af\u7403\u72ec\u4f9b\u7ec4",
//"is_kjt": "0",
//"price": 899,
//"price_flag": ""

@interface DMGoodsModel : NSObject

@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *videourl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *_id;

@end
