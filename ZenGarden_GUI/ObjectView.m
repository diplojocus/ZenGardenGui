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
      currentFrameWidth = frame.size.width;
      currentFrameHeight = frame.size.height;
      textField = [[NSTextField alloc] initWithFrame:NSMakeRect(2,
                                                                2,
                                                                (currentFrameWidth - 4),
                                                                currentFrameHeight - 4)];
      [textField setDelegate:self];
      [textField setEditable:NO];
      [textField setSelectable:NO];
      [textField setBezeled:NO];
      [textField setDrawsBackground:NO];
      [self addSubview:textField]; 
      
      stringCharSize = 10;
      
      ObjectBackgroundState = [NSColor redColor];
      isObjectInstantiated = NO;
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect {
  
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
  //[path setLineWidth:3];
  //[ObjectBackgroundState set]; 

}


// mouse behaviour

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


// text behaviour

- (void)controlTextDidBeginEditing:(NSNotification *)obj {

  ObjectBackgroundState = [NSColor redColor];
  isObjectInstantiated = NO;
  
}

-(void)controlTextDidChange:(NSNotification *)obj {
  
  NSString *textFieldValue = [textField stringValue];
  NSLog(@"string length %lu", [textFieldValue length]);
  
  currentFrameWidth = (int) (currentFrameWidth + ([textFieldValue length] * 10)); 
  [self setFrame:NSMakeRect([self frame].origin.x, [self frame].origin.y, currentFrameWidth, currentFrameHeight)];

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
