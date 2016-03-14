//
//  NSObject+CCModel.m
//  CCModel <https://github.com/crash-wu/CCModel-Master>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import "NSObject+CCModel.h"
#import "_CCModelMeta.h"
#import "_CCModelPropertyMeta.h"
#import "CCEnumType.h"

@implementation NSObject (CCModel)

/**
 *  @author crash, 16-03-09 11:03:29
 *
 *  @brief JSON transform NSDictionary
 *
 *  @param json
 *
 *  @return NSDictionary
 */

+(NSDictionary *)_cc_dictionaryWithJSON:(id)json{
    
    if (!json||json==(id)kCFNull) return nil;
    
    NSDictionary *dic=nil;
    NSData *jsonData=nil;
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic=json;
    }
    else if ([json isKindOfClass:[NSString class] ]){
        
        jsonData=[(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([json isKindOfClass:[NSData class]]){
        
        jsonData=json;
    }
    
    
    if (jsonData) {
        dic=[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        
        if (![dic isKindOfClass:[NSDictionary class]])   return nil;
    }
    
    return dic;
}



/**
 *  @author crash         crash_wu@163.com   , 16-03-11 16:03:04
 *
 *  @brief  Creates and returns a new instance of the receiver from a json.This method is thread-safe.
 *
 *  @param json A json object in 'NSDictionary','NSString' or 'NSData'.
 *
 *  @return A new instance created from the json ,or nil if an error occurs.
 */
+(instancetype)cc_modelWithJSON:(id)json{
    
    NSDictionary *dic=[self _cc_dictionaryWithJSON:json];
    
    return [self cc_modelWithDictionary:dic];
}


+(instancetype)cc_modelWithDictionary:(NSDictionary *)dictionary{
    if (!dictionary || dictionary==(id)kCFNull) {
        return nil;
    }
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        
        return nil;
    }
    
    Class cls=[self class];
    
    _CCModelMeta *modelMeta=[_CCModelMeta metaWithClass:cls];
    
    if (modelMeta->_hasCustomClassFromDictionary) {
        cls=[cls modelCustomClassForDictionary:dictionary]?:cls;
    }
    
    NSObject *one=[cls new];
    if ([one cc_modelSetWithDictionary:dictionary]) {
        return one  ;
    }
    return nil;

}

/**
 *  @author crash         crash_wu@163.com   , 16-03-11 16:03:30
 *
 *  @brief  Set the receiver's properties with a json object.Any invalid data in json will be ignored.
 *
 *  @param json A json object of 'NSDicitonary','NSString' or 'NSData' ,mapped to the receiver's properties.
 *
 *  @return Whether succeed.
 */
-(BOOL)cc_modelSetWithJSON:(id)json{
    
    NSDictionary *dic=[NSObject _cc_dictionaryWithJSON:json];
    
    return [self cc_modelSetWithDictionary:dic];
}

-(BOOL)cc_modelSetWithDictionary:(NSDictionary *)dic{
    
    
    if (!dic || dic==(id) kCFNull) {
        return NO;
    }
    
    
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    
    _CCModelMeta *modelMeta=[_CCModelMeta metaWithClass: object_getClass(self)];
    
    if (modelMeta->_keyMappedCount==0) {
        return NO;
        
    }
    
    ModelSetContext context={0};
    context.modelMeta=(__bridge void *)(modelMeta);
    context.dictionary=(__bridge void *)(dic );
    context.model=(__bridge void *)(self);
    
    
    EnumExtenFuntion *enumFuntion=[CCEnumType sharedUtil];
    if (modelMeta->_keyMappedCount >= CFDictionaryGetCount((CFDictionaryRef) dic )) {

      //  CFDictionaryApplyFunction((CFDictionaryRef)dic, ModelSetWithDictionaryFunction, &context);
        
        CFDictionaryApplyFunction((CFDictionaryRef)dic, enumFuntion->ModelSetWithDictionaryFunction_exten, &context);
        
        if (modelMeta->_keyPathPropertyMetas) {
/*            CFArrayApplyFunction((CFArrayRef)modelMeta->_keyPathPropertyMetas,
                                 CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_keyPathPropertyMetas)),
                                 ModelSetWithPropertyMetaArrayFunction,
                                 &context);*/
            
            CFArrayApplyFunction((CFArrayRef)modelMeta->_keyPathPropertyMetas,
                                 CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_keyPathPropertyMetas)),
                                 enumFuntion->ModelSetWithPropertyMetaArrayFunction_exten,
                                 &context);
            
        }
        
        if (modelMeta->_multiKeysPropertyMetas) {
            
           /*
            CFArrayApplyFunction((CFArrayRef)modelMeta->_multiKeysPropertyMetas, CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_multiKeysPropertyMetas)), ModelSetWithPropertyMetaArrayFunction, &context);*/
            
            CFArrayApplyFunction((CFArrayRef)modelMeta->_multiKeysPropertyMetas, CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_multiKeysPropertyMetas)), enumFuntion->ModelSetWithPropertyMetaArrayFunction_exten, &context);
            
        }
        
    }else {
        
        
        //CFArrayApplyFunction((CFArrayRef)modelMeta->_allPropertyMetas, CFRangeMake(0, modelMeta->_keyMappedCount), ModelSetWithPropertyMetaArrayFunction, &context);
        
        CFArrayApplyFunction((CFArrayRef)modelMeta->_allPropertyMetas, CFRangeMake(0, modelMeta->_keyMappedCount), enumFuntion->ModelSetWithPropertyMetaArrayFunction_exten, &context);
    }
    
    
    if (modelMeta->_hasCustomTransformFromDictionary) {
        return [((id<CCModel>)self) modelCustomTransformFromDictionary:dic];
    }
    
    return YES;
}


