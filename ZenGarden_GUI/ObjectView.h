//
//  ObjectView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZenGarden.h"


@interface ObjectView : NSView <NSTextFieldDelegate> {
  
  NSTextField *textField;
  
  int currentFrameWidth;
  int currentFrameHeight;
  int defaultFrameWidth;
  int defaultFrameHeight;
  
  NSPoint updatedFrameOrigin;
  
  BOOL isObjectInstantiated;
  NSColor *ObjectBackgroundState;
  
}

-(void)drawInlet;
-(void)drawOutlet;

-(void)highlightObject;
-(BOOL)isObjectHighlighted;

@end
