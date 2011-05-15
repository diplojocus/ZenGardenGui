/* 
 
 Martin Roth
 http://developer.apple.com/library/mac/#documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/Introduction/Introduction.html
 Martin Roth
 http://developer.apple.com/library/mac/#documentation/MusicAudio/Reference/AudioQueueReference/Reference/reference.html
 
*/

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <Foundation/Foundation.h>

#import "ZenGarden.h"

@interface PdAudio : NSObject {
  AudioStreamBasicDescription outAsbd;
  AudioQueueRef outAQ;
  int numOutputChannels;
  ZGContext *zgContext;
}

@property (nonatomic, readonly) ZGContext *zgContext;
@property (nonatomic, readonly) int numOutputChannels;

- (void)play;
- (void)pause;

@end
