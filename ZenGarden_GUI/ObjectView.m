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
@synthesize isLetMouseDown;
@synthesize isHighlighted;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      
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
      
      [self addLet:NSMakePoint(self.bounds.origin.x + 30 , 0) isInlet:YES isSignal:YES];
      [self addLet:NSMakePoint(self.bounds.origin.x + 100 , 0) isInlet:YES isSignal:YES];
      [self addLet:NSMakePoint(self.bounds.origin.x + 170 , 0) isInlet:YES isSignal:YES];
      [self addLet:NSMakePoint(self.bounds.origin.x + 30 , self.bounds.size.height - 10)
           isInlet:NO isSignal:YES];
    }
    
    return self;
}

- (void)dealloc {
  [letView release];
  [textField release];
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  
  [textField setFrame:NSMakeRect(self.bounds.origin.x + 30,
                                 self.bounds.origin.y + 30,
                                 self.bounds.size.width - 60,
                                 self.bounds.size.height - 60)];

  [self drawBackground:self.bounds];
}

- (BOOL)isFlipped { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

- (BOOL)becomeFirstResponder { return YES; }


#pragma mark - Background Drawing

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

- (void)highlightObject:(BOOL)state {
  if (state) {
    isHighlighted = YES;
    backgroundColour = [NSColor greenColor];
  }
  else {
    isHighlighted = NO;
    backgroundColour = [NSColor blueColor];
  }
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}


#pragma mark - Let drawing

- (void)addLet:(NSPoint)letOrigin isInlet:(BOOL)isInlet isSignal:(BOOL)isSignal {
  
  NSRect letRect = NSMakeRect(letOrigin.x, letOrigin.y, 30, 10);
  
  letView = [[LetView alloc] initWithFrame:letRect];
  [self addSubview:letView];
  [letArray addObject:letView];
  [letView release];
}

- (void)setLetMouseDown:(LetView *)let withState:(BOOL)state {
  letMouseDown = let;
  isLetMouseDown = state;
}

#pragma mark - TextField & Events

- (void)addTextField:(NSRect)rect {
  textField = [[NSTextField alloc] initWithFrame:NSMakeRect(rect.origin.x + 30,
                                                            rect.origin.y + 30,
                                                            30,
                                                            rect.size.height - 60)];
  
  [textField setEditable:YES];
  [textField setSelectable:YES];
  [textField setBezeled:NO];
  [self addSubview:textField];
  [textField setDelegate:self];
}

- (void)setTextFieldEditable:(BOOL)state {
  [textField setEditable:state];
  [textField setSelectable:state];
  NSLog(@"%d", state);
}

- (void)controlTextDidBeginEditing:(NSNotification *)obj {
  NSLog(@"TEXT BEGIN EDITING");
  [self highlightObject:YES];
}

- (void)controlTextDidChange:(NSNotification *)obj {
  NSLog(@"TEXT CHANGE");
  [textField sizeToFit];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
  NSLog(@"TEXT END EDITING");
  NSString *textValue = [textField stringValue];
  NSLog(@"%@", textValue);
  
  [self highlightObject:NO];
}


#pragma mark - Mouse events

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
  if (isLetMouseDown) {
    NSPoint letOriginInCanvas = NSMakePoint(self.frame.origin.x + letMouseDown.frame.origin.x + NSMidX(letMouseDown.bounds),
                                             self.frame.origin.y + letMouseDown.frame.origin.y + NSMidY(letMouseDown.bounds));
    [(CanvasMainView *)self.superview startConnectionDrawing:letOriginInCanvas];
  }
  else {
    NSLog(@"Object Mouse Down");
    NSPoint adjustedMousePosition = [self positionInsideObject:[theEvent locationInWindow]];
    [(CanvasMainView *)self.superview moveObject:self with:adjustedMousePosition];
    if ([(CanvasMainView *)self.superview isEditModeOn]) {
      [self highlightObject:YES];
      if ([theEvent clickCount] > 1) {
        NSLog(@"Start Editing");
      }
    }
  }
}


- (void)mouseDragged:(NSEvent *)theEvent {
  
  // call CanvasMainView mouse dragged event
  [super mouseDragged:theEvent];
}

- (NSPoint)positionInsideObject:(NSPoint)fromEventPosition {
  NSPoint convertedPoint = NSMakePoint(fromEventPosition.x - self.frame.origin.x,
                                       [(CanvasMainView *)self.superview frame].size.height - 
                                       fromEventPosition.y - self.frame.origin.y);
  return convertedPoint;
}

@end
