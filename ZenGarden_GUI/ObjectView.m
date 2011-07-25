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

@synthesize inletArray;
@synthesize outletArray;
@synthesize isLetMouseDown;
@synthesize isHighlighted;
@synthesize zgObject;

- (id)initWithFrame:(NSRect)frame delegate:(NSObject<ObjectViewDelegate> *)aDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    delegate = [aDelegate retain];
    inletArray = [[NSMutableArray alloc] init];
    outletArray = [[NSMutableArray alloc] init];    
    isObjectNew = YES;
    didTextChange = NO;
    zgObject = NULL;
    
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
  [delegate release];
  [LetView release];
  [textField release];
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  
  [textField setFrame:NSMakeRect(self.bounds.origin.x + 5,
                                 self.bounds.origin.y + 8,
                                 self.bounds.size.width - 10,
                                 self.bounds.size.height - 14)];
 
  [self drawBackground:self.bounds];
}

- (BOOL)isFlipped { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }


#pragma mark - Background Drawing

- (void)drawBackground:(NSRect)rect {
   
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(rect.origin.x + 2,
                                                                          rect.origin.y + 2.5,
                                                                          rect.size.width - 4,
                                                                          rect.size.height - 4)
                                                               xRadius:4 yRadius:4];
  
  [[NSColor whiteColor] setFill];
  [path fill];
  
  NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1 alpha:1]
                                                       endingColor:[NSColor colorWithCalibratedWhite:0.7 alpha:0.7]];
  [gradient drawInBezierPath:path angle:90.0];
  
  [path setLineWidth:1];
  NSColor *outsideStroke;
  outsideStroke = [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.8 alpha:1.0];
  [outsideStroke setStroke];
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

- (void)addLet:(NSPoint)letOrigin isInlet:(BOOL)isInlet {
  
  NSRect letRect = NSMakeRect(letOrigin.x, letOrigin.y, 12, 4);
  
  LetView *aLetView = [[LetView alloc] initWithFrame:letRect delegate:self];
  [self addSubview:aLetView];
  
  aLetView.isInlet = isInlet;
  if (isInlet) {
    [inletArray addObject:aLetView]; 
  }
  else {
    [outletArray addObject:aLetView];
  }
}

#pragma mark - TextField & Events

- (void)addTextField:(NSRect)rect {
  textField = [[NSTextField alloc] initWithFrame:NSMakeRect(self.bounds.origin.x + 5,
                                                            self.bounds.origin.y + 8,
                                                            self.bounds.size.width - 10,
                                                            self.bounds.size.height - 14)];
  [textField setEditable:YES];
  [textField setSelectable:YES];
  [textField setBezeled:NO];
  [textField setDrawsBackground:NO];
  [textField setFont:[NSFont fontWithName:@"Monaco" size:12.0]];
  [self addSubview:textField];
  [textField setDelegate:self];
}

- (void)setTextFieldEditable:(BOOL)state {
  [textField setEditable:state];
  [textField setSelectable:state];
}

- (void)controlTextDidBeginEditing:(NSNotification *)obj {
  [self highlightObject:YES];
}

- (void)controlTextDidChange:(NSNotification *)obj {
  
  if (!isObjectNew) {
    didTextChange = YES;
  }
  [textField sizeToFit];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
  // if textfield changes reinstantiate object 
  if (didTextChange) {
    [self removeZGObjectFromZGGraph:[(CanvasMainView *)self.superview zgGraph]];
    for (LetView *aLetView in inletArray) {
      [aLetView removeFromSuperview];
    }
    for (LetView *aLetView in outletArray) {
      [aLetView removeFromSuperview];
    }
    [inletArray removeAllObjects];
    [outletArray removeAllObjects];
    didTextChange = NO;
  }
  // Add zgObject
  zgObject = [delegate addNewObjectToGraphWithInitString:[textField stringValue]
                                            withLocation:self.frame.origin];
  if (zgObject == NULL) {
    NSLog(@"zgObject could not be created.");
  } else {
    // Add inlets
    for (int i = 0; i < zg_get_num_inlets(zgObject); i++) {
      [self addLet:NSMakePoint(self.bounds.origin.x + 10 + 38*i, 3) isInlet:YES];
    }
    // Add outlets
    for (int i = 0; i < zg_get_num_outlets(zgObject); i++) {
      [self addLet:NSMakePoint(self.bounds.origin.x + 10 + 70*i, self.bounds.size.height - 6) isInlet:NO];
    }
  }
  isObjectNew = NO;
  [self highlightObject:NO];
  [[textField window] endEditingFor: nil];
  [[textField window] makeFirstResponder: nil];
}


#pragma mark - Mouse events

- (NSPoint)positionInsideObject:(NSPoint)fromEventPosition {
  NSPoint convertedPoint = NSMakePoint(fromEventPosition.x - self.frame.origin.x,
                                       [(CanvasMainView *)self.superview frame].size.height - 
                                       fromEventPosition.y - self.frame.origin.y);
  return convertedPoint;
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
  // Only works in edit mode
  if ([(CanvasMainView *)self.superview isEditModeOn]) {
    // Highlight object
    [self highlightObject:YES];
  }
  // Adjust mouse position when dragging to keep it in place relative to the object
  NSPoint adjustedMousePosition = [self positionInsideObject:[theEvent locationInWindow]];
  [(CanvasMainView *)self.superview moveObject:self with:adjustedMousePosition];
}

- (void)mouseDragged:(NSEvent *)theEvent {
  // Call CanvasMainView mouse dragged event
  [super mouseDragged:theEvent];
}


#pragma mark - Let Events

- (void)mouseDownOfLet:(LetView *)aLetView {
  [delegate startNewConnectionDrawingFromLet:aLetView];
}

- (void)mouseDraggedOfLet:(LetView *)aLetView withEvent:(NSEvent *)theEvent {
  [delegate setNewConnectionEndPointFromLet:aLetView withEvent:theEvent];
}

- (void)mouseUpOfLet:(LetView *)aLetView withEvent:(NSEvent *)theEvent {
  [delegate endNewConnectionDrawingFromLet:aLetView withEvent:theEvent];
}

#pragma mark - ZenGarden Objects

- (void)removeZGObjectFromZGGraph:(ZGGraph *)graph {
  if (zgObject != NULL) {
    NSLog(@"Remove object");
    zg_remove_object(graph, zgObject);
  }
  else {
    NSLog(@"No ZGObject to remove");
  }
}

@end
