//
//  CCClassMethodInfo.h
//  CCModel <https://github.com/crash-wu/CCModel-Master>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCModelHead.h"
/**
 *  @author crash         crash_wu@163.com   , 16-03-09 13:03:50
 *
 *  @brief  Method information
 */

@interface CCClassMethodInfo : NSObject

@property(nonatomic,assign,readonly)Method method;//
@property(nonatomic,strong,readonly)NSString *name;//method name;
@property(nonatomic,assign,readonly) SEL sel;//method's selector
@property(nonatomic,assign,readonly) IMP imp;//method's implementation
@property(nonatomic,strong,readonly) NSString *typeEndoding;//method's parameter and return types;
@property(nonatomic,strong,readonly) NSString *returnTypeEncoding;//return value's type
@property(nonatomic,strong,readonly) NSArray *argumentTypeEncoding;//array of argument type

-(instancetype)initWithMethod:(Method)method;


@end
