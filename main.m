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

#import <Cocoa/Cocoa.h>

#import <IOKit/IOKitLib.h>
#import <Foundation/Foundation.h>

#import <Security/Security.h>

#include <openssl/pkcs7.h>
#include <openssl/objects.h>
#include <openssl/sha.h>
#include <openssl/x509.h>

static inline CFDataRef copy_apple_root_certificate(void) {
	OSStatus status;

	SecKeychainRef keychain = nil;
	status = SecKeychainOpen("/System/Library/Keychains/SystemRootCertificates.keychain", &keychain);
	if(status) {
		if(keychain) CFRelease(keychain);
		return nil;
	}

	CFArrayRef searchList = CFArrayCreate(kCFAllocatorDefault, (const void**)&keychain, 1, &kCFTypeArrayCallBacks);

	if (keychain)
		CFRelease(keychain);

	SecKeychainSearchRef searchRef = nil;
	status = SecKeychainSearchCreateFromAttributes(searchList, kSecCertificateItemClass, NULL, &searchRef);
	if(status) {
		if(searchRef) CFRelease(searchRef);
		if(searchList) CFRelease(searchList);
		return nil;
	}

	SecKeychainItemRef itemRef = nil;
	CFDataRef certificateData = nil;

	while(SecKeychainSearchCopyNext(searchRef, &itemRef) == noErr && certificateData == nil) {
		// Grab the name of the certificate
		SecKeychainAttributeList list;
		SecKeychainAttribute attributes[1];

		attributes[0].tag = kSecLabelItemAttr;

		list.count = 1;
		list.attr = attributes;

		SecKeychainItemCopyContent(itemRef, nil, &list, nil, nil);
		
		const char* certificate_name = attributes[0].data;
		size_t certificate_name_length = attributes[0].length;

		if(strncmp(certificate_name, "Apple Root CA", certificate_name_length) == 0) {
			CSSM_DATA certData;
			status = SecCertificateGetData((SecCertificateRef)itemRef, &certData);
			if(status) {
				if(itemRef) CFRelease(itemRef);
			}

			certificateData = CFDataCreate(
				NULL,
				certData.Data,
				certData.Length);

			SecKeychainItemFreeContent(&list, NULL);
			if(itemRef) CFRelease(itemRef);
		}
	}
	CFRelease(searchList);
	CFRelease(searchRef);

	return certificateData;
}

static inline CFDataRef copy_mac_address(void) {
    kern_return_t             kernResult;
    mach_port_t               master_port;
    CFMutableDictionaryRef    matchingDict;
    io_iterator_t             iterator;
    io_object_t               service;
    CFDataRef                 macAddress = nil;

    kernResult = IOMasterPort(MACH_PORT_NULL, &master_port);
    if (kernResult != KERN_SUCCESS) {
        printf("IOMasterPort returned %d\n", kernResult);
        return nil;
    }

    matchingDict = IOBSDNameMatching(master_port, 0, "en0");
    if(!matchingDict) {
        printf("IOBSDNameMatching returned empty dictionary\n");
        return nil;
    }

    kernResult = IOServiceGetMatchingServices(master_port, matchingDict, &iterator);
    if (kernResult != KERN_SUCCESS) {
        printf("IOServiceGetMatchingServices returned %d\n", kernResult);
        return nil;
    }

    while((service = IOIteratorNext(iterator)) != 0)
    {
        io_object_t        parentService;

        kernResult = IORegistryEntryGetParentEntry(service, kIOServicePlane, &parentService);
        if(kernResult == KERN_SUCCESS)
        {
            if(macAddress) CFRelease(macAddress);

            macAddress = IORegistryEntryCreateCFProperty(parentService, CFSTR("IOMACAddress"), kCFAllocatorDefault, 0);
            IOObjectRelease(parentService);
        }
        else {
            printf("IORegistryEntryGetParentEntry returned %d\n", kernResult);
        }

        IOObjectRelease(service);
    }

    return macAddress;
}

#define SOPHIESTICATION_VALIDATE_RECEIPT

