//
//  CCClassIvarInfo.h
//  CCModel <https://github.com/crash-wu/CCModel>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CCModelHead.h"
#import "CCEnumType.h"

/**
 *  @author crash, 16-03-09 11:03:28
 *
 *  @brief  Instance varible information.
 */
@interface CCClassIvarInfo : NSObject

@property(nonatomic,assign,readonly) Ivar ivar;
@property(nonatomic,strong,readonly) NSString *name;//Ivar's name
@property(nonatomic,assign,readonly) ptrdiff_t offset;//Ivar's offset
@property(nonatomic,strong,readonly) NSString *typeEncoding;//Ivar's type encoding;
@property(nonatomic,assign,readonly) CCEncodingType type;//Ivar's type


-(instancetype)initWithVar:(Ivar)var;

@end
