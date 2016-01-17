//
//  AppDelegate.m
//  Sampler
//
//  Created by Joe Todd on 01/09/2015.
//  Copyright (c) 2015 Joe Todd. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Sampler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

Sampler *sampler;


- (void)
applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    NSLog(@"MIDI Sampler!");
    sampler = [[Sampler alloc] init];
    [sampler loadSamples];
    [sampler setupMIDI];
    [sampler setupLooper];
    [sampler setupTimer];
    [sampler setupSerial];

}

- (void)
applicationWillTerminate:(NSNotification *)aNotification
{
    
}


@end
