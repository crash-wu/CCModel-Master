//
//  CCClassIvarInfo.m
//  CCModel <https://github.com/crash-wu/CCModel>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import "CCClassIvarInfo.h"


@implementation CCClassIvarInfo

-(instancetype)initWithVar:(Ivar)var{
    
    if (!var) {
        return nil  ;
    }
    
    self=[super self];
    
    EnumExtenFuntion *enumFuntion=[CCEnumType sharedUtil];
    
    _ivar=var;
    const char *name=ivar_getName(var);
    
    if (name) {
        _name=[NSString stringWithUTF8String:name];
    }
    
    _offset=ivar_getOffset(var);
    
    const char *typeEncoding=ivar_getTypeEncoding(var);
    
    if (typeEncoding) {
        _typeEncoding=[NSString stringWithUTF8String:typeEncoding];
        //_type=CCEncodingGetType(typeEncoding);
        _type=enumFuntion->CCEncodingGetType_exten(typeEncoding);
    }
    
    return self;
}

@end
