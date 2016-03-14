//
//  NSObject+CCModel.h
//  CCModel <https://github.com/crash-wu/CCModel-Master>
//
//  Created by 吴小星 on 16/3/9.
//  Copyright © 2016年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCModelHead.h"

@interface NSObject (CCModel)


/**
 Set the receiver's properties with a key-value dictionary.
 
 @param dic  A key-value dictionary mapped to the receiver's properties.
 Any invalid key-value pair in dictionary will be ignored.
 
 @discussion The key in `dictionary` will mapped to the reciever's property name,
 and the value will set to the property. If the value's type doesn't match the
 property, this method will try to convert the value based on these rules:
 
 `NSString`, `NSNumber` -> c number, such as BOOL, int, long, float, NSUInteger...
 `NSString` -> NSDate, parsed with format "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss" or "yyyy-MM-dd".
 `NSString` -> NSURL.
 `NSValue` -> struct or union, such as CGRect, CGSize, ...
 `NSString` -> SEL, Class.
 
 @return Whether succeed.
 */
- (BOOL)cc_modelSetWithDictionary:(NSDictionary *)dic;



/**
 *  @author crash         crash_wu@163.com   , 16-03-11 16:03:04
 *
 *  @brief  Creates and returns a new instance of the receiver from a json.This method is thread-safe.
 *
 *  @param json A json object in 'NSDictionary','NSString' or 'NSData'.
 *
 *  @return A new instance created from the json ,or nil if an error occurs.
 */
+ (instancetype)cc_modelWithJSON:(id)json;

/**
 Creates and returns a new instance of the receiver from a key-value dictionary.
 This method is thread-safe.
 
 @param dictionary  A key-value dictionary mapped to the instance's properties.
 Any invalid key-value pair in dictionary will be ignored.
 
 @return A new instance created from the dictionary, or nil if an error occurs.
 
 @discussion The key in `dictionary` will mapped to the reciever's property name,
 and the value will set to the property. If the value's type does not match the
 property, this method will try to convert the value based on these rules:
 
 `NSString` or `NSNumber` -> c number, such as BOOL, int, long, float, NSUInteger...
 `NSString` -> NSDate, parsed with format "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss" or "yyyy-MM-dd".
 `NSString` -> NSURL.
 `NSValue` -> struct or union, such as CGRect, CGSize, ...
 `NSString` -> SEL, Class.
 */
+ (instancetype)cc_modelWithDictionary:(NSDictionary *)dictionary;



/**
 *  @author crash         crash_wu@163.com   , 16-03-11 16:03:30
 *
 *  @brief  Set the receiver's properties with a json object.Any invalid data in json will be ignored.
 *
 *  @param json A json object of 'NSDicitonary','NSString' or 'NSData' ,mapped to the receiver's properties.
 *
 *  @return Whether succeed.
 */
- (BOOL)cc_modelSetWithJSON:(id)json;




/**
 *  @author crash         crash_wu@163.com   , 16-03-11 16:03:14
 *
 *  @brief  Generate a json object from the receiver's properties.Any of the invalid property is ignored.If the reciver's is 'NSArray','NSDictionary'or 'NSSet',it just convert the inner object to json object.
 *
 *  @return A json object in 'NSDictionary' or 'NSArray' or nil if an error occurs.
 */
- (id)cc_modelToJSONObject;



/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:18
 *
 *  @brief  Generate a json string's data from the receiver's properties.
    Any of the invalid property is ignored.If the reciver is 'NSArray','NSDictionary' or 'NSSet',it will also convert the inner object to json string.
 *
 *  @return NSData.
 */
- (NSData *)cc_modelToJSONData;



/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:07
 *
 *  @brief  Generate  a json string from the receiver's properties.
    Any of the invalid property is ignored. If the reciever's is 'NSArray','NSDictionary' or 'NSSet', it will also convert the inner object to json string.
 *
 *  @return A json string,or nil if an error occurs.
 */
- (NSString *)cc_modelToJSONString;


/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:02
 *
 *  @brief  copy a instance with the receiver's properties.
 *
 *  @return A copied instance ,or nil if an error occurs.
 */
- (id)cc_modelCopy;



/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:30
 *
 *  @brief  Encode the recevier's properties to a coder.
 *
 *  @param aCoder An archiver object.
 */
- (void)cc_modelEncodeWithCoder:(NSCoder *)aCoder;



/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:45
 *
 *  @brief  Decode the receiver's properties from a decoder.
 *
 *  @param aDecoder An archiver object.
 *
 *  @return self
 */
- (id)cc_modelInitWithCoder:(NSCoder *)aDecoder;


/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:13
 *
 *  @brief  Get a has code with the receiver's properties.
 *
 *  @return Hash code
 */
- (NSUInteger)cc_modelHash;

/**
 *  @author crash         crash_wu@163.com   , 16-03-11 15:03:51
 *
 *  @brief  Compares the reciver with another object for equality ,based on properties.
 *
 *  @param model Another object.
 *
 *  @return 'Yes' if the reciever is equal to the objetc,otherwis 'No'.
 */
- (BOOL)cc_modelIsEqual:(id)model;

@end

/**
 *  @author crash         crash_wu@163.com   , 16-03-11 14:03:18
 *
 *  @brief  Provide some data-model method for NSArray.
 */
@interface NSArray (CCModel)

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
+(NSArray *)cc_modelArrayWithClass:(Class )cls json:(id )json;

@end


@interface NSDictionary (CCModel)
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
+(NSDictionary *)cc_modelDictionaryWithClass:(Class )cls json:(id)json;

@end
