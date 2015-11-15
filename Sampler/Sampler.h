//
//  Sampler.h
//  Sampler
//
//  Created by Joe Todd on 31/08/2015.
//  Copyright (c) 2015 Joe Todd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreMIDI/CoreMIDI.h>

@interface Sampler : NSObject

-(void)playSample:(NSString *) drum amplitude:(float) volume;
-(void)loadSamples;
-(void)setupMIDI;

@end
