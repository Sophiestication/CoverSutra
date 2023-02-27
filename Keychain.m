//
// MIT License
//
// Copyright (c) 2006-2023 Sophiestication Software, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "Keychain.h"
#import "Keychain+Private.h"

#import "Utilities.h"

@implementation Keychain

+ (Keychain*)defaultKeychain {
	static Keychain* _defaultKeychain = nil;
	
	if(!_defaultKeychain) {
		_defaultKeychain = [[Keychain alloc] init];
	}
	
	return _defaultKeychain;
}

- (id)init {
	if(![super init]) {
		_keychain = NULL;
	}
	
	return self;
}

- (NSString*)genericPasswordForService:(NSString*)service account:(NSString*)account {
	const char* serviceName = [service UTF8String];
	UInt32 serviceNameSize = strlen(serviceName);
	
	const char* accountName = account ? [account UTF8String] : 0;
	UInt32 accountNameSize = account ? strlen(accountName) : 0;
	
	void* buffer = 0;
	UInt32 bufferSize = 0;
	
	OSStatus result = SecKeychainFindGenericPassword(
		_keychain,
		serviceNameSize, serviceName,
		accountNameSize, accountName,
		&bufferSize, &buffer,
		NULL);
	
	NSString* genericPassword = nil;
	
	if(result == noErr && bufferSize > 0) {
		genericPassword = [[NSString alloc] initWithBytes:buffer length:bufferSize encoding:NSUTF8StringEncoding];
	}
	
	if(buffer) {
		SecKeychainItemFreeContent(NULL, buffer);
	}
	
	return genericPassword;
}

- (void)setGenericPassword:(NSString*)genericPassword forService:(NSString*)service account:(NSString*)account {
	if(IsEmpty(account) || IsEmpty(service)) {
		return; // Nothing to do
	}
	
	SecKeychainItemRef keychainItem = [self _genericKeychainItemForService:service account:account];
	
	const char* password = [genericPassword UTF8String];
	UInt32 passwordSize = password ? strlen(password) : 0;
	
	OSStatus result = noErr;
	
	if(keychainItem) {
		if(passwordSize > 0) { // Modify password
			result = SecKeychainItemModifyAttributesAndData(
				keychainItem,
				NULL,
				passwordSize, password);
			
			if(result != noErr) {
				// TODO
			}
			
			CFRelease(keychainItem);
			
			return;
		} else { // Remove password
			result = SecKeychainItemDelete(keychainItem);
			
			if(result != noErr) {
				// TODO
			}
			
			CFRelease(keychainItem);
			
			return;
		}
	}
	
	if(passwordSize > 0) {
		// Add new password
		const char* serviceName = [service UTF8String];
		UInt32 serviceNameSize = strlen(serviceName);
		
		const char* accountName = [account UTF8String];
		UInt32 accountNameSize = strlen(accountName);

		result = SecKeychainAddGenericPassword(
			_keychain,
			serviceNameSize, serviceName,
			accountNameSize, accountName,
			passwordSize, password,
			NULL);
			
		if(result != noErr) {
			// TODO
		}
	}
	
	if(keychainItem) {
		CFRelease(keychainItem);
	}
}

- (SecKeychainItemRef)_genericKeychainItemForService:(NSString*)service account:(NSString*)account {
	if(IsEmpty(account) || IsEmpty(service)) {
		return nil;
	}
	
	const char* serviceName = [service UTF8String];
	UInt32 serviceNameSize = serviceName ? strlen(serviceName) : 0;
	
	const char* accountName = [account UTF8String];
	UInt32 accountNameSize = account ? strlen(accountName) : 0;
	
	SecKeychainItemRef keychainItem = 0;
	
	OSStatus result = SecKeychainFindGenericPassword(
		_keychain,
		serviceNameSize, serviceName,
		accountNameSize, accountName,
		NULL, NULL,
		&keychainItem);
		
	if(result != noErr) {
		// TODO
	}
	
	return keychainItem;
}

@end
