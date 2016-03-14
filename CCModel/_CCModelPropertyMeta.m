//
//  _CCModelPropertyMeta.m
//  CCModel
//
//  Created by 吴小星 on 16/3/10.
//  Copyright © 2016年 crash. All rights reserved.
//

#import "_CCModelPropertyMeta.h"
#import "CCClassInfo.h"
#import "CCClassPropertyInfo.h"
#import "CCEnumType.h"

@implementation _CCModelPropertyMeta


+(instancetype)metaWithClassInfo:(CCClassInfo *)classInfo propertyInfo:(CCClassPropertyInfo *)propertyInfo generice :(Class) generic{
    
    _CCModelPropertyMeta *meta=[self new];
    meta->_name=propertyInfo.name;
    meta->_type=propertyInfo.type;
    meta->_info=propertyInfo;
    meta->_genericCls=generic;
    
    EnumExtenFuntion *enumType=[CCEnumType sharedUtil];
    
    if ((meta->_type & YYEncodingTypeMask)== YYEncodingTypeObject) {
        
       // meta->_nsType=CCClassGetNSType(propertyInfo.cls);
        meta->_nsType=enumType->CCClassGetNSType_exten(propertyInfo.cls);
    }
    else{
        
        //meta->_isCNnumber=CCEncodingTypeIsCNumber(meta->_type);
        meta->_isCNnumber=enumType->CCEncodingTypeIsCNumber_exten(meta->_type);
    }
    
    if ((meta->_type & YYEncodingTypePropertyMask)==YYEncodingTypeStruct) {
        
        /*
          It seems that NSKeyedUnarchiver cannot decode NSValue except these structs.
         */
        static NSSet *types = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *set = [NSMutableSet new];
            // 32 bit
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];
            // 64 bit
            [set addObject:@"{CGSize=dd}"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGPoint=dd}{CGSize=dd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];
            types = set;
        });
        
        if ([types containsObject:propertyInfo.typeEncoding]) {
            meta->_isStructAvailableForKeyedArchiver=YES;
        }
    }
    
    meta->_cls=propertyInfo.cls;
    
    if (generic) {
        
        meta->_hasCustomClassFromDictionary=[generic respondsToSelector:@selector(modelCustomClassForDictionary:)];
    }
    else if (meta->_cls && meta->_nsType== YYEncodingTypeUnknown){
        
        meta->_hasCustomClassFromDictionary=[meta->_cls respondsToSelector:@selector(modelCustomClassForDictionary:)];
    }
    
    
    if (propertyInfo.getter) {
        
        SEL sel=NSSelectorFromString(propertyInfo.getter);
        
        if ([classInfo.cls instancesRespondToSelector:sel]) {
            meta->_getter=sel;
        }
    }
    
    if (propertyInfo.setter) {
        
        SEL sel=NSSelectorFromString(propertyInfo.setter);
        
        if ([classInfo.cls instancesRespondToSelector:sel]) {
            
            meta->_setter=sel;
        }
    }
    
    if (meta->_getter && meta->_setter) {
        /*
         KVC invalid type:
         long double
         pointer (such as SEL/CoreFoundation object)
         */
        switch (meta->_type & YYEncodingTypeMask) {
            case YYEncodingTypeBool:
            case YYEncodingTypeInt8:
            case YYEncodingTypeUInt8:
            case YYEncodingTypeInt16:
            case YYEncodingTypeUInt16:
            case YYEncodingTypeInt32:
            case YYEncodingTypeUInt32:
            case YYEncodingTypeInt64:
            case YYEncodingTypeUInt64:
            case YYEncodingTypeFloat:
            case YYEncodingTypeDouble:
            case YYEncodingTypeObject:
            case YYEncodingTypeClass:
            case YYEncodingTypeBlock:
            case YYEncodingTypeStruct:
            case YYEncodingTypeUnion: {
                meta->_isKVCCompatible = YES;
            } break;
            default: break;
        }
    }
    
    return meta;

}

@end
