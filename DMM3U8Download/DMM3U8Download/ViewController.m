//
//  ViewController.m
//  DMM3U8Download
//
//  Created by lbq on 2017/8/22.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "ViewController.h"
#import "DMGoodsCell.h"
#import "DMGoodsModel.h"
#import <GCDWebServer.h>

#define kScreeenW [UIScreen mainScreen].bounds.size.width
#define kScreeenH [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) GCDWebServer *webServer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<DMGoodsModel *> *goodsList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    [self.tableView reloadData];
}

- (void)createLocalServer
{
    self.webServer = [[GCDWebServer alloc] init];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [NSString stringWithFormat:@"%@/goodsVideo/", path];
    [self.webServer addGETHandlerForBasePath:@"/" directoryPath:path indexFilename:@"v.m3u8" cacheAge:3600 allowRangeRequests:YES];
    [self.webServer startWithPort:8080 bonjourName:nil];
}

- (void)loadData
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"error:%@",error.localizedDescription);
        return;
    }
    
    NSArray<NSDictionary *> *arr = dic[@"data"][@"returndata"][@"ad_list"];
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:arr.count];
    [arr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DMGoodsModel *model = [DMGoodsModel new];
        model.title = obj[@"title"];
        model.name = obj[@"name"];
        model.image = obj[@"image"];
        model.videourl = obj[@"videourl"];
        [mArr addObject:model];
    }];
    
    self.goodsList = [mArr copy];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//MARK: UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kScreeenW * 218./320.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FLT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//MARK: UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DMGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DMGoodsCell"];
    cell.goods = self.goodsList[indexPath.section];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.goodsList.count;
}
@end
