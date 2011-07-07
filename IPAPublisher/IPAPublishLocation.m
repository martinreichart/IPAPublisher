//
//  IPAPublishLocation.m
//  IPAPublisher
//
//  Created by Martin Reichart martin@martinreichart.com on 23.02.11.
//  Copyright 2011 Martin Reichart. All rights reserved.
//

#import "IPAPublishLocation.h"

@implementation IPAPublishLocation

@synthesize name, url, baseDirectory, customizedHTML;

- (id) init {
    if ((self = [super init])) {
        name = [@"New Publish Location" retain];
        url = [@"" retain];
        baseDirectory = [@"" retain];
    }
    return self;
}

- (id) initWithDictionary: (NSDictionary*) dictionary {
    if ((self = [super init])) {
        name = [[dictionary objectForKey: @"name"] retain];
        url = [[dictionary objectForKey: @"url"] retain];
        baseDirectory = [[dictionary objectForKey: @"baseDirectory"] retain];
        customizedHTML = [[dictionary objectForKey: @"customizedHTML"] retain];
    }
    return self;
}

- (void) dealloc {
    [name release], name = nil;
    [url release], url = nil;
    [baseDirectory release], baseDirectory = nil;
    [super dealloc];
}

- (NSDictionary*) dictionaryRepresentation {
    NSMutableDictionary* dictionaryRepresentation = [NSMutableDictionary dictionary];
    [dictionaryRepresentation setObject: name ? : @"" forKey: @"name"];
    [dictionaryRepresentation setObject: url ? : @"" forKey: @"url"];
    [dictionaryRepresentation setObject: baseDirectory ? : @"" forKey: @"baseDirectory"];
    if (customizedHTML) {
        [dictionaryRepresentation setObject: customizedHTML forKey: @"customizedHTML"];
    }
    return [NSDictionary dictionaryWithDictionary: dictionaryRepresentation];
}

@end
