//
//  MALocationDetailController.m
//  MAWebChat
//
//  Created by nwk on 2017/1/16.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MALocationDetailController.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "MAConfig.h"
#import "UIView+MARect.h"


@interface MALocationDetailController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
{
    BMKPoiSearch *_poiSearch;    //poi搜索
}
@property(nonatomic,strong)BMKMapView* mapView;
@property(nonatomic,strong)BMKLocationService* locService;

@property(nonatomic,assign)CLLocationCoordinate2D currentCoordinate;
@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) UINavigationBar *navBar;

@end

@implementation MALocationDetailController

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title {
    self = [super init];
    if (self) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        self.currentCoordinate = coordinate;
        self.titleStr = title;
    }
    
    return self;
}
- (UINavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 15, CGRectGetWidth(self.view.frame), 64)];
        //创建一个item
        UINavigationItem *item = [[UINavigationItem alloc]initWithTitle:@"位置信息"];
        _navBar.items = @[item];
        
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [leftBtn addTarget:self action:@selector(closeEvent) forControlEvents:UIControlEventTouchUpInside];
        leftBtn.width = 64;
        leftBtn.height = 64;
        item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    }
    
    return _navBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.titleStr;
    
    [self configUI];
    [self startLocation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locService.delegate =self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.mapView viewWillDisappear];
    self.mapView.delegate =nil;// 不用时，置nil
    self.locService.delegate =nil;
}

- (void)closeEvent {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)configUI
{
    [self.view addSubview:self.navBar];
    
    [self.view addSubview:self.mapView];
}

-(void)startLocation
{
    [self.locService startUserLocationService];
    
    self.mapView.showsUserLocation = NO;//先关闭显示的定位图层
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
}

- (void)addAnnotation {
    BMKPointAnnotation *point = [[BMKPointAnnotation alloc]init];
    
    point.coordinate = self.currentCoordinate;
    point.title = self.titleStr;
    
    [self.mapView addAnnotation:point];
    
    [self showCenterMap:self.currentCoordinate];
}
//显示大头针范围 -》》》》》》》》》》经纬度需判断
-(void) showCenterMap:(CLLocationCoordinate2D)coordinate {
    BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance(coordinate,0.3, 0.3);//范围
    BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
}
BMKCoordinateRegion BMKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D coordinate,int latitudeDelta,int longitudeDelta)
{
    BMKCoordinateSpan span;
    span.latitudeDelta = latitudeDelta;
    span.longitudeDelta = longitudeDelta;
    
    BMKCoordinateRegion region;
    region.center = coordinate;
    region.span = span;
    
    return region;
}
#pragma mark - BMKMapViewDelegate

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [self.mapView updateLocationData:userLocation];
    [self.locService stopUserLocationService];
    [self addAnnotation];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"1111");
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
    
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"map view: click blank");
}
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"2222");
}
- (void)mapStatusDidChanged:(BMKMapView *)mapView {
    NSLog(@"3333");
}

#pragma mark - InitMethod

-(BMKMapView*)mapView
{
    if (_mapView==nil)
    {
        _mapView =[[BMKMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.navBar.frame))];
        _mapView.zoomEnabled=YES;
        _mapView.zoomEnabledWithTap=NO;
        _mapView.zoomLevel=17;
    }
    return _mapView;
}

-(BMKLocationService*)locService
{
    if (_locService==nil)
    {
        _locService = [[BMKLocationService alloc]init];
    }
    return _locService;
}
@end
