//
//  LetView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LetView.h"
#import "ObjectView.h"


@implementation LetView

- (id)initWithFrame:(NSRect)frame delegate:(NSObject<LetViewDelegate> *)aDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    delegate = [aDelegate retain];
    [self resetTrackingArea];
    [[self window] setAcceptsMouseMovedEvents:YES];
  }
  
  return self;
}

- (void)dealloc {
  [delegate dealloc];
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  
  [self drawBackground];

}

- (void)drawBackground {
  
  NSRect letRect = NSMakeRect(self.bounds.origin.x, self.bounds.origin.y, 30, 10);
  
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:letRect xRadius:2 yRadius:2];
  [[NSColor blackColor] setFill];
  [path fill];
}

#pragma mark - Tracking Mouse

- (void)updateTrackingAreas {
  [self resetTrackingArea];
}

- (void)resetTrackingArea {
  NSRect trackingRect = self.bounds; 
  
  [self removeTrackingArea:letTrackingArea];
  [letTrackingArea release];
  letTrackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect
                                                 options: (NSTrackingMouseEnteredAndExited | 
                                                           NSTrackingMouseMoved | 
                                                           NSTrackingActiveInKeyWindow | 
                                                           NSTrackingCursorUpdate)
                                                   owner:self userInfo:nil];
  [self addTrackingArea:letTrackingArea];
}

- (void)mouseDown:(NSEvent *)theEvent {
  [delegate mouseDownOfLet:self];
}

- (void)mouseUp:(NSEvent *)theEvent {
  [delegate mouseUpOfLet:self];
}

- (void)mouseEntered:(NSEvent *)theEvent {
  cursor = [NSCursor crosshairCursor];
}

- (void)mouseExited:(NSEvent *)theEvent {
  cursor = [NSCursor arrowCursor];
  [cursor set];
}

- (void)cursorUpdate:(NSEvent *)event {
  [cursor set];
}

- (BOOL)isFlipped { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

@end
