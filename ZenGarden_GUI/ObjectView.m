//
//  ObjectView.m
//  ObjectDrawing
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectView.h"


@implementation ObjectView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      
      [self addTextView:frame];
      
      [self addObjectResizeTrackingRect:frame];
      objectResizeTrackingArea = [[NSTrackingArea alloc] 
                                          initWithRect:objectResizeTrackingRect
                                          options: (NSTrackingMouseEnteredAndExited | 
                                                    NSTrackingMouseMoved | 
                                                    NSTrackingActiveInKeyWindow|
                                                    NSTrackingCursorUpdate)
                                                    owner:self userInfo:nil];
      [self addTrackingArea:objectResizeTrackingArea];
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
  
  [self drawTextView:dirtyRect];

}

- (void)drawBackground:(NSRect)rect {
  
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:
                              NSMakeRect(rect.origin.x + 5,
                                         rect.origin.y + 5,
                                         rect.size.width - 10,
                                         rect.size.height - 10) 
                              xRadius:20 yRadius:20];
  
  [[NSColor blueColor] setFill];
  [path fill];
  
  [path setLineWidth:10];
  [[NSColor lightGrayColor] setStroke];
  [path stroke];
}

- (void)addTextView:(NSRect)rect {
  NSRect textViewRect = NSMakeRect(rect.origin.x + 30,
                                   rect.origin.y + 30,
                                   30,
                                   rect.size.height - 60);
  textView = [[TextView alloc] initWithFrame:textViewRect];
  [self addSubview:textView];
  [textView setRichText:NO];
  [textView setDelegate:self];
  [[textView textContainer] setContainerSize:NSMakeSize(10, 30)];
}

- (void)drawTextView:(NSRect)rect {
  [textView setFrame:NSMakeRect(rect.origin.x + 30,
                                rect.origin.y + 30,
                                rect.size.width - 60,
                                rect.size.height - 60)];
}

- (void)addLet:(NSPoint)letOrigin isInlet:(BOOL)isInlet isSignal:(BOOL)isSignal {
  
  NSRect letRect = NSMakeRect(letOrigin.x, letOrigin.y, 30, 10);
  
  letView = [[LetView alloc] initWithFrame:letRect];
  [self addSubview:letView];
  [letArray addObject:letView];
  [letView release];
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
  NSLog(@"OBJECT MOUSE DOWN");
}

- (BOOL)isFlipped { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

- (BOOL)becomeFirstResponder { return YES; }

@end
