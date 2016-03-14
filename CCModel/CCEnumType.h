//
//  CCEnumType.h
//  CCModel <https://github.com/crash-wu/CCModel-Master>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCModelHead.h"


#define force_inline __inline__ __attribute__((always_inline))



typedef struct {
    void *modelMeta;  ///< _CCModelMeta
    void *model;      ///< id (self)
    void *dictionary; ///< NSDictionary (json)
} ModelSetContext;



typedef struct {
    
    BOOL(*CCEncodingTypeIsCNumber_exten)(CCEncodingType type);
    
    /// Parse a number value from 'id'.
    NSNumber* (*CCNSNumberCreateFromID_exten)(__unsafe_unretained id value);
    
    
    void(*ModelSetWithDictionaryFunction_exten)(const void *_key, const void *_value, void *_context);
    
   // Get number from property,Caller should hold strong reference to the parameters before this function returns
    NSNumber *(*ModelCreateNumberFromProperty_exten)(__unsafe_unretained id model,
                                                    __unsafe_unretained _CCModelPropertyMeta *meta);

    // Set value to model with a property meta
    void(*ModelSetValueForProperty_exten)(__unsafe_unretained id model,
                                          __unsafe_unretained id value,
                                          __unsafe_unretained _CCModelPropertyMeta *meta);
    
    // Apply function for model property meta, to set dictionary to model.
    void(*ModelSetWithPropertyMetaArrayFunction_exten)(const void *_propertyMeta, void *_context);
    
    // Returns a valid JSON object (NSArray/NSDictionary/NSString/NSNumber/NSNull),    or nil if an error occurs
    id (*ModelToJSONObjectRecursive_exten)(NSObject *model);
    

    //将string转化成NSDate类型
    NSDate  *(*CCNSDateFromString_exten)(__unsafe_unretained NSString *string);
    
    /// Get the 'NSBlock' class.
    Class (*CCNSBlockClass_exten)(void*);
    
    
    
    /**
     Get the ISO date formatter.
     
     ISO8601 format example:
     2010-07-09T16:13:30+12:00
     2011-01-11T11:11:11+0000
     2011-01-26T19:06:43Z
     
     length: 20/24/25
     */
    NSDateFormatter *(*CCISODateFormatter_exten)(void*);
    
    /// Get the value with key paths from dictionary
    /// The dic should be NSDictionary, and the keyPath should not be nil.
    id (*CCValueForKeyPath_exten)(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *keyPaths);
    
    
    
    /**
     Set number to property.
     @discussion Caller should hold strong reference to the parameters before this function returns.
     @param model Should not be nil.
     @param num   Can be nil.
     @param meta  Should not be nil, meta.isCNumber should be YES, meta.setter should not be nil.
     */
    void(*ModelSetNumberToProperty_exten)(__unsafe_unretained id model,
                                          __unsafe_unretained NSNumber *num,
                                          __unsafe_unretained _CCModelPropertyMeta *meta);

    /// Get the value with multi key (or key path) from dictionary
    /// The dic should be NSDictionary
    id(*CCValueForMultiKeys_exten)(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *multiKeys);
    
    CCEncodingNSType (*CCClassGetNSType_exten)(Class cls);
    
    CCEncodingType (*CCEncodingGetType_exten)(const char *typeEncoding);
    
    
}EnumExtenFuntion;


@interface CCEnumType : NSObject


+ (EnumExtenFuntion *)sharedUtil;

@end