int main(int argc, char *argv[]) {
@autoreleasepool {

#ifdef SOPHIESTICATION_VALIDATE_RECEIPT
	CFURLRef bundle_url = CFBundleCopyBundleURL(CFBundleGetMainBundle());
	CFURLRef receipt_url = CFURLCreateCopyAppendingPathComponent(
		NULL,
		bundle_url,
		(CFStringRef)@"Contents/_MASReceipt/receipt",
		false);
	
	// we use [appStoreReceiptURL] if available
	if([NSBundle instancesRespondToSelector:@selector(appStoreReceiptURL)]) {
		CFRelease(receipt_url);
		receipt_url = CFBridgingRetain([[NSBundle mainBundle] appStoreReceiptURL]);
	}
	
	CFIndex receiptfile_length = 1024; // 1k should be enough to hold the complete path
	UInt8* receiptfile = malloc(receiptfile_length);
	
	Boolean fileSystemRepresenationResult = CFURLGetFileSystemRepresentation(
		receipt_url,
		true,
		receiptfile,
		receiptfile_length);
		
	CFRelease(bundle_url);
	CFRelease(receipt_url);
	
	if(!fileSystemRepresenationResult) {
		return 173;
	}
	
	FILE* file = fopen((const char*)receiptfile, "rb");
	free(receiptfile);
	
	if(!file) {
		return 173;
	}
	
	ERR_load_PKCS7_strings();
	ERR_load_X509_strings();

	OpenSSL_add_all_digests();
	
	PKCS7* receipt = d2i_PKCS7_fp(file, NULL);
	fclose(file);
	
	if(!receipt) {
		return 173;
	}
	
	if(!PKCS7_type_is_signed(receipt)) {
		PKCS7_free(receipt);
		return 173;
	}
	
	if(!PKCS7_type_is_data(receipt->d.sign->contents)) {
		PKCS7_free(receipt);
		return 173;
	}
	
	// Check if the receipt was signed with the Apple root certificate
	CFDataRef root_certificate = copy_apple_root_certificate();
	
	if(!root_certificate) {
		PKCS7_free(receipt);
		return 173;
	}
	
	BIO* payload = BIO_new(BIO_s_mem());
	X509_STORE* store = X509_STORE_new();

	unsigned char* certificate_buffer = (unsigned char*)CFDataGetBytePtr(root_certificate);
	CFIndex certificate_buffer_length = CFDataGetLength(root_certificate);
	
	X509* appleCA = d2i_X509(NULL, (const unsigned char**)&certificate_buffer, certificate_buffer_length);

	X509_STORE_add_cert(store, appleCA);

	int certificate_verification_result = PKCS7_verify(receipt, NULL, store, NULL, payload, 0);

	BIO_free(payload);
	X509_free(appleCA);

	X509_STORE_free(store);
	EVP_cleanup();
	
	CFRelease(root_certificate);

	if(certificate_verification_result != 1) {
		PKCS7_free(receipt);
		return 173;
	}

	// Read in all relevant attributes
	ASN1_OCTET_STRING* asn1String = receipt->d.sign->contents->d.data;
	
	// Relevant receipt attribute types according to http://developer.apple.com/devcenter/mac/documents/validating.html
	enum container_attributes {
        first_container_attribute = 1,
        bundleid_container_attribute = 2, // Interpret as an ASN.1 UTF8STRING
        version_container_attribute = 3, // Interpret as an ASN.1 UTF8STRING
        opaquevalue_container_attribute = 4, // Interpret as a series of bytes
        hash_container_attribute = 5, // Interpret as a 20-byte SHA-1 digest value
        last_container_attribute
    };
	
	unsigned char* bundleid = NULL;
	long bundleid_length = 0;
	
	unsigned char* bundleidbuffer = NULL;
	long bundleidbuffer_length;
	
	unsigned char* version = NULL;
	long version_length = 0;
	
	unsigned char* opaquevalue = NULL;
	long opaquevalue_length = 0;
	
	unsigned char* hash = NULL;
	long hash_length = 0;
	
	unsigned char* first = asn1String->data;
	unsigned char* current = first;
	unsigned char* end = first + asn1String->length;
	
	int iterator_type= 0;
	int iterator_class = 0;
	long iterator_length = 0;
    
    ASN1_get_object((const unsigned char**)&current, &iterator_length, &iterator_type, &iterator_class, end - first);
    
	if(iterator_type != V_ASN1_SET) {
        PKCS7_free(receipt);
        return 173;
    }
	
	while(current < end) {
		 ASN1_get_object((const unsigned char**)&current, &iterator_length, &iterator_type, &iterator_class, end - current);
		 
		 if(iterator_type != V_ASN1_SEQUENCE) {
			continue;
		 }
		 
		 unsigned char* sequence_end = current + iterator_length;
		 
		 int attribute_type = 0;
		 int attribute_version = 0;
		 
		 ASN1_get_object((const unsigned char**)&current, &iterator_length, &iterator_type, &iterator_class, sequence_end - current);
		 
		 if(iterator_type == V_ASN1_INTEGER && iterator_length == 1) {
			attribute_type = current[0];
		 }
		 
		 current += iterator_length;
		 
		 ASN1_get_object((const unsigned char**)&current, &iterator_length, &iterator_type, &iterator_class, sequence_end - current);
		 
		 if(iterator_type == V_ASN1_INTEGER && iterator_length == 1) {
			attribute_version = current[0];
			attribute_version = attribute_version;
		 }
		 
		 current += iterator_length;
		 
		 if(attribute_type > first_container_attribute && attribute_type < last_container_attribute) {
			ASN1_get_object((const unsigned char**)&current, &iterator_length, &iterator_type, &iterator_class, sequence_end - current);
			
			if(iterator_type == V_ASN1_OCTET_STRING) {
				switch(attribute_type) {
					case opaquevalue_container_attribute:
						opaquevalue = current;
						opaquevalue_length = iterator_length;
					break;
					
					case hash_container_attribute:
						hash = current;
						hash_length = iterator_length;
					break;
					
					case bundleid_container_attribute:
						bundleidbuffer = current;
						bundleidbuffer_length = iterator_length;
					break;
				}
			}
			
			if(	attribute_type == bundleid_container_attribute ||
				attribute_type == version_container_attribute) {
				int string_type = 0;
				int string_class = 0;
				long string_length = 0;
				unsigned char* string = current;
				
				ASN1_get_object((const unsigned char**)&string, &string_length, &string_type, &string_class, sequence_end - string);
				
				if(string_type == V_ASN1_UTF8STRING) {
					switch(attribute_type) {
						case bundleid_container_attribute:
							bundleid = string;
							bundleid_length = string_length;
						break;
						
						case version_container_attribute:
							version = string;
							version_length = string_length;
						break;
					}
				}
			}
			
			current += iterator_length;
		 }

		 while(current < sequence_end) {
			ASN1_get_object((const unsigned char**)&current, &iterator_length, &iterator_type, &iterator_class, sequence_end - current);
			current += iterator_length;
		 }
	}
	
	if(	!bundleid ||
		!version ||
		!opaquevalue ||
		!hash) {
		PKCS7_free(receipt);
		return 173;
	}
	
	CFBundleRef mainBundle = CFBundleGetMainBundle();

	CFStringRef bundleIdentifier = CFBundleGetValueForInfoDictionaryKey(mainBundle, kCFBundleIdentifierKey);
	CFStringRef bundleVersion = CFBundleGetValueForInfoDictionaryKey(mainBundle, (CFStringRef)@"CFBundleShortVersionString");

	CFStringRef bundleIdentifierString = CFStringCreateWithBytesNoCopy(NULL, bundleid, bundleid_length, kCFStringEncodingUTF8, false, kCFAllocatorNull);
	CFStringRef bundleVersionString = CFStringCreateWithBytesNoCopy(NULL, version, version_length, kCFStringEncodingUTF8, false, kCFAllocatorNull);

	if(	CFStringCompare(bundleIdentifier, bundleIdentifierString, 0) != kCFCompareEqualTo ||
		CFStringCompare(bundleVersion, bundleVersionString, 0) != kCFCompareEqualTo) {
		CFRelease(bundleIdentifierString);
		CFRelease(bundleVersionString);
		
		PKCS7_free(receipt);
		
		return 173;
	}
	
	CFRelease(bundleIdentifierString);
	CFRelease(bundleVersionString);

	CFDataRef guid = copy_mac_address();
	CFIndex guid_length = CFDataGetLength(guid);

	size_t buffer_length = guid_length + opaquevalue_length + bundleidbuffer_length;
	unsigned char* buffer = malloc(buffer_length);
	
	memcpy(buffer, CFDataGetBytePtr(guid), guid_length);
	memcpy((buffer + guid_length), opaquevalue, opaquevalue_length);
	memcpy((buffer + guid_length + opaquevalue_length), bundleidbuffer, bundleidbuffer_length);
	
	CFRelease(guid);
	
	unsigned char* digest = malloc(SHA_DIGEST_LENGTH);
	
	SHA1(buffer, buffer_length, digest);

	if(memcmp(digest, hash, MIN(hash_length, SHA_DIGEST_LENGTH)) != 0) {
		PKCS7_free(receipt);

		free(buffer);
		free(digest);
		
		return 173;
	}

	PKCS7_free(receipt);

	free(buffer);
	free(digest);
#endif

	return NSApplicationMain(argc, (const char**)argv);
}
}