/**
 *  @author crash         crash_wu@163.com   , 16-03-11 16:03:14
 *
 *  @brief  Generate a json object from the receiver's properties.Any of the invalid property is ignored.If the reciver's is 'NSArray','NSDictionary'or 'NSSet',it just convert the inner object to json object.
 *
 *  @return A json object in 'NSDictionary' or 'NSArray' or nil if an error occurs.
 */
-(id)cc_modelToJSONObject{
    /**
        The top level object is an NSArray or NSDictionary.
        All objects are instances of NSString,NSNumber,NSArray,NSDictionray, or NSNull.
        All dictionary key are instances of NSString.
        Numbers are not NaN or infinity.
     */
    
    EnumExtenFuntion *enumFuntion=[CCEnumType sharedUtil];
    
  //  id jsonObject=ModelToJSONObjectRecursive(self);
    
    
    
     id jsonObject=enumFuntion->ModelToJSONObjectRecursive_exten(self);
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        return jsonObject;
    }
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        return jsonObject;
    }
    
    return nil;
}

/**
 *  @author crash         crash_wu@163.com   , 16-03-11 11:03:47
 *
 *  @brief  Transform Object to NSData
 *
 *  @return NSData
 */

-(NSData *)cc_modelToJSONData{
    
    id jsonObject=[self cc_modelToJSONObject];
    if (!jsonObject) {
        return nil;
    }
    
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
    
}

/**
 *  @author crash         crash_wu@163.com   , 16-03-11 11:03:13
 *
 *  @brief  Transform NSData to NSString
 *
 *  @return NSString
 */
-(NSString *)cc_modelToJSONString{
    NSData *jsonData=[self cc_modelToJSONData];
    
    if (jsonData.length==0) {
        return nil;
    }
    
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}



/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:02
 *
 *  @brief  copy a instance with the receiver's properties.
 *
 *  @return A copied instance ,or nil if an error occurs.
 */
