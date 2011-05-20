//
//  OutletView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 19/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OutletView.h"


@implementation OutletView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  
  NSBezierPath * path = [NSBezierPath bezierPathWithRect:NSMakeRect(super.frame.origin.x - 1, 
                                                                    super.frame.origin.y, 6, 4)];
  [path setLineWidth:1];
  [[NSColor whiteColor] set];
  [path fill];
  [[NSColor blackColor] set]; 
  [path stroke];
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (BOOL)isFlipped {
  return YES;
}

@end
