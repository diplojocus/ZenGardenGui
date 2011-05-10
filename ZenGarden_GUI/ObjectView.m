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
      // Initialization code here.
      textField = [[NSTextField alloc] initWithFrame:frame];
      [textField setDelegate:self];
      [textField setEditable:NO];
      [textField setSelectable:NO];
      [textField setBezeled:NO];
      [textField setDrawsBackground:NO];
      [self addSubview:textField]; 
      
      ObjectBackgroundState = [NSColor redColor];
      isObjectInstantiated = NO;
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect {
  
  // adjust padding for textfield
  [textField setFrame:NSMakeRect(2, 2, (rect.size.width - 4), rect.size.height - 4)];
  
  // Set default line join style
  [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
  
  // rounded corners
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect 
                                                     xRadius:6
                                                     yRadius:6];
  
  // background colour
  [[ObjectBackgroundState colorWithAlphaComponent:0.1f]set];
  [path fill];
  
  // set border width and colour
  [path setLineWidth:3];
  [ObjectBackgroundState set]; 
  
  float lineDash[4];
  
  lineDash[0] = 4.0;
  lineDash[1] = 4.0;
  lineDash[2] = 4.0;
  lineDash[3] = 4.0;
  
  [path setLineDash:lineDash count:4 phase:0.0];
  [path stroke]; 
}


// mouse behaviour

- (void)mouseDown:(NSEvent *)theEvent {
  
  [self.superview setObjectFrameOrigin];
  
  // edit text field
  [textField setEditable:YES];
  [textField setSelectable:YES];
  [textField selectText:self];
}

-(void)mouseUp:(NSEvent *)theEvent {
  
}

- (void)mouseDragged:(NSEvent *)theEvent {
  
  // move object on cmd + mouse drag
  BOOL commandKeyDown = (([[NSApp currentEvent] modifierFlags] & NSCommandKeyMask) == NSCommandKeyMask);
  if (commandKeyDown == 1) {
  
    [self setFrameOrigin:NSMakePoint([theEvent locationInWindow].x + updatedFrameOrigin.x, 
                                     [theEvent locationInWindow].y + updatedFrameOrigin.y)];
    
    NSLog(@"CMD+MOVE");
    
  }
}


// text behaviour

- (void)controlTextDidBeginEditing:(NSNotification *)obj {

    ObjectBackgroundState = [NSColor redColor];
    isObjectInstantiated = NO;
}

- (void) controlTextDidEndEditing:(NSNotification *)obj {

  // release focus
  [[self window] makeFirstResponder:self];
  
  // instantiate object
  if (isObjectInstantiated == NO) {
    
    ObjectBackgroundState = [NSColor blueColor];
    isObjectInstantiated = YES;
    
  }
  else {
    
    ObjectBackgroundState = [NSColor redColor];
    isObjectInstantiated = NO;
  }
  
  // Output Text Field value
  NSLog(@"%@", [textField stringValue]);
  
}

- (void) controlTextDidChange:(NSNotification *)obj {
  
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
  
  return YES;
}

- (BOOL)acceptsFirstResponder {
  
  return YES;
}

- (void)dealloc {
  
  [textField release];
  [super dealloc];
}


@end
