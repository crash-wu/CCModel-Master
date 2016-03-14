//
//  CCClassPropertyInfo.m
//  CCModel <https://github.com/crash-wu/CCModel-Master>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import "CCClassPropertyInfo.h"

@implementation CCClassPropertyInfo
-(instancetype) initWithProperty:(objc_property_t)property{
    
    if (!property) {
        return nil  ;
    }
    
    _property=property;
    
    const char *name=property_getName(property);
    
    if (name) {
        _name=[NSString stringWithUTF8String:name];
    }
    
    CCEncodingType type=0;
    
    enumFuntion=[CCEnumType sharedUtil];
    
    unsigned int attrCount;
    
    //get property list
    objc_property_attribute_t *attrs=property_copyAttributeList(property , &attrCount);
    for (unsigned int i=0; i<attrCount; i++) {
        
        switch (attrs[i].name[0]) {
            case 'T':{//Type encoding
                if (attrs[i].value) {
                    
                    _typeEncoding=[NSString stringWithUTF8String:attrs[i].value];
                    //type=CCEncodingGetType(attrs[i].value);
                    type=enumFuntion->CCEncodingGetType_exten(attrs[i].value);
                    if (type& YYEncodingTypeObject) {
                        
                        size_t len=strlen(attrs[i].value);
                        
                        if (len>3) {
                            
                            char name[len -2];
                            //end char
                            name[len -3]='\0';
                            
                            memcpy(name, attrs[i].value+2, len-3);
                            _cls=objc_getClass(name);
                        }
                    }
                }
            }break;
                
            case 'V':{// Instance variable
                
                if (attrs[i].value) {
                    
                    _ivarName=[NSString stringWithUTF8String:attrs[i].value];
                }
            }break;
            case 'R': {
                type |= YYEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= YYEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= YYEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= YYEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= YYEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= YYEncodingTypePropertyWeak;
            } break;
                
            case 'S':{
                
                type |=YYEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter=[NSString stringWithUTF8String:attrs[i].value];
                }
                
            }break;
            
            case 'G':{
                
                type |=YYEncodingTypePropertyCustomGetter;
                
                if (attrs[i].value) {
                    _getter=[NSString stringWithUTF8String:attrs[i].value];
                }
            }break;
                
                
                
            default:
                break;
        }
        
    }
    
    //dealloc
    if (attrs) {
        
        free(attrs);
        attrs=NULL;
    }
    
    
    _type=type;
    
    if (_name.length) {
        if (!_getter) {
            _getter=_name;
        }
        
        
        //setter
        if (!_setter) {
            
            _setter=[NSString stringWithFormat:@"set%@%@:",[_name substringToIndex:1].uppercaseString,[_name substringFromIndex:1]];
        }
        
    }
    
    return self;
    
}



@end
