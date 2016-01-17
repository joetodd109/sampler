//
//  Sampler.h
//  Sampler
//
//  Created by Joe Todd on 31/08/2015.
//  Copyright (c) 2015 Joe Todd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <ORSSerial/ORSSerial.h>

@interface Sampler : NSObject

-(void)playSample:(NSString *) drum amplitude:(float) volume;
-(void)loadSamples;
-(void)setupTimer;
-(int)setupMIDI;
-(int)setupLooper;
-(void)setupSerial;

@property (nonatomic, strong) ORSSerialPort *serialPort;

@end
