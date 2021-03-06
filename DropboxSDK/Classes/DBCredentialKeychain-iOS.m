//
//  DBCredentialKeychain.m
//  DropboxSDK
//
//  Created by Brian Smith on 4/5/12.
//  Copyright (c) 2012 Dropbox, Inc. All rights reserved.
//

#import "DBCredentialKeychain.h"

#import "DBLog.h"

static NSDictionary *kDBCredentialKeychainDict;


@implementation DBCredentialKeychain

+ (void)initialize {
	if ([self class] != [DBCredentialKeychain class]) return;
	NSString *keychainId = [NSString stringWithFormat:@"%@.dropbox.auth", [[NSBundle mainBundle] bundleIdentifier]];
	kDBCredentialKeychainDict = [[NSDictionary alloc] initWithObjectsAndKeys:
					   (id)kSecClassGenericPassword, (id)kSecClass,
					   keychainId, (id)kSecAttrService,
					   nil];
}

+ (NSDictionary *)credentials {
	NSMutableDictionary *searchDict = [NSMutableDictionary dictionaryWithDictionary:kDBCredentialKeychainDict];
	[searchDict setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	[searchDict setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
	[searchDict setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];

	NSDictionary *attrDict = nil;
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)searchDict, (CFTypeRef *)&attrDict);
	[attrDict autorelease];
	NSData *foundValue = [attrDict objectForKey:(id)kSecValueData];

	if (status == noErr && foundValue) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:foundValue];
	} else {
		if (status != errSecItemNotFound) {
			DBLogWarning(@"DropboxSDK: error reading stored credentials (%i)", (int32_t)status);
		}
		return nil;
	}
}

+ (void)setCredentials:(NSDictionary *)credentials {
	NSData *credentialData = [NSKeyedArchiver archivedDataWithRootObject:credentials];

	NSMutableDictionary *attrDict = [NSMutableDictionary dictionaryWithDictionary:kDBCredentialKeychainDict];
	[attrDict setObject:credentialData forKey:(id)kSecValueData];

	NSArray *version = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    if ([[version objectAtIndex:0] intValue] >= 4) {
        [attrDict setObject:(id)kSecAttrAccessibleAfterFirstUnlock forKey:(id)kSecAttrAccessible];
    }

	OSStatus status = noErr;

	if ([self credentials]) {
		[attrDict removeObjectForKey:(id)kSecClass];
		status = SecItemUpdate((CFDictionaryRef)kDBCredentialKeychainDict, (CFDictionaryRef)attrDict);
	} else {
		status = SecItemAdd((CFDictionaryRef)attrDict, NULL);
	}

	if (status != noErr) {
		DBLogWarning(@"DropboxSDK: error saving credentials (%i)", (int32_t)status);
	}
}

+ (void)deleteCredentials {
	OSStatus status = SecItemDelete((CFDictionaryRef)kDBCredentialKeychainDict);

	if (status != noErr) {
		DBLogWarning(@"DropboxSDK: error deleting credentials (%i)", (int32_t)status);
	}
}

@end
