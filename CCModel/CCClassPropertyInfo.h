//
//  CCClassPropertyInfo.h
//  CCModel <https://github.com/crash-wu/CCModel-Master>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCModelHead.h"
#import "CCEnumType.h"
/**
 *  @author crash         crash_wu@163.com   , 16-03-09 13:03:31
 *
 *  @brief  Property information
 */
@interface CCClassPropertyInfo : NSObject{
    
    EnumExtenFuntion *enumFuntion;
}

@property(nonatomic,assign,readonly)objc_property_t property;
@property(nonatomic,strong,readonly)NSString *name;//property's name;
@property(nonatomic,assign,readonly) CCEncodingType type;//property's type
@property(nonatomic,strong,readonly) NSString *typeEncoding;//property encoding value
@property(nonatomic,strong,readonly) NSString *ivarName;//property 's ivar name
@property(nonatomic,assign,readonly) Class cls;//may be nil
@property(nonatomic,strong,readonly) NSString *getter;//getter (nonnull)
@property(nonatomic,strong,readonly) NSString *setter;//setter(nonnull)
-(instancetype)initWithProperty:(objc_property_t) property;


@end
