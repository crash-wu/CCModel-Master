//
//  CCModell.h
//  CCModel <https://github.com/crash-wu/CCModel-Master>
//
//  Created by 吴小星 on 16/3/10.
//  Copyright © 2016年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  @author crash         crash_wu@163.com   , 16-03-10 09:03:27
 *
 *  @brief  If the default model transform does not fit to your model class,
 or implement one or more method in this protocol to change the default key-value transform process.
 There's no need to add'<CCModel>'to your class header.
 */
@protocol CCModel <NSObject>
@optional

/**
 *  @author crash         crash_wu@163.com   , 16-03-10 09:03:47
 *
 *  @brief  If the key in JSON/Dictionary does not match to the model's property name ,
 implement this method and returns the additional mapper.
 
    Example:
 
    JSON:{
        "n":"Harry Pottery",
        "p":256,
        "ext":{
 
            "desc":"A book "
        },
        "ID":10000
    }
 
    model:
        @interface BookModel:NSObject
        @property NSString *name;
        @property NSInteger page;
        @property NSString *desc;
        @property NSString *bookID;
        @end
 
        @implementation BookModel
            +(NSDictionary*)modelCustomPropertyMapper{
                return @{@"name":@"n",
                        @"page":@"p",
                        @"desc":@"ext.desc",
                        @"bookID":@[@"id",@"ID",@"book_id"]
                    };
                }
        @end
 *
 *  @return A custom mapper for properties.
 */
+(NSDictionary *)modelCustomPropertyMapper;

/**
 *  @author crash         crash_wu@163.com   , 16-03-10 10:03:55
 *
 *  @brief  The generic class mapper for container properties.
 
 If the property is a container object,such as NSArray/NSSet/NSDictionary,
 implements this method and returns a property->class mapper,tells which kind of object will be add to the array/set/dictionary.
 
        Example:
            @class YYShadow,YYBorder,YYAttachment;
            @interface YYAttributes
            @property NSString *name;
            @property NSArray *shadows;
            @property NSSet *borders;
            @property NSDictionary *attachments;
            @end
 
            @implementation YYAttributes
 
                +(NSDictionary*)modelContainerPropertyGenericClass{
 
                    return @{@"shadowos":[YYShadow class],
                            @"borders":YYBorder.class,
                            @"attachments":@"YYAttachment"};
                }
            @end
 *
 *  @return A class mapper.
 */
+(NSDictionary *)modelContainerPropertyGenericClass;

/**
 *  @author crash         crash_wu@163.com   , 16-03-10 10:03:23
 *
 *  @brief  If you need to create instance of different classes during json->object transform,
 use the method to choose custom class base on dictionary data.
 If the model implement this method ,it will be called to determine resulting class during '+modelWithJSON:','+modelWithDictionary:',conveting object of properties of parant objects(both singular and containers via '+modelContainerPropertyGenericClass').
 
        Example:
            @class YYCircle, YYRectangle, YYLine;
 
            @implementation YYShape
 
            + (Class)modelCustomClassForDictionary:(NSDictionary*)dictionary {
                    if (dictionary[@"radius"] != nil) {
                            return [YYCircle class];
                    } else if (dictionary[@"width"] != nil) {
                            return [YYRectangle class];
                    } else if (dictionary[@"y2"] != nil) {
                            return [YYLine class];
                    } else {
                            return [self class];
                    }
                }
 
            @end
 *
 *  @param dictionary The json/kv dictionary.
 *
 *  @return Class to create from this dictionary ,'nil'to use current class.
 */
+(Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;

/**
 *  @author crash         crash_wu@163.com   , 16-03-10 11:03:03
 *
 *  @brief  All the properties in blacklist will be ignored in model transform process.
    Return nil to ignore this feature.
 *
 *  @return An array of property's name(Array<NSString>).
 */
+(NSArray *)modelPropertyBlacklist;

/**
 *  @author crash         crash_wu@163.com   , 16-03-10 11:03:30
 *
 *  @brief  If a property is not in the whitelist ,it will be ignored in model transform process.
    Return ni to ignored this feature.
 *
 *  @return An array of property's name(Array<NSString>).
 */
+(NSArray *)modelpropertyWhitelist;

/**
 *  @author crash         crash_wu@163.com   , 16-03-10 11:03:06
 *
 *  @brief  If the default json-to-model transform does not fit to your model object,
    implement this method to do addtional process.You can also use this method to validate the model's propretise.
    If the model implement this method ,it will be called at the end of '+modelWithJSON:','+modelWithDictionary:','-modelSetWithJSON:' and '-modelSetWithDictionary:'.
    If this method returns NO,the transform process will ignore this model.
 *
 *  @param dic The json/kv dictionary.
 *
 *  @return Return Yes if the model is valid ,or No to ignore this model.
 */
-(BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;

/**
 *  @author crash         crash_wu@163.com   , 16-03-10 11:03:54
 *
 *  @brief  If the default model-to-json transform does not fit to your model class,
    implement this method to do additional process.You can also use this method to validate the json dictionary.
    If the model implement this method ,it will be called at the end of '-modelToJSONObject' and '-modelTOJSONString'.
    If the method return No,the transform process will ignore this json dictionary.
 *
 *  @param dic The json dictionary
 *
 *  @return Return YES if the model is valid,or NO to ignore this model.
 */
-(BOOL)modelCustomTransformToDictionary:(NSMutableDictionary*)dic;

@end