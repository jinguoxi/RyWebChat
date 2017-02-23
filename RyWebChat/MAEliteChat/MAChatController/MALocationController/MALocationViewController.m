//
//  MALocationViewController.m
//  SocketDemo
//
//  Created by nwk on 2017/1/10.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MALocationViewController.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>

#import "MALocationCell.h"
#import "MABaiduAnnotation.h"
#import "UIView+MARect.h"
#import "Masonry.h"
#import "MAConfig.h"


@interface MALocationViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UITableViewDataSource,UITableViewDelegate>
{
    BOOL isFirstLocation;
    BOOL touchAddressCell;
    UIButton *rightBtn;
}
@property(nonatomic,strong)BMKMapView* mapView;
@property(nonatomic,strong)BMKLocationService* locService;
@property(nonatomic,strong)BMKGeoCodeSearch* geocodesearch;
@property (strong, nonatomic) BMKPointAnnotation *annotation;

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataSource;

@property(nonatomic,assign)CLLocationCoordinate2D currentCoordinate;
@property(nonatomic,assign)NSInteger currentSelectLocationIndex;
@property(nonatomic,strong)UIImageView *centerCallOutImageView;
@property(nonatomic,strong)UIButton *currentLocationBtn;

@property (strong, nonatomic) UINavigationBar *navBar;

@end

@implementation MALocationViewController
#define kBaiduMapMaxHeight 300
#define kCurrentLocationBtnWH 40
#define kPading 10


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self configUI];
    
    [self startLocation];
}

- (UINavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
        //创建一个item
        UINavigationItem *item = [[UINavigationItem alloc]initWithTitle:@"位置"];
        _navBar.items = @[item];
        
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [leftBtn addTarget:self action:@selector(closeEvent) forControlEvents:UIControlEventTouchUpInside];
        leftBtn.width = 64;
        leftBtn.height = 64;
        item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        
        rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitle:@"发送" forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithRed:0.1563 green:0.8748 blue:0.0972 alpha:1.0] forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [rightBtn addTarget:self action:@selector(sendEvent) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.width = 64;
        rightBtn.height = 64;
        rightBtn.hidden = YES;
        item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
    
    return _navBar;
}

//关闭
- (void)closeEvent {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//发送
- (void)sendEvent {
    
    BMKPoiInfo *model=[self.dataSource objectAtIndex:self.currentSelectLocationIndex];
    
    [self.delegate sendlocation:model.pt title:model.name detail:model.address image:[self getMapImage]];
    
    [self closeEvent];
}

- (UIImage *)getMapImage {
    
    BMKLocationViewDisplayParam* testParam = [[BMKLocationViewDisplayParam alloc] init];
    testParam.isRotateAngleValid = true;// 跟随态旋转角度是否生效
    testParam.isAccuracyCircleShow = false;// 精度圈是否显示
    testParam.locationViewImgName = nil;// 定位图标名称
    testParam.locationViewOffsetX = 0;//定位图标偏移量(经度)
    testParam.locationViewOffsetY = 0;// 定位图标偏移量(纬度)
    [_mapView updateLocationViewWithParam:testParam]; //调用此方法后自定义定位图层生效
    
    UIImage *image = [self.mapView takeSnapshot];
    return image;
}

-(void)configUI
{
    [self.view addSubview:self.navBar];

    [self.view addSubview:self.mapView];
    
    [self.view addSubview:self.centerCallOutImageView];
    [self.view bringSubviewToFront:self.centerCallOutImageView];
    
    self.centerCallOutImageView.center = self.mapView.center;
    
    [self.mapView layoutIfNeeded];
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[MALocationCell class]forCellReuseIdentifier:@"MALocationCell"];
    
    
    self.currentLocationBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    self.currentLocationBtn.frame = CGRectMake(20, CGRectGetMaxY(self.mapView.frame)-(kCurrentLocationBtnWH+20), kCurrentLocationBtnWH, kCurrentLocationBtnWH);
    [self.currentLocationBtn setImage:[UIImage imageNamed:MAChatMsgBundleName(@"location_back_icon")]forState:UIControlStateNormal];
    [self.currentLocationBtn setImage:[UIImage imageNamed:MAChatMsgBundleName(@"location_blue_icon")]forState:UIControlStateSelected];
    [self.currentLocationBtn addTarget:self action:@selector(startLocation) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.currentLocationBtn];
    [self.view bringSubviewToFront:self.currentLocationBtn];
    
    [self.view bringSubviewToFront:self.navBar];
}

