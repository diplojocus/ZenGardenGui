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

@synthesize isObjectInstantiated;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      inletArray = [[NSMutableArray alloc] init];
      [self drawTextView:NSMakeRect(2, 2, (frame.size.width) - 4, frame.size.height - 4)];
      [self instantiateObject:NULL];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
  [self drawBackground:dirtyRect];
}

- (void)drawBackground:(NSRect)frame {
  [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:5 yRadius:5];
  [[objectBackgroundColour colorWithAlphaComponent:0.15f]set];
  [path fill];
}

- (void)drawTextView:(NSRect)frame {
  textView = [[TextView alloc] initWithFrame:frame];
  [self addSubview:textView];
  [textView setDelegate:self];
}

- (void)drawInlet:(NSRect)frame {
  inletView = [[InletView alloc] initWithFrame:frame];
  [self addSubview:inletView];
  [inletArray addObject:inletView];
  [inletView release];
}

- (void)drawOutlet:(NSRect)frame {
  outletView = [[OutletView alloc] initWithFrame:frame];
  [self addSubview:outletView];
  [outletArray addObject:outletView];
  [outletView release];
}

- (void)instantiateObject:(ZGObject *)objectLabel {
  isObjectInstantiated = (objectLabel != NULL);
  if (isObjectInstantiated) {
    unsigned int numberOfInlets = zg_get_num_inlets(objectLabel);
    unsigned int numberOfOutlets = zg_get_num_outlets(objectLabel);
    NSLog(@"numOfInlets: %u", numberOfInlets);
    NSLog(@"numOfOutlet: %u", numberOfOutlets);
    for (int i = 1; i == numberOfInlets; i++) {
      [self drawInlet:NSMakeRect((i * 20), 0, 5, 3)];
    }
    for (int i = 1; i == numberOfOutlets; i++) {
      [self drawOutlet:NSMakeRect((i * 10), 25, 5, 3)];
    }
    [self drawInlet:NSMakeRect(3, 0, 50, 3)];
    objectBackgroundColour = [NSColor blueColor];
  }
  else {
    objectBackgroundColour = [NSColor redColor];
  }
}

- (BOOL)isObjectInstantiated {
  return isObjectInstantiated;
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
  
  if ([self.superview isEditModeOn]) {
    
  }
  
  [self.superview setObjectFrameOrigin];
  [textView setEditable:YES];
  [textView setSelectable:YES];
  [textView selectLine:self];
}


#pragma mark - Textfield Behaviour 

- (void)textDidBeginEditing:(NSNotification *)obj {

  //objectBackgroundColour = [NSColor redColor];
  //isObjectInstantiated = NO;
  
}

- (void)textDidChange:(NSNotification *)aNotification {
  [textView sizeToFit];
  [self setFrame:NSMakeRect([self frame].origin.x,
                            [self frame].origin.y,
                            [textView frame].size.width + 4, 
                            self.frame.size.height)];
}

- (void)textDidEndEditing:(NSNotification *)obj {
  [[textView window] makeFirstResponder:[self superview]];
  
  zgObject = [self.superview instantiateZgObject:[textView string]
      atLocation:[self frame].origin];
  
  [self instantiateObject:zgObject];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
  return YES;
}

#pragma mark - Overrides

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (BOOL)isFlipped {
  return YES;
}

- (void)dealloc {
  
  [textView release];
  [super dealloc];
}


@end
