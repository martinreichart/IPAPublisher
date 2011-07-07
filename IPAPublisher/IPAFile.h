//
//  IPAFile.h
//  IPAPublisher
//
//  Created by Martin Reichart martin@martinreichart.com on 23.02.11.
//  Copyright 2011 Martin Reichart. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IPAFile : NSObject {
    
@private
    NSString* ipaPath;
    NSString* unzippedContentPath;
}

@property (nonatomic, retain) NSString* ipaPath;
@property (nonatomic, readonly) NSDictionary* applicationMetadataDictionary;
@property (nonatomic, readonly) NSString* applicationDisplayName;
@property (nonatomic, readonly) NSString* applicationExecutableName;
@property (nonatomic, readonly) NSData* embeddedProvisioningProfileData;
@property (nonatomic, readonly) NSData* iTunesArtworkData;
@property (nonatomic, readonly) NSData* smallIconData;

- (id) initWithPath: (NSString*) ipaPath;

- (NSData*) deploymentPropertyListDataWithURLStringToExecutable: (NSString*) urlString artwork: (BOOL) artwork icon: (BOOL) icon;

@end
