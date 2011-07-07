//
//  IPAFile.m
//  IPAPublisher
//
//  Created by Martin Reichart martin@martinreichart.com on 23.02.11.
//  Copyright 2011 Martin Reichart. All rights reserved.
//

#import "IPAFile.h"
#import "ZipArchive.h"

@interface IPAFile ()
@property (nonatomic, readonly) NSString* unzippedContentPath;
@property (nonatomic, readonly) NSString* applicationBundleDirectory;
@property (nonatomic, readonly) NSDictionary* infoPlistDictionary;
@property (nonatomic, readonly, getter = isUnzipped) BOOL unzipped;

- (void) unzipIPAFile;
- (void) removeUnzippedContent;

@end

@implementation IPAFile

@synthesize ipaPath;

- (id) initWithPath: (NSString*) _ipaPath {
    if ((self = [super init])) {
        ipaPath = [_ipaPath retain];
    }
    
    return self;
}

- (void) dealloc {
    [ipaPath release], ipaPath = nil;
    [self removeUnzippedContent];
    [super dealloc];
}

- (BOOL) isUnzipped {
    return [[NSFileManager defaultManager] fileExistsAtPath: self.unzippedContentPath];
}

- (NSString*) applicationBundleDirectory {
    if (self.unzipped == NO) [self unzipIPAFile];
    
    NSString* payloadDirectory = [self.unzippedContentPath stringByAppendingPathComponent: @"Payload"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: payloadDirectory]) {
        for (NSString* subpath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath: payloadDirectory error: nil]) {
            if ([subpath rangeOfString: @"DS_Store"].location != NSNotFound) continue;
            
            return [payloadDirectory stringByAppendingPathComponent: subpath];
        }
    }
    
    return nil;
}

- (NSString*) unzippedContentPath {
    if (unzippedContentPath == nil) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString* cacheFolder = [paths objectAtIndex: 0];    
        unzippedContentPath = [[cacheFolder stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"tmp"]] retain];
    }
    return unzippedContentPath;
}

- (void) unzipIPAFile {
    ZipArchive* zip = [ZipArchive new];
    [zip UnzipOpenFile: ipaPath];
    [zip UnzipFileTo: self.unzippedContentPath overWrite:YES];
    [zip UnzipCloseFile];
    [zip release];
}

- (void) removeUnzippedContent {
    [[NSFileManager defaultManager] removeItemAtPath: self.unzippedContentPath error: nil];
}

- (NSData*) embeddedProvisioningProfileData {
    return [NSData dataWithContentsOfFile: [self.applicationBundleDirectory stringByAppendingPathComponent: @"embedded.mobileprovision"]];
}

- (NSDictionary*) infoPlistDictionary {
    NSString* infoPlistPath = [self.applicationBundleDirectory stringByAppendingPathComponent: @"Info.plist"];
    
    return [NSPropertyListSerialization propertyListFromData: [NSData dataWithContentsOfFile: infoPlistPath] mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];    
}

- (NSDictionary*) applicationMetadataDictionary {
    NSDictionary *properties = self.infoPlistDictionary;
    
    NSString* bundleIdentifier = [properties objectForKey: @"CFBundleIdentifier"];
    NSString* bundleVersion = [properties objectForKey: @"CFBundleVersion"];
    NSString* displayName = [properties objectForKey: @"CFBundleDisplayName"];
    
    NSDictionary* metadataDictionary = [NSDictionary dictionaryWithObjectsAndKeys: bundleIdentifier, @"bundle-identifier", bundleVersion, @"bundle-version", @"software", @"kind", @"", @"subtitle", displayName, @"title", nil];
    
    return metadataDictionary;
}

- (NSString*) applicationDisplayName {
    return [self.infoPlistDictionary objectForKey: @"CFBundleDisplayName"];
}

- (NSString*) applicationExecutableName {
    return [self.infoPlistDictionary objectForKey: @"CFBundleExecutable"];
}

- (NSData*) deploymentPropertyListDataWithURLStringToExecutable: (NSString*) urlString artwork: (BOOL) artwork icon: (BOOL) icon {
    NSDictionary* assetDictionary = [NSDictionary dictionaryWithObjectsAndKeys: @"software-package", @"kind", [urlString stringByAppendingString: @".ipa"], @"url", nil];
    NSDictionary* fullSizeImage = [NSDictionary dictionaryWithObjectsAndKeys: @"full-size-image", @"kind", [urlString stringByAppendingString: @"_artwork.png"], @"url", [NSNumber numberWithBool: NO], @"needs-shine", nil];
    NSDictionary* displayImage = [NSDictionary dictionaryWithObjectsAndKeys: @"display-image", @"kind", [urlString stringByAppendingString: @"_icon.png"], @"url", [NSNumber numberWithBool: NO], @"needs-shine", nil];

    NSMutableArray* array = [NSMutableArray array];
    [array addObject: assetDictionary];
    if (artwork) {
        [array addObject: fullSizeImage];
    }
    if (icon) {
        [array addObject: displayImage];
    }
    NSDictionary* itemsDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NSArray arrayWithArray: array], @"assets", self.applicationMetadataDictionary, @"metadata", nil];
    NSDictionary* deploymentPropertyListDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NSArray arrayWithObject: itemsDictionary], @"items", nil];
 
    return [NSPropertyListSerialization dataFromPropertyList: deploymentPropertyListDictionary format: NSPropertyListXMLFormat_v1_0 errorDescription:nil];
}

- (NSData*) iTunesArtworkData {
    return [NSData dataWithContentsOfFile: [self.applicationBundleDirectory stringByAppendingPathComponent: @"iTunesArtwork"]];
}

- (NSData*) smallIconData {
    NSData* artwork = self.iTunesArtworkData;
    if (artwork == nil) return nil;
    
    NSImage* artworkImage = [[[NSImage alloc] initWithData: artwork] autorelease];
    if (artworkImage == nil) return nil;
    [artworkImage setScalesWhenResized: YES];
    
    NSImage *smallImage = [[[NSImage alloc] initWithSize: NSMakeSize(57.0, 57.0)] autorelease];
    [smallImage lockFocus];
    [artworkImage setSize: NSMakeSize(57.0, 57.0)];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [artworkImage compositeToPoint: NSZeroPoint operation: NSCompositeCopy];
    [smallImage unlockFocus];
    
    NSBitmapImageRep* representation = [NSBitmapImageRep imageRepWithData: [smallImage TIFFRepresentation]];
    return [representation representationUsingType: NSPNGFileType properties: nil];
}

@end
