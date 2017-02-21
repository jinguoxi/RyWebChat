//
//  MALocationDetailController.h
//  MAWebChat
//
//  Created by nwk on 2017/1/16.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MALocationDetailController : UIViewController

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;

@end
