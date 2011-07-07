//
//  IPAPublisherDropIPAView.h
//  IPAPublisher
//
//  Created by Martin Reichart martin@martinreichart.com on 23.02.11.
//  Copyright 2011 Martin Reichart. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol IPAPublisherDropIPAViewDelegate<NSObject>
- (void) userDroppedIPAFile: (NSString*) filename;
@end

@interface IPAPublisherDropIPAView : NSBox {
@private
    BOOL inDropMode;
    id<IPAPublisherDropIPAViewDelegate> delegate;
}

@property (nonatomic, assign) id<IPAPublisherDropIPAViewDelegate> delegate;

@end
