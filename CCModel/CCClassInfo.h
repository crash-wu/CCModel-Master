//
//  CCClassInfo.h
//  CCModel <https://github.com/crash-wu/CCModel>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCModelHead.h"

/**
 *  @author crash         crash_wu@163.com   , 16-03-11 11:03:10
 *
 *  @brief  A class Information.
 */
@interface CCClassInfo : NSObject


@property(nonatomic,assign,readonly) Class cls;
@property(nonatomic,assign,readonly) Class superCls;
@property(nonatomic,assign,readonly) Class metaCls;
@property(nonatomic,assign,readonly) BOOL isMeta;
@property(nonatomic,strong,readonly) NSString *name;
@property(nonatomic,strong,readonly) CCClassInfo *superClassInfo;

@property(nonatomic,strong,readonly) NSDictionary *ivarinfos;//key:NSString(ivar),value:CCClassIvarInfo
@property(nonatomic,strong,readonly) NSDictionary *methodInfos;//key:NSString(selector),value:CCClassMethodInfo

@property(nonatomic,strong,readonly) NSDictionary *propertyInfos;//key:NSString(property),value:CCClassPropertyInfo

/**
 *  @author crash         crash_wu@163.com   , 16-03-09 14:03:15
 *
 *  @brief  if the class is changed (for example:you add a method to this class with 'class_addMethod()',
    you should call this method to refresh the class info.
    
    After called this method,you may call 'classInfoWithClass' or 'classInfoWithClassName' to get the updated class info.
 */
-(void)setNeedUpdate;

/**
 *  @author crash         crash_wu@163.com   , 16-03-09 15:03:20
 *
 *  @brief  Get the class info of a specified class.
 *  @discussion This method will cache the class info and super-class info at the first access to the class.This method is thread-safe;
 *
 *  @param cls A class
 *
 *  @return A class info ,or nil if an error occurs.
 */
+(instancetype) classInfoWithClass:(Class) cls;

/**
 *  @author crash         crash_wu@163.com   , 16-03-09 15:03:28
 *
 *  @brief  Get the class info of a specified Class.
 
    @disccussion This method will cache the class info and super-class info at the first access to the class.This Method is thread-safe.
 *
 *  @param className A class Name
 *
 *  @return A class info,or nil if an error occurs.
 */
+(instancetype) classInfoWithClassName:(NSString *)className;

@end
