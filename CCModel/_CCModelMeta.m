//
//  _CCModelMeta.m
//  CCModel <https://github.com/crash-wu/CCModel>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import "_CCModelMeta.h"
#import "CCClassInfo.h"
#import "CCModelProtocol.h"
#import "CCClassPropertyInfo.h"
#import "_CCModelPropertyMeta.h"

@implementation _CCModelMeta

-(instancetype) initWithClass:(Class )cls{
    
    CCClassInfo *classInfo=[CCClassInfo classInfoWithClass:cls];
    if (!classInfo) {
        return nil;
    }
    
    self=[super init];
    
    //Get black list
    NSSet *blacklist=nil;
    if ([cls respondsToSelector:@selector(modelPropertyBlacklist)]) {
        
        NSArray *properties=[(id<CCModel>) cls modelPropertyBlacklist];
        
        if (properties) {
            blacklist=[NSSet setWithArray:properties];
        }
    }

    //Get white list
    
    NSSet *whitelist=nil;
    
    if ([cls respondsToSelector:@selector(modelpropertyWhitelist)]) {
        
        NSArray *properties=[(id<CCModel>)cls modelpropertyWhitelist];
        
        if (properties) {
            whitelist=[NSSet setWithArray:properties];
        }
    }
    
    //Get container property's generic class
    
    NSDictionary *genericMapper=nil;
    if ([cls respondsToSelector:@selector(modelContainerPropertyGenericClass)]) {
        
        genericMapper=[(id<CCModel>)cls modelContainerPropertyGenericClass];
        
        if (genericMapper) {
        
            NSMutableDictionary *tmp=[NSMutableDictionary new];
            [genericMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
               
                if (![key isKindOfClass:[NSString class]]) {
                    return ;
                }
                
                Class meta=object_getClass(obj);
                
                if (!meta) {
                    return;
                }
                
                if (class_isMetaClass(meta)) {
                    
                    tmp[key]=obj;
                }
                else if ([obj isKindOfClass:[NSString class]]){
                    
                    Class clss=NSClassFromString(obj);
                    if (clss) {
                        tmp[key]=clss;
                    }
                }
            }];
            genericMapper=tmp;
            
        }
    }
    
    
    //Create all property metas.
    NSMutableDictionary *allPropertyMetas=[NSMutableDictionary new];
    CCClassInfo *curClassInfo=classInfo;
    
    while (curClassInfo && curClassInfo.superCls !=nil) {
        //recursive parse super class,but ignore root class(NSObject/NSProxy)
        
        for (CCClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            
            if (!propertyInfo.name) {
                continue;
            }
            
            if (blacklist && [blacklist  containsObject:propertyInfo.name]) {
                continue;
            }
            
            if (whitelist&& [whitelist containsObject: propertyInfo.name]) {
                continue;
            }
            
            _CCModelPropertyMeta *meta=[_CCModelPropertyMeta metaWithClassInfo:classInfo propertyInfo:propertyInfo generice:genericMapper[propertyInfo.name]];
            
            if (!meta || !meta ->_name) {
                continue    ;
            }
            
            if (!meta->_getter && !meta->_setter) {
                continue;
            }
            
            if (allPropertyMetas[meta->_name]) {
                continue;
            }
            
            allPropertyMetas[meta->_name]=meta;
        }
        curClassInfo=curClassInfo.superClassInfo;
    }
    
    if (allPropertyMetas.count) {
        _allPropertyMetas=allPropertyMetas.allValues.copy;
    }
    
    // Create mapper
    NSMutableDictionary *mapper=[NSMutableDictionary new];
    NSMutableArray *keyPathPropertyMetas=[NSMutableArray new];
    NSMutableArray *multiKeysPropertyMetas=[NSMutableArray new];
    
    if ([cls respondsToSelector:@selector(modelCustomPropertyMapper)]) {
        
        NSDictionary *customMapper =[(id <CCModel>)cls modelCustomPropertyMapper];
        [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString * propertyName, NSString * mappedToKey, BOOL * _Nonnull stop) {
            
            _CCModelPropertyMeta *propertyMeta=allPropertyMetas[propertyName];
            
            if (!propertyMeta) {
                return ;
            }
            
            [allPropertyMetas removeObjectForKey:propertyName];
            
            if ([mappedToKey isKindOfClass:[NSString class]]) {
                
                if (mappedToKey.length==0) {
                    return;
                }
                
                propertyMeta->_mappedToKey=mappedToKey;
                
                NSArray *keyPath=[mappedToKey componentsSeparatedByString:@"."];
                
                if (keyPath.count>1) {
                    propertyMeta->_mappedToKeyPath=keyPath;
                    [keyPathPropertyMetas addObject:propertyMeta];
                }
                
                propertyMeta->_next=mapper[mappedToKey]?:nil;
                mapper[mappedToKey]=propertyMeta;
            }else if ([mappedToKey isKindOfClass:[NSArray class]]){
                
                
                NSMutableArray *mappedToKeyArray=[NSMutableArray new];
                
                for (NSString *onekey in ((NSArray *) mappedToKey)) {
                    
                    if (onekey.length==0) {
                        continue    ;
                    }
                    
                    NSArray *keyPath=[onekey componentsSeparatedByString:@"."];
                    
                    if (keyPath.count>1) {
                        [mappedToKeyArray addObject:keyPath];
                    }
                    else{
                        
                        [mappedToKeyArray addObject:onekey];
                    }
                    
                    if (!propertyMeta->_mappedToKey) {
                        
                        propertyMeta->_mappedToKey=onekey;
                        propertyMeta->_mappedToKeyPath=keyPath.count>1?keyPath:nil;
                    }
                }
                
                if (!propertyMeta->_mappedToKey) {
                    return  ;
                }
                
                propertyMeta->_mappedToKeyArray=mappedToKeyArray;
                [multiKeysPropertyMetas addObject:propertyMeta];
                propertyMeta->_next=mapper[mappedToKey]?:nil;
                mapper[mappedToKey]=propertyMeta;
            }
        }];
    }
    
    [allPropertyMetas enumerateKeysAndObjectsUsingBlock:^(NSString *name , _CCModelPropertyMeta *propertyMeta   , BOOL * _Nonnull stop) {
        
        propertyMeta->_mappedToKey =name;
        propertyMeta->_next=mapper[name]? :nil;
        mapper[name]=propertyMeta;
        
        
    }];
    
    if (mapper.count) {
        _mapper=mapper;
    }
    
    if (keyPathPropertyMetas) {
        _keyPathPropertyMetas=keyPathPropertyMetas;
    }
    
    if (multiKeysPropertyMetas) {
        _multiKeysPropertyMetas=multiKeysPropertyMetas;
    }
    
    
    EnumExtenFuntion *enumFuntion=[CCEnumType sharedUtil];
    
    _keyMappedCount=_allPropertyMetas.count;
  //  _nsType=CCClassGetNSType(cls);
    
    _nsType=enumFuntion->CCClassGetNSType_exten(cls);
    _hasCustomTransformFromDictionary=([cls instancesRespondToSelector:@selector(modelCustomTransformFromDictionary:)]);
    
    _hasCustomTransformToDictionary=([cls instancesRespondToSelector:@selector(modelCustomTransformToDictionary:)]);
    
    _hasCustomClassFromDictionary=([cls instancesRespondToSelector:@selector(modelCustomClassForDictionary:)]);
    
    return self;
}



//Returns the cached model class meta
+(instancetype)metaWithClass:(Class)cls{
    
    if (!cls) {
        return nil;
    }
    
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    
    static OSSpinLock lock;
    
    dispatch_once(&onceToken, ^{
       
        cache=CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock=OS_SPINLOCK_INIT;
    });
    
    
    OSSpinLockLock(&lock);
    _CCModelMeta *meta=CFDictionaryGetValue(cache, (__bridge const void*)(cls));
    OSSpinLockUnlock(&lock);
    
    
    if (!meta) {
        meta=[[_CCModelMeta alloc]initWithClass:cls];
        if (meta) {
            OSSpinLockLock(&lock);
            CFDictionarySetValue(cache, (__bridge const void*)(cls), (__bridge const void *)(meta));
            OSSpinLockUnlock(&lock);
        }
    }
    return meta;
}

@end
