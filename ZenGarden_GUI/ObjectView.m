//
//  ObjectView.m
//  ObjectDrawing
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectView.h"
#import "CanvasMainView.h"


@implementation ObjectView

@synthesize letArray;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      
      // adding NSTextField instead of NSTextView for now
      //[self addTextView:frame];
      [self addTextField:frame];
      
      [self addObjectResizeTrackingRect:frame];
      objectResizeTrackingArea = [[NSTrackingArea alloc] 
                                          initWithRect:objectResizeTrackingRect
                                          options: (NSTrackingMouseEnteredAndExited | 
                                                    NSTrackingMouseMoved | 
                                                    NSTrackingActiveInKeyWindow|
                                                    NSTrackingCursorUpdate)
                                                    owner:self userInfo:nil];
      [self addTrackingArea:objectResizeTrackingArea];
      [self highlightObject:NO];
    }
    
    return self;
}

- (void)dealloc {
  [letView release];
  [textView release];
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  [self drawBackground:dirtyRect];
  [self addLet:NSMakePoint(self.bounds.origin.x + 30 , 0) isInlet:YES isSignal:YES];
  [self addLet:NSMakePoint(self.bounds.origin.x + 100 , 0) isInlet:YES isSignal:YES];
  [self addLet:NSMakePoint(self.bounds.origin.x + 170 , 0) isInlet:YES isSignal:YES];
  [self addLet:NSMakePoint(self.bounds.origin.x + 30 , self.bounds.size.height - 10)
       isInlet:NO isSignal:YES];
  
  //[self drawTextView:dirtyRect];

}

- (void)drawBackground:(NSRect)rect {
  
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:
                              NSMakeRect(rect.origin.x + 5,
                                         rect.origin.y + 5,
                                         rect.size.width - 10,
                                         rect.size.height - 10) 
                              xRadius:20 yRadius:20];
  
  [backgroundColour setFill];
  [path fill];
  
  [path setLineWidth:10];
  [[NSColor lightGrayColor] setStroke];
  [path stroke];
}

// TODO(joewhite4): Find out why object is highlighted on mouseUp rather than mouseDown
- (void)highlightObject:(BOOL)state {
  if (state) {
    isHighlighted = YES;
    backgroundColour = [NSColor greenColor];
  }
  else {
    isHighlighted = NO;
    backgroundColour = [NSColor blueColor];
  }
}

- (void)addTextView:(NSRect)rect {
  NSRect textViewRect = NSMakeRect(rect.origin.x + 30,
                                   rect.origin.y + 30,
                                   30,
                                   rect.size.height - 60);
  textView = [[TextView alloc] initWithFrame:textViewRect];
  [self addSubview:textView];
  [textView setRichText:NO];
//  [textView setDelegate:self];
  [[textView textContainer] setContainerSize:NSMakeSize(10, 30)];
}

- (void)drawTextView:(NSRect)rect {
  [textView setFrame:NSMakeRect(rect.origin.x + 30,
                                rect.origin.y + 30,
                                rect.size.width - 60,
                                rect.size.height - 60)];
}
       
- (void)addTextField:(NSRect)rect {
  NSRect textFieldRect = NSMakeRect(rect.origin.x + 30,
                                   rect.origin.y + 30,
                                   30,
                                   rect.size.height - 60);
  NSTextField *textField = [[NSTextField alloc] initWithFrame:textFieldRect];
  [self addSubview:textField];
  [textField setDelegate:self];
  [textField setSelectable:YES];
  [textField setEditable:YES];
//  [[textView textContainer] setContainerSize:NSMakeSize(10, 30)];
}

- (void)addLet:(NSPoint)letOrigin isInlet:(BOOL)isInlet isSignal:(BOOL)isSignal {
  
  NSRect letRect = NSMakeRect(letOrigin.x, letOrigin.y, 30, 10);
  
  letView = [[LetView alloc] initWithFrame:letRect];
  [self addSubview:letView];
  [letArray addObject:letView];
  [letView release];
}

- (void)letMouseDown:(NSPoint)location {
  [(CanvasMainView *)self.superview startConnectionDrawing:location];
}

- (void)addObjectResizeTrackingRect:(NSRect)rect {
  objectResizeTrackingRect = NSMakeRect(self.frame.size.width - 10, 20,
                                                10, self.frame.size.height - 40);
}

- (void)updateTrackingAreas {
  
  [self addObjectResizeTrackingRect:self.frame];
  
  [self removeTrackingArea:objectResizeTrackingArea];
  [objectResizeTrackingArea release];
  objectResizeTrackingArea = [[NSTrackingArea alloc] 
                                      initWithRect:objectResizeTrackingRect
                                      options: (NSTrackingMouseEnteredAndExited |
                                                NSTrackingMouseMoved |
                                                NSTrackingActiveInKeyWindow | 
                                                NSTrackingCursorUpdate)
                                                owner:self userInfo:nil];
  [self addTrackingArea:objectResizeTrackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent {
  cursor = [NSCursor resizeRightCursor];
}

- (void)mouseExited:(NSEvent *)theEvent {
  cursor = [NSCursor arrowCursor];
}

- (void)cursorUpdate:(NSEvent *)event {
  [cursor set];
}

- (void)mouseDown:(NSEvent *)theEvent {
  NSPoint adjustedMousePosition = [self positionInsideObject:[theEvent locationInWindow]];
  [(CanvasMainView *)self.superview moveObject:self with:adjustedMousePosition];
  if ([(CanvasMainView *)self.superview isEditModeOn]) {
    [self highlightObject:YES];
    if ([theEvent clickCount] > 1) {
      NSLog(@"Start Editing");
    }
  }
}

- (void)mouseDragged:(NSEvent *)theEvent {

  [(CanvasMainView *)self.superview mouseDragged:theEvent];
}

- (NSPoint)positionInsideObject:(NSPoint)fromEventPosition {
  NSPoint convertedPoint = NSMakePoint(fromEventPosition.x - self.frame.origin.x,
                                       [(CanvasMainView *)self.superview frame].size.height - 
                                       fromEventPosition.y - self.frame.origin.y);
  return convertedPoint;
}


- (BOOL)isFlipped { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

- (BOOL)becomeFirstResponder { return YES; }

@end
