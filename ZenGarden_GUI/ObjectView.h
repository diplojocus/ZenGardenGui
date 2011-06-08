//
//  ObjectView.h
//  ObjectDrawing
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LetView.h"
#import "TextView.h"


@interface ObjectView : NSView <NSTextViewDelegate> {
  
  float numberOfInlets;
  float numberOfOutlets;
  LetView *letView;
  NSMutableArray *letArray;
  
  TextView *textView;
  
  NSRect objectResizeTrackingRect;
  NSTrackingArea *objectResizeTrackingArea;
  NSCursor *cursor;
  
@private
    
}

- (void)drawBackground:(NSRect)rect;
- (void)addTextView:(NSRect)rect;
- (void)drawTextView:(NSRect)rect;
- (void)addLet:(NSPoint)letOrigin isInlet:(BOOL)isInlet isSignal:(BOOL)isSignal;
- (void)addObjectResizeTrackingRect:(NSRect)rect;

@end
