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
#import <AFNetworking.h>
#import "DMM3u8Parse.h"
#import <AVFoundation/AVFoundation.h>


#define kScreeenW [UIScreen mainScreen].bounds.size.width
#define kScreeenH [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,GCDWebServerDelegate>

@property (nonatomic, strong) GCDWebServer *webServer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<DMGoodsModel *> *goodsList;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLocalServer];
    
    [self loadData];
    [self.tableView reloadData];
}

- (NSString *)getLocolServerRootPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [NSString stringWithFormat:@"%@/goodsVideo", path];
    return path;
}

- (void)createLocalServer
{
    NSString *rootPath = [self getLocolServerRootPath];
    GCDWebServer *webServer = [GCDWebServer new];
    webServer.delegate = self;
    [webServer addGETHandlerForBasePath:@"/" directoryPath:rootPath indexFilename:@"v.m3u8" cacheAge:3600 allowRangeRequests:YES];
    [webServer startWithPort:8080 bonjourName:nil];
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
        model._id = [NSString stringWithFormat:@"%tu",idx];
        [mArr addObject:model];
    }];

    
    self.goodsList = [mArr copy];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildPlayer:(NSString *)path {
    NSString *str = [NSString stringWithFormat:@"http://localhost:8080/%@/v.m3u8",path];
    NSURL *url = [NSURL URLWithString:str];
    
    AVURLAsset *playerAsset = [AVURLAsset assetWithURL:url];
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:playerAsset];
    
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        return;
    }
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    playerLayer.frame = CGRectMake(0, 64, kScreeenW, 160);
    
    [self.view.layer addSublayer:playerLayer];
    
    //监听播放状态变化
    [self.player addObserver:self forKeyPath:@"status"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([object isKindOfClass:[self.player class]]) {
        
        if ([keyPath isEqualToString:@"status"]) {
            //状态改变
            AVPlayerStatus oldStatus = [((NSNumber *)change[@"old"]) integerValue];
            AVPlayerStatus newStatus = [((NSNumber *)change[@"new"]) integerValue];
            NSLog(@"%ld--%ld", (long)oldStatus, (long)newStatus);
            if (newStatus == AVPlayerStatusReadyToPlay) {
                [self.player play];
            }
        }
    }
}

- (void)downloadWithUrl:(NSURL *)url path:(NSString *)aPath completionHandler:(void(^)(NSError *error))completionHandler{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *path = NSTemporaryDirectory();
        NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:path];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:aPath];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSError *err;
        [fileManager createDirectoryAtPath:aPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager moveItemAtURL:filePath toURL:documentsDirectoryURL error:&err];
        NSLog(@"File downloaded to: %@", aPath);
        if(completionHandler){
            completionHandler(err);
        }
    }];
    
    [downloadTask resume];
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
    __weak typeof (self) weakSelf = self;
    cell.downloadBlock = ^(DMGoodsModel *goods) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSURL *url = [NSURL URLWithString:goods.videourl];
        NSString *downloadPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        downloadPath = [downloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"goodsVideo/%@",goods._id]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
            [strongSelf buildPlayer:goods._id];
            return ;
        }
        //下载m3u8文件
        [strongSelf downloadWithUrl:url path:downloadPath completionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"%@",error.localizedDescription);
                return ;
            }
            //解析m3u8
            
            DMM3u8Parse *parse = [DMM3u8Parse new];
            [parse parseM3U8With:url completionHandler:^(NSArray<NSString *> *infos, NSError *error) {
                if (error) {
                    NSLog(@"%@",error.localizedDescription);
                    return ;
                }
                [infos enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSURL *url = [NSURL URLWithString:obj];
                    [strongSelf downloadWithUrl:url path:downloadPath completionHandler:^(NSError *error) {
                        if (error) {
                            NSLog(@"%@",error.localizedDescription);
                            return ;
                        }
                        [strongSelf buildPlayer:goods._id];
                    }];
                }];
            }];
        }];

    };
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.goodsList.count;
}

/**
 *  This method is called after the server has successfully started.
 */
- (void)webServerDidStart:(GCDWebServer*)server
{
    NSLog(@"%s",__func__);
}


- (void)webServerDidCompleteBonjourRegistration:(GCDWebServer*)server
{
    NSLog(@"%s",__func__);
}


- (void)webServerDidUpdateNATPortMapping:(GCDWebServer*)server
{
    NSLog(@"%s",__func__);
}

- (void)webServerDidConnect:(GCDWebServer*)server
{
    NSLog(@"%s",__func__);
}

- (void)webServerDidDisconnect:(GCDWebServer*)server
{
    NSLog(@"%s",__func__);
}

- (void)webServerDidStop:(GCDWebServer*)server
{
    NSLog(@"%s",__func__);
}

//MARK: lazy
- (GCDWebServer *)webServer
{
    if(!_webServer){
        _webServer = [[GCDWebServer alloc] init];
    }
    return _webServer;
}
@end
