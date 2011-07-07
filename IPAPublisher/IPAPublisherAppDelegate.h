//
//  IPAPublisherAppDelegate.h
//  IPAPublisher
//
//  Created by Martin Reichart martin@martinreichart.com on 11.02.11.
//  Copyright 2011 Martin Reichart. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IPAPublisherDropIPAView.h"

#define kIpaPublishLocations @"IPAPUBLISHER_IPA_PUBLISH_LOCATIONS"

@class IPAPublishLocation, IPAFile;

@interface IPAPublisherAppDelegate : NSObject <NSApplicationDelegate, IPAPublisherDropIPAViewDelegate> {
@private
    NSTextField* urlbaseTextField;
    NSTextField* baseDirectoryTextField;
    NSWindow *window;
    NSWindow* locationManagementWindow;
    NSWindow* publishIPAWindow;
    IPAPublisherDropIPAView* dropView;
    NSMutableArray* publishLocations;
    IPAPublishLocation* selectedPublishLocation;
    IPAFile* ipaFileToPublish;
    BOOL canPublish;
    BOOL applicationWasAlreadyRunning;
}

@property (assign) IBOutlet NSTextField* urlbaseTextField;
@property (assign) IBOutlet NSTextField* baseDirectoryTextField;
@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet NSWindow* locationManagementWindow;
@property (assign) IBOutlet NSWindow* publishIPAWindow;
@property (assign) IBOutlet IPAPublisherDropIPAView* dropView;
@property (nonatomic, retain) NSMutableArray* publishLocations;
@property (nonatomic, retain) IPAPublishLocation* selectedPublishLocation;
@property (nonatomic, retain) IPAFile* ipaFileToPublish;
@property (assign, readonly) BOOL canPublish;

- (IBAction) dismissPublishLocationManagementView: (id) sender;
- (IBAction) publishIPA: (id) sender;

@end
