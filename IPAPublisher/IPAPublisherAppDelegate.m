//
//  IPAPublisherAppDelegate.m
//  IPAPublisher
//
//  Created by Martin Reichart martin@martinreichart.com on 11.02.11.
//  Copyright 2011 Martin Reichart. All rights reserved.
//

#import "IPAPublisherAppDelegate.h"
#import "IPAFile.h"
#import "IPAPublishLocation.h"

@interface IPAPublisherAppDelegate ()
- (void) readPublishLocations;
@end

@implementation IPAPublisherAppDelegate

@synthesize window, baseDirectoryTextField, urlbaseTextField, publishLocations, locationManagementWindow, selectedPublishLocation, publishIPAWindow, ipaFileToPublish, dropView;

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
    if (self.ipaFileToPublish == nil) {
        self.dropView.delegate = self;
        applicationWasAlreadyRunning = YES;
        [self.window makeKeyAndOrderFront: self];
    } 
    
    [self readPublishLocations];
    
    [self addObserver: self forKeyPath: @"publishLocations" options: NSKeyValueObservingOptionNew context: nil];
}

- (void) readPublishLocations {
    NSArray* publishLocationData = [[NSUserDefaults standardUserDefaults] objectForKey: kIpaPublishLocations];
    
    if (publishLocationData == nil) {
        publishLocations = [NSMutableArray new];
    } else {
        NSMutableArray* array = [NSMutableArray array];
        for (NSDictionary* publishLocationDictionary in publishLocationData) {
            IPAPublishLocation* publishLocation = [[IPAPublishLocation alloc] initWithDictionary: publishLocationDictionary];
            [array addObject: publishLocation];
            [publishLocation release];
        }
        self.publishLocations = array;
    }
}

- (void) dealloc {
    self.dropView.delegate = nil;
    [ipaFileToPublish release], ipaFileToPublish = nil;
    [selectedPublishLocation release], selectedPublishLocation = nil;
    [publishLocations release], publishLocations = nil;
    [super dealloc];
}

- (void) savePublishLocations {
    NSMutableArray* dataArray = [NSMutableArray array];
    for (IPAPublishLocation* location in self.publishLocations) {
        [dataArray addObject: [location dictionaryRepresentation]];
    }
    [[NSUserDefaults standardUserDefaults] setObject: [NSArray arrayWithArray: dataArray] forKey: kIpaPublishLocations];
}

- (NSString*) preparedHTMLForIPAFile: (IPAFile*) ipaFile publishLocation: (IPAPublishLocation*) publishLocation baseURLString: (NSString*) baseURLString artwork: (BOOL) artworkWritten icon: (BOOL) iconWritten {
    NSMutableString* websiteHTML = nil;
    if (publishLocation.customizedHTML == nil || [publishLocation.customizedHTML length] == 0) {
        NSString* resourcePath = [NSBundle pathForResource: @"WebsiteTemplate" ofType: @"html" inDirectory: [[NSBundle mainBundle] bundlePath]];
        NSString* str = [NSString stringWithContentsOfFile: resourcePath encoding: NSUTF8StringEncoding error: nil];
        websiteHTML = [str mutableCopy];        
    } else {
        websiteHTML = [publishLocation.customizedHTML mutableCopy];
    }

    [websiteHTML replaceOccurrencesOfString: @"$title" withString: ipaFile.applicationDisplayName options: NSLiteralSearch range: NSMakeRange(0, [websiteHTML length])];
    [websiteHTML replaceOccurrencesOfString: @"$profilelink" withString: [baseURLString stringByAppendingString: @".mobileprovision"] options: NSLiteralSearch range:NSMakeRange(0, [websiteHTML length])];
    [websiteHTML replaceOccurrencesOfString: @"$plistlink" withString: [baseURLString stringByAppendingString: @".plist"] options: NSLiteralSearch range:NSMakeRange(0, [websiteHTML length])];
    if (artworkWritten) {
        [websiteHTML replaceOccurrencesOfString: @"$artworklink" withString: [baseURLString stringByAppendingString: @"_artwork.png"] options: NSLiteralSearch range:NSMakeRange(0, [websiteHTML length])];
    }
    if (iconWritten) {
        [websiteHTML replaceOccurrencesOfString: @"$iconlink" withString: [baseURLString stringByAppendingString: @"_icon.png"] options: NSLiteralSearch range:NSMakeRange(0, [websiteHTML length])];
    }
    
    return websiteHTML;
}

