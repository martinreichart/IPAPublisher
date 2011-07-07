//
//  main.m
//  IPAPublisher
//
//  Created by Martin on 11.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "validatereceipt.h"

const NSString * global_bundleVersion = @"1.0";
const NSString * global_bundleIdentifier = @"com.martinreichart.IPAPublisher";

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
/*#ifndef USE_SAMPLE_RECEIPT
    NSString* pathToReceipt = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/_MASReceipt/receipt"];
#else
    NSString* pathToReceipt = @"/Users/martin/Downloads/receipt";
#endif
    if (!validateReceiptAtPath(pathToReceipt))
		exit(173);*/
    [pool release], pool = nil;
    return NSApplicationMain(argc, (const char **)argv);
}
