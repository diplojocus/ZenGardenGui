//
//  ObjectView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectView.h"
#import "CanvasMainView.h"

@implementation ObjectView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      inletArray = [[NSMutableArray alloc] init];
      [self drawTextField:NSMakeRect(2, 2, (frame.size.width - 4), frame.size.height - 4)];
      [self drawInlet:NSMakeRect(3, 0, 50, 3)];
      [self drawOutlet:frame];
      [self instantiateObject:NO];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [self drawBackground:dirtyRect];
}

- (void)drawBackground:(NSRect)frame {
  [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:5 yRadius:5];
  [[objectBackgroundColour colorWithAlphaComponent:0.15f]set];
  [path fill];
}

- (void)drawTextField:(NSRect)frame {
  textField = [[NSTextField alloc] initWithFrame:frame];
  [textField setDelegate:self];
  [textField setEditable:NO];
  [textField setSelectable:NO];
  [textField setBezeled:NO];
  [textField setDrawsBackground:NO];
  [self addSubview:textField]; 
}

- (void)drawInlet:(NSRect)frame {
  InletView *inlet = [[InletView alloc] initWithFrame:frame];
  [self addSubview:inlet];
  [inletArray addObject:inlet];
  [inlet release];
}

- (void)drawOutlet:(NSRect)frame {
  
}

- (void)instantiateObject:(BOOL)selector {
  isObjectInstantiated = selector;
  
  if (isObjectInstantiated) {
    objectBackgroundColour = [NSColor blueColor];
  }
  else {
    objectBackgroundColour = [NSColor redColor];
  }
}

- (void)highlightObject:(NSString *)colour {
  
  if (colour == @"GREEN") {
    objectBackgroundColour = [NSColor greenColor];
  }
  else {
    
    objectBackgroundColour = [NSColor blueColor];
  }
}

- (BOOL)isObjectHighlighted {
  
  if (objectBackgroundColour == [NSColor greenColor]) {
    
    return YES;
  }
  else {
    return NO;
  }
}


#pragma mark - Mouse Behaviour

- (void)mouseDown:(NSEvent *)theEvent {
  
  [(CanvasMainView *)self.superview setObjectFrameOrigin];
  
  // edit text field
  [textField setEditable:YES];
  [textField setSelectable:YES];
  [textField selectText:self];
}

-(void)mouseUp:(NSEvent *)theEvent {
  
}

- (void)mouseDragged:(NSEvent *)theEvent {
    
}


#pragma mark - Textfield Behaviour 

- (void)controlTextDidBeginEditing:(NSNotification *)obj {

  objectBackgroundColour = [NSColor redColor];
  isObjectInstantiated = NO;
  
}

-(void)controlTextDidChange:(NSNotification *)obj {
  NSString *textFieldValue = [textField stringValue];
  [textField sizeToFit];
  [self setFrame:NSMakeRect([self frame].origin.x,
                            [self frame].origin.y,
                            [textField frame].size.width + 4, 
                            [textField frame].size.height + 4)];
  
}

- (void) controlTextDidEndEditing:(NSNotification *)obj {

  // release focus
  [[self window] makeFirstResponder:self];
  
  zgObject = [((CanvasMainView *) self.superview) instantiateZgObject:[textField stringValue]
      atLocation:[self frame].origin];
  isObjectInstantiated = (zgObject != NULL);
  
  // instantiate object
  if (isObjectInstantiated) {
    
    objectBackgroundColour = [NSColor blueColor];
    isObjectInstantiated = YES;
    
    //[self drawInlet];
    
  }
  else {
    
    objectBackgroundColour = [NSColor redColor];
    isObjectInstantiated = NO;
  }
  

  
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
  return YES;
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (BOOL)isFlipped {
  return YES;
}

- (void)dealloc {
  
  [textField release];
  [super dealloc];
}


@end
