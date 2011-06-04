//
//  InletView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InletView.h"
#import "ObjectView.h"


@implementation InletView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [[self window] setAcceptsMouseMovedEvents:YES];
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  
  NSBezierPath * path = [NSBezierPath bezierPathWithRect:NSMakeRect(self.frame.origin.x - 1, 
      self.frame.origin.y + 1, 10, 3)];
  
  [[NSColor blackColor] set]; 
  [path fill];
}

- (void)viewDidMoveToWindow {
  NSTrackingArea *inletTrackingArea = [[NSTrackingArea alloc] 
      initWithRect:NSMakeRect(self.frame.origin.x - 5, self.frame.origin.y - 5, 
      self.frame.size.width + 10, self.frame.size.height + 10) 
      options:(NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow) 
      owner:self userInfo:NULL];
  [self addTrackingArea:inletTrackingArea];
  [self becomeFirstResponder];
}

- (void)mouseEntered:(NSEvent *)theEvent {
  [(ObjectView *)self.superview showInletOutletCursor:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
  [(ObjectView *)self.superview showInletOutletCursor:NO];
}

- (void)mouseDown:(NSEvent *)theEvent {
  [(ObjectView *)self.superview setConnectionStartPoint:[theEvent locationInWindow]];
}

- (void)mouseUp:(NSEvent *)theEvent {
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (BOOL)isFlipped {
  return YES;
}

@end
