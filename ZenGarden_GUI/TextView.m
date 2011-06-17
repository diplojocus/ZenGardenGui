//
//  TextView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 19/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextView.h"
#import "ObjectView.h"


@implementation TextView

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self != nil) {
    [self setFont:[NSFont fontWithName:@"Helvetica" size:self.frame.size.height - 10]];
    [self setSelectable:YES];
    [self setEditable:YES];
    [[self textContainer] setContainerSize:NSMakeSize(FLT_MAX, self.frame.size.height)];
    [self setHorizontallyResizable:YES];
    [self setVerticallyResizable:NO];
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)didChangeText {
  float newStringWidth =  [self stringWidthForResizingView:[self string]
                                                  withFont:[self font]
                                        andContainerHeight:[[self textContainer] 
                                                            containerSize].height];
  [self setFrame:NSMakeRect(self.frame.origin.x,
                            self.frame.origin.y,
                            newStringWidth,
                            self.frame.size.height)];
  [self needsDisplay];
  [(ObjectView *)self.superview needsDisplay];
}

- (float)stringWidthForResizingView:(NSString *)string
                           withFont:(NSFont *)font
                 andContainerHeight:(float)containerHeight {
  
  /** Calculates textContainer size to resize view by
   * http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/TextLayout/Tasks/StringHeight.html
   **/
  
  NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithString:string] autorelease];
  NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize: 
                                     NSMakeSize(FLT_MAX, containerHeight)] autorelease];
  NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init] autorelease];
  [layoutManager addTextContainer:textContainer];
  [textStorage addLayoutManager:layoutManager];
  [textStorage addAttribute:NSFontAttributeName value:font
                      range:NSMakeRange(0, [textStorage length])];
  [textContainer setLineFragmentPadding:0.0];
  
  (void) [layoutManager glyphRangeForTextContainer:textContainer];
  return [layoutManager usedRectForTextContainer:textContainer].size.width;
}

- (BOOL)isFieldEditor { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

- (BOOL)becomeFirstResponder { return YES; }

@end