-(id)cc_modelCopy{
    
    
    if (self==(id)kCFNull) {
        return self;
    }
    
    
    _CCModelMeta *modelMeta=[_CCModelMeta metaWithClass:self.class];
    
    if (modelMeta->_nsType) {
        return [self copy];
    }
    
    NSObject *one=[self.class new];
    for (_CCModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_getter || !propertyMeta->_setter) continue;
        
        if (propertyMeta->_isCNnumber) {
            switch (propertyMeta->_type & YYEncodingTypeMask) {
                case YYEncodingTypeBool: {
                    bool num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeInt8:
                case YYEncodingTypeUInt8: {
                    uint8_t num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeInt16:
                case YYEncodingTypeUInt16: {
                    uint16_t num = ((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeInt32:
                case YYEncodingTypeUInt32: {
                    uint32_t num = ((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeInt64:
                case YYEncodingTypeUInt64: {
                    uint64_t num = ((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeFloat: {
                    float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeDouble: {
                    double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeLongDouble: {
                    long double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                default: break;
            }
        } else {
            switch (propertyMeta->_type & YYEncodingTypeMask) {
                case YYEncodingTypeObject:
                case YYEncodingTypeClass:
                case YYEncodingTypeBlock: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case YYEncodingTypeSEL:
                case YYEncodingTypePointer:
                case YYEncodingTypeCString: {
                    size_t value = ((size_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, size_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case YYEncodingTypeStruct:
                case YYEncodingTypeUnion: {
                    @try {
                        NSValue *value = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                        if (value) {
                            [one setValue:value forKey:propertyMeta->_name];
                        }
                    }
                    @catch (NSException *exception) {
                        // do nothing...
                    }
                } break;
                default: break;
            }
        }
    }

    return one;
}



/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:30
 *
 *  @brief  Encode the recevier's properties to a coder.
 *
 *  @param aCoder An archiver object.
 */
-(void)cc_modelEncoderWithCoder:(NSCoder *)aCoder{
    
    EnumExtenFuntion *enmuFuntion=[CCEnumType sharedUtil];
    
    if (! aCoder) {
        return;
    }
    
    if (self==(id)kCFNull) {
        [((id<NSCoding>)self) encodeWithCoder:aCoder];
        
        return;
    }
    
    _CCModelMeta *modelMeta=[_CCModelMeta metaWithClass:self.class];
    
    if (modelMeta->_nsType) {
        [((id<NSCoding>) self) encodeWithCoder:aCoder];
        return;
    }
    
    for (_CCModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        
        if (!propertyMeta->_getter) {
            return;
        }
        
        if (propertyMeta->_isCNnumber) {
          //  NSNumber *value=ModelCreateNumberFromProperty(self, propertyMeta);
            
            NSNumber *value=enmuFuntion->ModelCreateNumberFromProperty_exten(self, propertyMeta);
            
            if (value) {
                [aCoder encodeObject:value forKey:propertyMeta->_name];
            }
        }else{
            
            switch (propertyMeta->_type &YYEncodingTypeMask) {
                case YYEncodingTypeObject:{
                    
                    id value=((id (*)(id,SEL))(void *)objc_msgSend)((id )self,propertyMeta->_getter);
                    
                    if (value &&(propertyMeta->_nsType||[value respondsToSelector:@selector(encodeWithCoder:)])) {
                        
                        if ([value isKindOfClass:[NSValue class]]) {
                            
                            if ([value isKindOfClass:[NSNumber class]]) {
                                
                                [aCoder encodeObject:value forKey:propertyMeta->_name];
                                
                            }
                        }else{
                            
                            [aCoder encodeObject:value forKey:propertyMeta->_name];
                        }
                        
                    }
                    
                }break;
                
                case YYEncodingTypeSEL:{
                    
                    SEL value=((SEL (*)(id ,SEL))(void *)objc_msgSend)((id)self,propertyMeta->_getter);
                    if (value) {
                        
                        NSString *str=NSStringFromSelector(value);
                        
                        [aCoder encodeObject:str forKey:propertyMeta->_name];
                    }
                    
                } break;
                  
                case YYEncodingTypeStruct:
                case YYEncodingTypeUnion:{
                    
                    if (propertyMeta->_isKVCCompatible &&propertyMeta->_isStructAvailableForKeyedArchiver) {
                    
                        
                        @try {
                            NSValue *value=[self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                            [aCoder encodeObject:value forKey:propertyMeta->_name];
                        }
                        @catch (NSException *exception) {
                            
                        }

                    }
                }break;
                    
                default:
                    break;
            }
        }
    }
}



/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:45
 *
 *  @brief  Decode the receiver's properties from a decoder.
 *
 *  @param aDecoder An archiver object.
 *
 *  @return self
 */
-(id)cc_modelInitWithCoder:(NSCoder *)aDecoder{
    
    if (!aDecoder) {
        return self ;
    }
    
    if (self==(id)kCFNull) {
        return self ;
    }
    
    
    EnumExtenFuntion *enumFuntion=[CCEnumType sharedUtil];
    _CCModelMeta *modelMeta=[_CCModelMeta metaWithClass:self.class];
    
    if (modelMeta->_nsType) {
        return self;
    }
    
    for (_CCModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        
        if (!propertyMeta->_setter) {
            continue    ;
        }
        
        if (propertyMeta->_isCNnumber) {
            NSNumber *value=[aDecoder decodeObjectForKey:propertyMeta->_name];
            
            if ([value isKindOfClass:[NSNumber class]]) {
                
              //  ModelSetNumberToProperty(self, value, propertyMeta);
                enumFuntion->ModelSetNumberToProperty_exten(self,value,propertyMeta);
                
                [value class];
            }
        }else{
            
            CCEncodingType type=propertyMeta->_type &YYEncodingTypeMask;
            
            switch (type) {
                case YYEncodingTypeObject:{
                    
                    id value=[aDecoder decodeObjectForKey:propertyMeta->_name];
                    ((void (*)(id,SEL ,id))(void *)objc_msgSend)((id)self ,propertyMeta->_setter,value);
                    
                }break;
                
                case YYEncodingTypeStruct:
                case YYEncodingTypeUnion:{
                    
                    if (propertyMeta->_isKVCCompatible) {
                        
                        
                        @try {
                            NSValue *value=[aDecoder decodeObjectForKey:propertyMeta->_name];
                            if (value) {
                                [self setValue:value forKey:propertyMeta->_name];
                            }
                        }
                        @catch (NSException *exception) {
                            
                        }
                        @finally {
                            
                        }
                    }
                    
                }break;
                    
                default:
                    break;
            }
        }
    }
    
    return self;
}

/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:13
 *
 *  @brief  Get a has code with the receiver's properties.
 *
 *  @return Hash code
 */
-(NSUInteger)cc_modelHash{
    
    if (self==(id)kCFNull) {
        return [self hash];
    }
    
    _CCModelMeta *modelMeta=[_CCModelMeta metaWithClass:self.class];
    
    if (modelMeta->_nsType) {
        return [self hash];
    }
    
    NSUInteger value=0;
    NSUInteger count=0;
    
    
    for (_CCModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        
        if (!propertyMeta->_isKVCCompatible) {
            continue    ;
        }
        
        value ^=[[self valueForKey:NSStringFromSelector(propertyMeta->_getter)]hash];
        count ++;
    }
    
    if (count ==0) {
        value=(long) ((__bridge void *)self);
    }
    
    return value;
}

/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:51
 *
 *  @brief  Compares the reciver with another object for equality ,based on properties.
 *
 *  @param model Another object.
 *
 *  @return 'Yes' if the reciever is equal to the objetc,otherwis 'No'.
 */
- (BOOL)cc_modelIsEqual:(id)model {
    if (self == model) return YES;
    if (![model isMemberOfClass:self.class]) return NO;
    _CCModelMeta *modelMeta = [_CCModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return [self isEqual:model];
    if ([self hash] != [model hash]) return NO;
    
    for (_CCModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_isKVCCompatible) continue;
        id this = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        id that = [model valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        if (this == that) continue;
        if (this == nil || that == nil) return NO;
        if ([this isEqual:that]) continue;
    }
    return YES;
}

@end


@implementation NSArray (CCModel)

/**
 *  @author crash         crash_wu@163.com   , 16-03-11 14:03:07
 *
 *  @brief  creates and returns an array from a json-array.
 This method is thread-safe.
 *
 *  @param cls  The instance's class in array
 *  @param json A json array of 'NSArray','NSString' or 'NSData'.
 Example:[{"name":"crash"},{"name":"teme"}];
 *
 *  @return A array,or nil if an error occurs.
 */
+(NSArray *)cc_modelArrayWithClass:(Class)cls json:(id)json{
    
    
    if (!json) {
        return nil;
    }
    
    NSArray *arr=nil;
    NSData *jsonData=nil;
    
    if ([json isKindOfClass:[NSArray class]]) {
        arr=json;
    }else if ([json isKindOfClass:[NSString class]]){
        jsonData=[(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([json isKindOfClass:[NSData class]]){
        
        jsonData=json;
    }
    
    if (jsonData) {
        arr=[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        if (![arr isKindOfClass:[NSArray class]]) {
            arr=nil;
        }
    }
    return [self cc_modelArraywithClass:cls array:arr];
}


+(NSArray *)cc_modelArraywithClass:(Class)cls array:(NSArray *)arr{
    
    if (!cls || !arr) {
        return nil  ;
    }
    
    NSMutableArray *result=[NSMutableArray new];
    for (NSDictionary *dic in arr) {
        
        if (![dic isKindOfClass: [NSDictionary class]]) {
            continue;
        }
        
        NSObject *obj=[cls cc_modelWithDictionary:dic];
        if (obj) {
            [result addObject:obj];
        }
    }
    return result;
}

@end


@implementation NSDictionary (CCModel)


/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:37
 *
 *  @brief  create and returns a dictionary from a json.
 This method is thread-safe.
 *
 *  @param cls  The value instance's class in dictionary.
 *  @param json A json dictionary of 'NSDicitonary','NSString' or 'NSData'.
 
 Example:
 {"user1":{"naem":"crash"},"user2":{"name":"teme"}};
 *
 *  @return A array,or  nil if an error occurs.
 */

+(NSDictionary *)cc_modelDictionaryWithClass:(Class)cls json:(id)json{
    
    if (!json) {
        return nil  ;
    }
    
    NSDictionary *dic=nil;
    NSData *jsonData=nil;
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic=json;
    }else if ([json isKindOfClass:[NSString class]]){
        jsonData=[(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
        
    }else if ([json isKindOfClass:[NSData class]]){
        jsonData=json;
    }
    
    if (jsonData) {
        
        dic=[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        
        if (![dic isKindOfClass:[NSDictionary class]]) {
            dic=nil;
        }
    }
    
    return [self cc_modelDictionaryWithClass:cls dictionary:dic];
}


+(NSDictionary *)cc_modelDictionaryWithClass:(Class)cls dictionary:(NSDictionary *)dic{
    
    
    if (!cls||!dic) {
        return nil;
    }
    
    NSMutableDictionary *result=[NSMutableDictionary new];
    
    for (NSString *key in dic.allKeys) {
        
        if (![key isKindOfClass:[NSString class]]) {
            continue;
        }
        
        NSObject *objcet=[cls cc_modelWithDictionary:dic[key]];
        
        if (objcet) {
            result[key]=objcet;
        }
    }
    return  result;
}

@end
