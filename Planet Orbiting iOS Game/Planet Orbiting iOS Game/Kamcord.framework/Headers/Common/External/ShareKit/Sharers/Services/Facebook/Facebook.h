/*
 * Copyright 2010 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FBLoginDialog.h"
#import "FBRequest.h"

@protocol KC_FBSessionDelegate;

@class KC_Facebook;
@compatibility_alias Facebook KC_Facebook;

/**
 * Main Facebook interface for interacting with the Facebook developer API.
 * Provides methods to log in and log out a user, make requests using the REST
 * and Graph APIs, and start user interface interactions (such as
 * pop-ups promoting for credentials, permissions, stream posts, etc.)
 */
@interface KC_Facebook : NSObject<KC_FBLoginDialogDelegate>{
  NSString* _accessToken;
  NSDate* _expirationDate;
  id<KC_FBSessionDelegate> _sessionDelegate;
  NSMutableSet* _requests;
  FBDialog* _loginDialog;
  FBDialog* _fbDialog;
  NSString* _appId;
  NSString* _urlSchemeSuffix;
  NSArray* _permissions;
}

@property(nonatomic, copy) NSString* accessToken;
@property(nonatomic, copy) NSDate* expirationDate;
@property(nonatomic, assign) id<KC_FBSessionDelegate> sessionDelegate;
@property(nonatomic, copy) NSString* urlSchemeSuffix;

- (id)initWithAppId:(NSString *)appId
        andDelegate:(id<KC_FBSessionDelegate>)delegate;

- (id)initWithAppId:(NSString *)appId
    urlSchemeSuffix:(NSString *)urlSchemeSuffix
        andDelegate:(id<KC_FBSessionDelegate>)delegate;

- (void)authorize:(NSArray *)permissions useSSO:(BOOL)SSOEnabled;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)logout;

- (FBRequest*)requestWithParams:(NSMutableDictionary *)params
                    andDelegate:(id <KC_FBRequestDelegate>)delegate;

- (FBRequest*)requestWithMethodName:(NSString *)methodName
                          andParams:(NSMutableDictionary *)params
                      andHttpMethod:(NSString *)httpMethod
                        andDelegate:(id <KC_FBRequestDelegate>)delegate;

- (FBRequest*)requestWithGraphPath:(NSString *)graphPath
                       andDelegate:(id <KC_FBRequestDelegate>)delegate;

- (FBRequest*)requestWithGraphPath:(NSString *)graphPath
                         andParams:(NSMutableDictionary *)params
                       andDelegate:(id <KC_FBRequestDelegate>)delegate;

- (FBRequest*)requestWithGraphPath:(NSString *)graphPath
                         andParams:(NSMutableDictionary *)params
                     andHttpMethod:(NSString *)httpMethod
                       andDelegate:(id <KC_FBRequestDelegate>)delegate;

- (void)dialog:(NSString *)action
   andDelegate:(id<KC_FBDialogDelegate>)delegate;

- (void)dialog:(NSString *)action
     andParams:(NSMutableDictionary *)params
   andDelegate:(id <KC_FBDialogDelegate>)delegate;

- (BOOL)isSessionValid;

@end

////////////////////////////////////////////////////////////////////////////////

/**
 * Your application should implement this delegate to receive session callbacks.
 */
@protocol KC_FBSessionDelegate <NSObject>

@optional

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin;

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled;

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout;

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired 
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated;

@end
