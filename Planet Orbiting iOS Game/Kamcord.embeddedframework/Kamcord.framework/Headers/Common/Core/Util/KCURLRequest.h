//
//  KCURLRequest.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 2/17/13.
//
//

#import <Foundation/Foundation.h>

@interface KCURLRequest : NSObject  <NSURLConnectionDelegate>

// Is the URL request a GET or POST?
typedef enum
{
    KC_URL_REQUEST_GET,
    KC_URL_REQUEST_POST,
} KCURLRequestType;

// Properties
@property (nonatomic, copy)     NSURL *             url;
@property (nonatomic, assign)   KCURLRequestType    requestType;
@property (nonatomic, copy)     NSString *          contentType;
@property (nonatomic, retain)   NSData *            body;
@property (nonatomic, assign)   NSUInteger          timeout;
@property (nonatomic, copy)     void (^completionHandler)(NSData *, NSError *, KCURLRequest *);

// Init and dealloc
- (id)initWithURL:(NSURL *)url
      requestType:(KCURLRequestType)requestType
      contentType:(NSString *)contentType
             body:(NSData *)body
          timeout:(NSUInteger)timeout
completionHandler:(void (^)(NSData *, NSError *, KCURLRequest *))completionHandler;
- (void)dealloc;

// Actually perform the URL connection
- (void)start;

@end
