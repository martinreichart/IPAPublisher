//
//  IPAPublisherDropIPAView.m
//  IPAPublisher
//
//  Created by Martin Reichart martin@martinreichart.com on 23.02.11.
//  Copyright 2011 Martin Reichart. All rights reserved.
//

#import "IPAPublisherDropIPAView.h"

@implementation IPAPublisherDropIPAView

@synthesize delegate;

- (id) initWithFrame: (NSRect) frame {
    if (([super initWithFrame:frame])) {
        [self registerForDraggedTypes: [NSArray arrayWithObject: NSFilenamesPboardType]];
        [self setTitlePosition: NSNoTitle];
        [self setBoxType: NSBoxCustom];
        [self setBorderType: NSLineBorder];
        [self setCornerRadius: 10.0];
        [self setFillColor: [NSColor clearColor]];
    }
    
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self setTitlePosition: NSNoTitle];
    [self setBoxType: NSBoxCustom];
    [self setBorderType: NSLineBorder];
    [self setCornerRadius: 10.0];
    [self setFillColor: [NSColor clearColor]];

    [self registerForDraggedTypes: [NSArray arrayWithObject: NSFilenamesPboardType]];
}

- (void) dealloc {
    delegate = nil;
    [super dealloc];
}

- (void) drawRect: (NSRect) dirtyRect {
    if (inDropMode) {
        [self setFillColor: [NSColor lightGrayColor]];
    } else {
        [self setFillColor: [NSColor clearColor]];
    }
    [super drawRect: dirtyRect];
}

- (NSDragOperation) draggingEntered: (id <NSDraggingInfo>) sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];

    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        NSArray* files = [pboard propertyListForType:NSFilenamesPboardType];
        
        if ([files count] != 1) {
            inDropMode = NO;
            [self setNeedsDisplay: YES];
            return NSDragOperationNone;
        }
        
        if ([[files objectAtIndex: 0] hasSuffix: @".ipa"] == NO) {
            inDropMode = NO;
            [self setNeedsDisplay: YES];
            return NSDragOperationNone;
        }
        
        if (sourceDragMask & NSDragOperationLink) {
            inDropMode = YES;
            [self setNeedsDisplay: YES];
            return NSDragOperationCopy;
        }
    }
    
    inDropMode = NO;
    [self setNeedsDisplay: YES];
    
    return NSDragOperationNone;
}

- (void) draggingExited: (id < NSDraggingInfo >) sender {
    inDropMode = NO;
    [self setNeedsDisplay: YES];
}

- (BOOL) performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];

        if ([files count] != 1) {
            inDropMode = NO;
            [self setNeedsDisplay: YES];
            return NO;
        }
        
        if ([[files objectAtIndex: 0] hasSuffix: @".ipa"] == NO) {
            inDropMode = NO;
            [self setNeedsDisplay: YES];
            return NO;
        }
        
        if (sourceDragMask & NSDragOperationCopy) {
            if (delegate && [delegate respondsToSelector: @selector(userDroppedIPAFile:)]) {
                [delegate userDroppedIPAFile: [files objectAtIndex: 0]];
            }
        }
    }
    
    inDropMode = NO;
    [self setNeedsDisplay: YES];
    
    return YES;
}

@end
