//
//  MALocationViewController.h
//  SocketDemo
//
//  Created by nwk on 2017/1/10.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol MALocationDelegate <NSObject>

- (void)sendlocation:(CLLocationCoordinate2D)coordinate title:(NSString *)title detail:(NSString *)detail image:(UIImage *)image;

@end

@interface MALocationViewController : UIViewController

@property (assign, nonatomic) id<MALocationDelegate> delegate;

@end
