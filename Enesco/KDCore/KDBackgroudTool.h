//
//  ATMBackgroudTool.h
//  ZJSocketServer
//
//  Created by admin  on 2017/6/12.
//  Copyright © 2017年 admin . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDBackgroudTool : NSObject

@property (nonatomic, assign,readonly) BOOL opened;

+ (void)setupOpened:(BOOL)opened;

@end