-(void)startLocation
{
    isFirstLocation=YES;//首次定位
    self.currentSelectLocationIndex=0;
    self.currentLocationBtn.selected=YES;
    [self.locService startUserLocationService];
    self.mapView.showsUserLocation =NO;//先关闭显示的定位图层
    self.mapView.userTrackingMode =BMKUserTrackingModeFollow;//设置定位的状态
    self.mapView.showsUserLocation =YES;//显示定位图层
    
    BMKLocationViewDisplayParam* testParam = [[BMKLocationViewDisplayParam alloc] init];
    testParam.isRotateAngleValid = true;// 跟随态旋转角度是否生效
    testParam.isAccuracyCircleShow = true;// 精度圈是否显示
    testParam.locationViewImgName = @"icon_center_point";// 定位图标名称
    testParam.locationViewOffsetX = 0;//定位图标偏移量(经度)
    testParam.locationViewOffsetY = 0;// 定位图标偏移量(纬度)
    [_mapView updateLocationViewWithParam:testParam]; //调用此方法后自定义定位图层生效
}

-(void)startGeocodesearchWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = coordinate;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

-(void)setCurrentCoordinate:(CLLocationCoordinate2D)currentCoordinate
{
    _currentCoordinate=currentCoordinate;
    [self startGeocodesearchWithCoordinate:currentCoordinate];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locService.delegate =self;
    self.geocodesearch.delegate =self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.mapView viewWillDisappear];
    self.mapView.delegate =nil;// 不用时，置nil
    self.locService.delegate =nil;
    self.geocodesearch.delegate =nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (_mapView)
    {
        _mapView = nil;
    }
    if (_geocodesearch)
    {
        _geocodesearch =nil;
    }
    if (_locService)
    {
        _locService=nil;
    }
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
    //    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    isFirstLocation=NO;
    self.currentLocationBtn.selected=YES;
    [self.mapView updateLocationData:userLocation];
    self.currentCoordinate=userLocation.location.coordinate;
    
    if (self.currentCoordinate.latitude!=0)
    {
        [self.locService stopUserLocationService];
    }
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
    NSLog(@"%zd",mapView.annotations.count);
    if (!isFirstLocation)
    {
        CLLocationCoordinate2D tt =[self.mapView convertPoint:self.mapView.center toCoordinateFromView:self.mapView];
        self.currentCoordinate=tt;
        
        self.currentLocationBtn.selected=NO;
    }
}
- (void)mapStatusDidChanged:(BMKMapView *)mapView {
    touchAddressCell = NO;
}

#pragma mark - BMKGeoCodeSearchDelegate

/**
 *返回地址信息搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结BMKGeoCodeSearch果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"返回地址信息搜索结果,失败-------------");
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error ==BMK_SEARCH_NO_ERROR && !touchAddressCell)
    {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:result.poiList];
        
//        if (isFirstLocation)
//        {
//            //把当前定位信息自定义组装放进数组首位
//            BMKPoiInfo *first =[[BMKPoiInfo alloc]init];
//            first.address=result.address;
//            first.name=@"[当前位置]";
//            first.pt=result.location;
//            first.city=result.addressDetail.city;
//            [self.dataSource insertObject:first atIndex:0];
//        }
        
        
        if (self.dataSource && self.dataSource.count) {
            //TODO 显示发送按钮
            rightBtn.hidden = NO;
            
            self.currentSelectLocationIndex = 0;
            [self.tableView reloadData];
            
        } else {
            rightBtn.hidden = YES;
        }
    }
}

#pragma mark - TableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MALocationCell*cell =[tableView dequeueReusableCellWithIdentifier:@"MALocationCell" ];
    
    BMKPoiInfo *model=[self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text=model.name;
    cell.detailTextLabel.text=model.address;
    cell.detailTextLabel.textColor=[UIColor grayColor];
    
    if (self.currentSelectLocationIndex==indexPath.row)
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType=UITableViewCellAccessoryNone;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    touchAddressCell = YES;
    BMKPoiInfo *model=[self.dataSource objectAtIndex:indexPath.row];
    BMKMapStatus *mapStatus =[self.mapView getMapStatus];
    mapStatus.targetGeoPt=model.pt;
    [self.mapView setMapStatus:mapStatus withAnimation:YES];
    self.currentSelectLocationIndex=indexPath.row;
    [self.tableView reloadData];
}
#pragma mark - InitMethod

-(BMKMapView*)mapView
{
    if (_mapView==nil)
    {
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navBar.frame), CGRectGetWidth(self.view.frame), kBaiduMapMaxHeight)];
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
-(BMKGeoCodeSearch*)geocodesearch
{
    if (_geocodesearch==nil)
    {
        _geocodesearch=[[BMKGeoCodeSearch alloc]init];
    }
    return _geocodesearch;
}

-(UITableView*)tableView
{
    if (_tableView==nil)
    {
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.mapView.frame)) style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        
    }
    return _tableView;
}

-(UIImageView*)centerCallOutImageView
{
    if (_centerCallOutImageView==nil)
    {
        _centerCallOutImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_centerCallOutImageView setImage:[UIImage imageNamed:MAChatMsgBundleName(@"pin_red_point")]];
    }
    return _centerCallOutImageView;
}

-(NSMutableArray*)dataSource
{
    if (_dataSource==nil) {
        _dataSource=[[NSMutableArray alloc]init];
    }
    
    return _dataSource;
}
@end
