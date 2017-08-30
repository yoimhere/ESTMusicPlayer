//
//  KDHttpConnection.m
//  KDAssisentHttp
//
//  Created by admin  on 2017/8/10.
//  Copyright © 2017年 kd. All rights reserved.
//

#import "KDHttpConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"
#import "KDHttpStore.h"
#import "KDHttpRoute.h"
#import "KDHttpResponse.h"
#import "YYModel.h"

static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;

@implementation KDHttpConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    
    // Add support for POST
    if ([method isEqualToString:@"POST"] || [method isEqualToString:@"GET"])
    {
        return YES;
    }
    
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    
    if([method isEqualToString:@"POST"]) return YES;
    if([method isEqualToString:@"GET"])  return NO;
    
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    HTTPLogTrace();
    
    NSString *body;
    NSData *postData = [request body];
    if (postData)
    {
        body = [[NSString alloc] initWithData: [request body] encoding:NSUTF8StringEncoding];
    }
    
    NSDictionary *dict = [KDHttpRoute body:body path:path];
    if (dict)
    {
        NSString *dataStr = [dict yy_modelToJSONString];
        NSData *response  = [dataStr dataUsingEncoding:NSUTF8StringEncoding];

        KDHttpResponse *res = [[KDHttpResponse alloc] initWithData:response];
        return res;
    }
    
    return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    HTTPLogTrace();
}

- (void)processBodyData:(NSData *)postDataChunk
{
    HTTPLogTrace();
    
    // Remember: In order to support LARGE POST uploads, the data is read in chunks.
    // This prevents a 50 MB upload from being stored in RAM.
    // The size of the chunks are limited by the POST_CHUNKSIZE definition.
    // Therefore, this method may be called multiple times for the same POST request.
    
    BOOL result = [request appendData:postDataChunk];
    if (!result)
    {
        HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
    }
}

- (NSData *)preprocessResponse:(HTTPMessage *)response
{
    [response setHeaderField:@"Access-Control-Allow-Origin" value:@"*"];
    return [super preprocessResponse:response];
}


@end