- (BOOL) application: (NSApplication *) theApplication openFile: (NSString *) filename {
    if (publishLocations == nil) {
        [self readPublishLocations];
    }
    if ([publishLocations count] == 0) {
        NSAlert* alert = [NSAlert alertWithMessageText: @"No Publish Locations configured" defaultButton: @"OK" alternateButton: nil otherButton: nil informativeTextWithFormat: @"You have to configure publish locations before you can publish an IPA file."];
        [alert runModal];
        return YES;
    } else if ([publishLocations count] == 1) {
        self.selectedPublishLocation = [publishLocations objectAtIndex: 0];
        self.ipaFileToPublish = [[[IPAFile alloc] initWithPath: filename] autorelease];
        [self publishIPA: nil];
    } else {
        self.ipaFileToPublish = [[[IPAFile alloc] initWithPath: filename] autorelease];
        [self.publishIPAWindow makeKeyAndOrderFront: self];
    }
    
    return YES;
}

- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context {
    [self savePublishLocations];
}

- (IBAction) dismissPublishLocationManagementView: (id) sender {
    [self savePublishLocations];
    [self.locationManagementWindow orderOut: nil];
}

- (void) setSelectedPublishLocation: (IPAPublishLocation *) _selectedPublishLocation {
    if (selectedPublishLocation != _selectedPublishLocation) {
        [self willChangeValueForKey: @"canPublish"];
        [selectedPublishLocation release];
        selectedPublishLocation = [_selectedPublishLocation retain];
        [self didChangeValueForKey: @"canPublish"];
    }
}

- (BOOL) canPublish {
    return selectedPublishLocation != nil;
}

- (IBAction) publishIPA: (id) sender {
    NSString* urlBase = self.selectedPublishLocation.url;
    NSString* baseDirectory = self.selectedPublishLocation.baseDirectory;
    if (urlBase == nil) return;
    
    if (baseDirectory != nil && [self.ipaFileToPublish.ipaPath hasPrefix: baseDirectory]) {
        NSString* addition = [[self.ipaFileToPublish.ipaPath substringFromIndex: [baseDirectory length]] stringByDeletingLastPathComponent];
        if ([urlBase hasSuffix: @"/"] == NO && [addition hasPrefix: @"/"] == NO) {
            urlBase = [urlBase stringByAppendingString: @"/"];
        }
        if ([addition length] > 0 && [addition isEqualToString: @"/"] == NO) {
            if ([urlBase hasSuffix: @"/"] && [addition hasPrefix: @"/"]) {
                urlBase = [urlBase stringByAppendingString: [addition substringFromIndex: 1]];
            } else {
                urlBase = [urlBase stringByAppendingString: addition];
            }
        }
        if ([urlBase hasSuffix: @"/"] == NO) {
            urlBase = [urlBase stringByAppendingString: @"/"];
        }
    }
    if ([urlBase hasSuffix: @"/"] == NO) {
        urlBase = [urlBase stringByAppendingString: @"/"];
    }
    
    NSString* executableName = [[self.ipaFileToPublish.ipaPath lastPathComponent] stringByDeletingPathExtension];
    NSString* basePath = [self.ipaFileToPublish.ipaPath stringByDeletingPathExtension];
    
    [self.ipaFileToPublish.embeddedProvisioningProfileData writeToFile: [basePath stringByAppendingPathExtension: @"mobileprovision"] atomically: YES];
            
    NSData* itunesArtworkData = self.ipaFileToPublish.iTunesArtworkData;
    NSData* smallIconData = self.ipaFileToPublish.smallIconData;
    
    BOOL artworkWritten = NO;
    BOOL iconWritten = NO;
    
    if (itunesArtworkData) {
        [itunesArtworkData writeToFile: [basePath stringByAppendingString: @"_artwork.png"] atomically: YES];
        artworkWritten = YES;
    } else if (smallIconData) {
        [smallIconData writeToFile: [basePath stringByAppendingString: @"_artwork.png"] atomically: YES];
        artworkWritten = YES;
    }
    
    if (smallIconData) {
        [smallIconData writeToFile: [basePath stringByAppendingString: @"_icon.png"] atomically: YES];
        iconWritten = YES;
    }

    NSString* baseURLString = [urlBase stringByAppendingString: [basePath lastPathComponent]];
    NSString* preparedHTML = [self preparedHTMLForIPAFile: self.ipaFileToPublish publishLocation: self.selectedPublishLocation baseURLString: baseURLString artwork: artworkWritten icon: iconWritten];
    
    [preparedHTML writeToFile: [basePath stringByAppendingPathExtension: @"html"] atomically: YES encoding: NSUTF8StringEncoding error: nil];
    
    NSString* deploymentPropertyListPath = [basePath stringByAppendingPathExtension: @"plist"];
    [[self.ipaFileToPublish deploymentPropertyListDataWithURLStringToExecutable: [urlBase stringByAppendingString: executableName] artwork: artworkWritten icon: iconWritten] writeToFile: deploymentPropertyListPath atomically: YES];
    
    self.ipaFileToPublish = nil;
    
    [self.publishIPAWindow orderOut: nil];
    
    if (applicationWasAlreadyRunning == NO) {
        [[NSApplication sharedApplication] terminate: self];
    }
}

- (void) userDroppedIPAFile: (NSString*) filename {
    [self application: nil openFile: filename];
}

@end
