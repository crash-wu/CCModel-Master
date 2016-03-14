//
//  _CCModelPropertyMeta.h
//  CCModel
//
//  Created by 吴小星 on 16/3/10.
//  Copyright © 2016年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCModelHead.h"


/**
 *  @author crash         crash_wu@163.com   , 16-03-10 14:03:52
 *
 *  @brief  A property info in objcet model.
 */
@interface _CCModelPropertyMeta : NSObject{
    
    @package
    NSString *_name ;       //property 's name
    CCEncodingType _type;   //property's type
    CCEncodingNSType _nsType; // propety's Foundation type
    BOOL _isCNnumber;         // is c number type
    Class _cls;             //property's class,or nil
    Class _genericCls;      //container's generic class ,or nil if there are no generic class
    SEL _setter;            //setter,or nil if the instance can's respond
    SEL _getter;            //getter,or nil if the instance can's respond
    BOOL _isKVCCompatible;  //yes if it can access with key-value coding
    BOOL _isStructAvailableForKeyedArchiver;// yes if the struct can encoded with keyed archiver/unarchiver
    BOOL _hasCustomClassFromDictionary;// class /generic class implements +modelCustomClassForDictionary:
    
    /*
     property->key:       _mappedToKey:key     _mappedToKeyPath:nil            _mappedToKeyArray:nil
     property->keyPath:   _mappedToKey:keyPath _mappedToKeyPath:keyPath(array) _mappedToKeyArray:nil
     property->keys:      _mappedToKey:keys[0] _mappedToKeyPath:nil/keyPath    _mappedToKeyArray:keys(array)
     */
    
    NSString *_mappedToKey;//the key mapped to
    NSArray *_mappedToKeyPath;// the key path mapped to(nil if the name is not key path)
    NSArray *_mappedToKeyArray;// the key(NSString) or keyPath(NSArray) array (nil if not mapped to multiple keys)
    CCClassPropertyInfo *_info;// property's info
    _CCModelPropertyMeta *_next;//next meta if there are multiple properties mapped to the same key.
}

+(instancetype)metaWithClassInfo:(CCClassInfo *)classInfo propertyInfo:(CCClassPropertyInfo *)propertyInfo generice :(Class) generic;

@end
