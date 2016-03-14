//
//  _CCModelMeta.h
//  CCModel <https://github.com/crash-wu/CCModel>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCModelHead.h"


/**
 *  @author crash, 16-03-09 11:03:48
 *
 *  @brief   A class information in object model
 */
@interface _CCModelMeta : NSObject{
    
    @package
    
    //key :mapped and key path ,Value:_CCModelPropertyInfo
    NSDictionary *_mapper;
    
    
    //Array<_CCModelPropertyMeta>,all property meta of this model
    NSArray<_CCModelPropertyMeta*>  *_allPropertyMetas;
    
    //Array<_CCModelPropertyMeta>,property meta which is mapped to a key path
    NSArray *_keyPathPropertyMetas;
    
    //Array<_CCModlePropertyMeta>,property meta which is mapped to multi keys
    NSArray *_multiKeysPropertyMetas;
    
    //The number of mapped key (and key path),same to _mapper.count
    NSUInteger _keyMappedCount;
    
    //Model class type
    CCEncodingNSType _nsType;
    
    BOOL _hasCustomTransformFromDictionary;
    BOOL _hasCustomTransformToDictionary;
    BOOL _hasCustomClassFromDictionary;
    
}



//Returns the cached model class meta


/**
 *  @author crash         crash_wu@163.com   , 16-03-11 09:03:30
 *
 *  @brief  Returns the cached model class meta
 *
 *  @param cls A class
 *
 *  @return The cached model
 */
+(instancetype)metaWithClass:(Class)cls;

@end
