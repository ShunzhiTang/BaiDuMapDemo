//
//  ViewController.m
//  MapDemo
//
//  Created by Tsz on 15/11/6.
//  Copyright © 2015年 Tsz. All rights reserved.

#import "ViewController.h"
//#import "BMapKit.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件

#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件

#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件

#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件

#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件

#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件

#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

@interface ViewController () <BMKMapViewDelegate , BMKPoiSearchDelegate>
{
    BMKPoiSearch *_poisearch;
    BMKMapView   *_mapView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建 地图
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    
//    [_mapView setMapType:BMKMapTypeSatellite];// 卫星图
    _mapView.delegate = self;

    [self.view addSubview:_mapView];
    
    // 1、创建一个 button 上去
    
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, 80, 30)];
    [btn setTitle:@"poi检索" forState:UIControlStateNormal];
    
    btn.backgroundColor  = [UIColor purpleColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
}

// 实现点击的 方法 实现 poi 检索（POI（Point of Interest），中文可以翻译为“兴趣点”。在地理信息系统中，一个POI可以是一栋房子、一个商铺、一个邮筒、一个公交站等。）

- (void)btnClick{
    
    // 封装参数
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc] init];
    
    citySearchOption.pageIndex = 1;
    citySearchOption.pageCapacity = 10;
    
    citySearchOption.city = @"北京市";
    citySearchOption.keyword = @"酒店";
    
    _poisearch = [[BMKPoiSearch alloc] init];
    
    _poisearch.delegate = self;
    
    //开始检索
    [_poisearch poiSearchInCity:citySearchOption];
}


/*
 自2.0.0起，BMKMapView新增viewWillAppear、viewWillDisappear方法来控制BMKMapView的生命周期，并且在一个时刻只能有一个BMKMapView接受回调消息，因此在使用BMKMapView的viewController中需要在viewWillAppear、viewWillDisappear方法中调用BMKMapView的对应的方法，并处理delegate
 */

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

#pragma mark: BMKPoiSearchDelegate

/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode{
    //获取周边信息
    for (BMKPoiInfo  *info in poiResult.poiInfoList) {
        //创建大头针模型
        BMKPointAnnotation *anno = [[BMKPointAnnotation alloc]init];
        
        anno.title = info.name;
        anno.coordinate = info.pt;
        
        [_mapView addAnnotation:anno];
    }
}

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    
    // 1、生成重用标示 identifier
    NSString *annotationID = @"anno";
    
    //2、检查是否有重用的缓存
    BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationID];
    
    //3、缓存没有命中，自己创建
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationID];
        
        ((BMKPinAnnotationView *)annotationView).pinColor = BMKPinAnnotationColorPurple;
        
        //设置天下掉下的效果
        ((BMKPinAnnotationView *)annotationView).animatesDrop = YES;
    }
    
    //4、设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    
    // 单击弹出泡泡 ，弹出泡泡前提实现
    annotationView.canShowCallout = YES;
    
    annotationView.draggable = NO;
    
    return annotationView;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}

@end
