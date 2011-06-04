//
//  TextView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 19/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextView.h"


@implementation TextView

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self != nil) {
    [self setSelectable:YES];
    [self setEditable:YES];
    [self setHorizontallyResizable:YES];
    [self setVerticallyResizable:NO];
    [self setBackgroundColor:[NSColor clearColor]];
    [self setDrawsBackground:NO];
  }
  return self;
}

-(void)mouseDown:(NSEvent *)theEvent {
  [[self superview] mouseDown:theEvent];
}

- (void)dealloc {
  [super dealloc];
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (BOOL)isFieldEditor {
  return YES;
}

@end
