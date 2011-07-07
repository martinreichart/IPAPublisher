//
//  IPAPublishLocation.h
//  IPAPublisher
//
//  Created by Martin Reichart martin@martinreichart.com on 23.02.11.
//  Copyright 2011 Martin Reichart. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IPAPublishLocation : NSObject {
    NSString* name;
    NSString* url;
    NSString* baseDirectory;
    NSString* customizedHTML;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* baseDirectory;
@property (nonatomic, retain) NSString* customizedHTML;

- (id) initWithDictionary: (NSDictionary*) dictionary;
- (NSDictionary*) dictionaryRepresentation;

@end
