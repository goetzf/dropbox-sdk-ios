//
//  DBSession+iOS.h
//  DropboxSDK
//
//  Created by Brian Smith on 3/7/12.
//  Copyright (c) 2012 Dropbox. All rights reserved.
//

#import "DBSession.h"

#import <UIKit/UIKit.h>

@interface DBSession (iOS)

+ (NSDictionary*)parseURLParams:(NSString *)query;

- (NSString *)appScheme;

- (void)linkFromController:(UIViewController *)rootController;
- (void)linkUserId:(NSString *)userId fromController:(UIViewController *)rootController;

- (void)linkFromController:(UIViewController *)rootController presentationHandler:(void(^)(UIViewController *viewController))presentationHandler dismissalHandler:(void(^)(BOOL success, UIViewController *viewController))dismissalHandler;
- (void)linkUserId:(NSString *)userId fromController:(UIViewController *)rootController presentationHandler:(void(^)(UIViewController *viewController))presentationHandler dismissalHandler:(void(^)(BOOL success, UIViewController *viewController))dismissalHandler;

- (BOOL)handleOpenURL:(NSURL *)url linkedUserId:(NSString **)userId;
- (BOOL)handleOpenURL:(NSURL *)url;

@end
