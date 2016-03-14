//
//  CCClassMethodInfo.m
//  CCModel <https://github.com/crash-wu/CCModel-Master>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import "CCClassMethodInfo.h"

@implementation CCClassMethodInfo


-(instancetype) initWithMethod:(Method)method{
    
    if (!method) {
        return nil  ;
    }
    
    
    self=[super init];
    
    _method=method;
    
    //get the selector
    _sel=method_getName(method);
    
    // get the implementation
    _imp=method_getImplementation(method );
    
    //selector name
    const char *name=sel_getName(_sel);
    
    //format
    if (name) {
        _name=[NSString stringWithUTF8String:name];
    }
    
    const char * typeEncoding=method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEndoding=[NSString stringWithUTF8String:typeEncoding];
    }
    
    char *returnType=method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding=[NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    
    //get the class argument numbers;
    unsigned int argumentCount=method_getNumberOfArguments(method);
    
    if (argumentCount>0) {
        NSMutableArray *argumentTypes=[NSMutableArray new];
        for (unsigned int i=0; i<argumentCount; i++) {
            //get  argument type
            char *argumentType=method_copyArgumentType(method , i);
            
            NSString *type=argumentType ?[NSString stringWithUTF8String:argumentType]:nil;
            
            [argumentTypes addObject:type?type :@""];
            if (argumentType ) {
                free(argumentType);
            }
        }
        
        _argumentTypeEncoding=argumentTypes;
    }
    
    return  self;
}

@end
