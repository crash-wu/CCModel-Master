//
//  CCClassInfo.m
//  CCModel <https://github.com/crash-wu/CCModel-Master>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import "CCClassInfo.h"
#import "CCClassMethodInfo.h"
#import "CCClassPropertyInfo.h"
#import "CCClassIvarInfo.h"

@implementation CCClassInfo{
    
    BOOL _needUpdate;// yes ,class is need to update ,or other is mean no
}



-(instancetype)initWithClass:(Class )cls{
    
    if(!cls) return nil;
    
    self=[super init];
    
    _cls =cls;
    
    //get the superClass
    _superCls=class_getSuperclass(cls);
    _isMeta=class_isMetaClass(cls);
    
    //if isMeta is false,so get the metaClass
    if (!_isMeta) {
        _metaCls=objc_getMetaClass(class_getName(cls));
    }
    
    //class name
    _name=NSStringFromClass(cls);
    
    //update class
    [self _update ];
    
    //get superclass information
    _superClassInfo=[self.class classInfoWithClass:_superCls];
    
    
    return self;
    
}

-(void)_update{
    
    // set var ,method and property to nil
    _ivarinfos=nil;
    _methodInfos=nil;
    _propertyInfos=nil;
    
    
    Class cls=self.cls;
    
    unsigned int methodCount=0;
    
    //get the cls methods,
    Method *methods=class_copyMethodList(cls, &methodCount);
    
    //if methods is not null
    if (methods) {
        
        NSMutableDictionary *methodInfos=[NSMutableDictionary new];
        
        //copy
        _methodInfos=methodInfos;
        
        //traverse methods
        for (unsigned int i=0; i<methodCount; i++) {
            
            CCClassMethodInfo *info=[[CCClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) {
                
                methodInfos[info.name]=info;
            }
            
        }
        //dealloc
        free(methods);
    }
    
    
    //get property
    
    unsigned int propertyCount=0;
    objc_property_t *properties=class_copyPropertyList(cls, &propertyCount);
    
    if (properties) {
        
        NSMutableDictionary *propertyInfos=[NSMutableDictionary new];
        
        _propertyInfos=propertyInfos    ;
        
        // traverse property
        for (unsigned int i=0; i<propertyCount; i++) {
            
            CCClassPropertyInfo *info=[[CCClassPropertyInfo alloc]initWithProperty:properties[i]];
            
            if (info.name) {
                
                propertyInfos[info.name]=info;
            }
        }
        
        free(properties);
    }
    
    //get variable
    unsigned int ivarCount=0;
    
    Ivar *ivars=class_copyIvarList(cls, &ivarCount);
    
    if (ivars) {
    
        NSMutableDictionary *ivarsInfos=[NSMutableDictionary new];
        
        _ivarinfos=ivarsInfos;
        
        //traverse variable
        for (unsigned int i=0; i<ivarCount; i++) {
        
            CCClassIvarInfo *info=[[CCClassIvarInfo alloc]initWithVar:ivars[i]];
            if (info.name) {
                
                ivarsInfos[info.name]=info;
            }
        }
        
        //dealloc
        free(ivars);
    }
    
    //set update flag to no
    _needUpdate=NO;
}

-(void)setNeedUpdate{
    
    _needUpdate=YES;
}
+(instancetype)classInfoWithClass:(Class)cls{
    
    if (!cls) {
        return nil  ;
    }
    
    
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static OSSpinLock lock;
    dispatch_once(&onceToken, ^{
        
        //create class cache
        classCache=CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        //create metaclass cache
        metaCache=CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks,& kCFTypeDictionaryValueCallBacks);
        
        lock=OS_SPINLOCK_INIT;
        
    });
    
    OSSpinLockLock(&lock);
    
    //get class information
    CCClassInfo *info=CFDictionaryGetValue(class_isMetaClass(cls)?metaCache:classCache, (__bridge const void *)(cls));
    
    //if the class information is no null,and need to update ,so update
    if (info&& info->_needUpdate) {
        [info _update];
    }
    
    OSSpinLockUnlock(&lock);
    
    //if the class information is nil,so init ,and set information by the metaCache or classCache.
    if (!info) {
        info=[[CCClassInfo alloc]initWithClass:cls];
        if (info) {
            OSSpinLockLock(&lock);
            CFDictionarySetValue(info.isMeta?metaCache:classCache, (__bridge const void *)(cls), (__bridge const void*)(info));
            
            OSSpinLockUnlock(&lock);
        }
    }
    
    return info;
}

+(instancetype)classInfoWithClassName:(NSString *)className{
    
    Class cls=NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end
