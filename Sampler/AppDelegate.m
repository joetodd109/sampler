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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreMIDI/CoreMIDI.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

MIDIClientRef midiClient;
MIDIPortRef inputPort;
MIDIObjectRef endPoint;
MIDIObjectType foundObj;
MIDIUniqueID uniqueID = -1669486234;  // edirol

NSString *myDeviceName = @"EDIROL FA-66";
MIDIDeviceRef myDevice = 0;

NSURL *kickURL;         // 36
NSURL *snareURL;        // 38
NSURL *midTomURL;       // 48
NSURL *lowTomURL;       // 45
NSURL *hiHatOpenURL;    // 46
NSURL *hiHatClosedURL;  // 46
NSURL *loCrashURL;      // 49
NSURL *hiCrashURL;      // 49

NSMutableArray *samples;
OSStatus result;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSLog(@"MIDI Sampler..");
    
    [self loadSamples];
    [self setupMIDI];
    
    // load samples on initialisation or else crash
    AVAudioPlayer *kick = [[AVAudioPlayer alloc] initWithContentsOfURL:kickURL error:nil];
    AVAudioPlayer *snare = [[AVAudioPlayer alloc] initWithContentsOfURL:snareURL error:nil];
    AVAudioPlayer *tom = [[AVAudioPlayer alloc] initWithContentsOfURL:midTomURL error:nil];
    AVAudioPlayer *floor = [[AVAudioPlayer alloc] initWithContentsOfURL:lowTomURL error:nil];
    AVAudioPlayer *hhOpen = [[AVAudioPlayer alloc] initWithContentsOfURL:hiHatOpenURL error:nil];
    AVAudioPlayer *hhClosed = [[AVAudioPlayer alloc] initWithContentsOfURL:hiHatClosedURL error:nil];
    AVAudioPlayer *loCrash = [[AVAudioPlayer alloc] initWithContentsOfURL:loCrashURL error:nil];
    AVAudioPlayer *hiCrash = [[AVAudioPlayer alloc] initWithContentsOfURL:hiCrashURL error:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

static void
midiInputCallback (const MIDIPacketList *list, void *procRef, void *srcRef)
{
    const MIDIPacket *packet = &list->packet[0];
    NSLog(@"note = %d, velocity = %d", packet->data[1], packet->data[2]);
    
    AVAudioPlayer *sample;
    NSString *drumString;
    NSUInteger length = [samples count];
    if (length > 30) {
        [samples removeObjectAtIndex:0];
    }
    float volume = packet->data[2] / 128.0;
    
    switch (packet->data[1]) {
        case 36:
            sample = [[AVAudioPlayer alloc] initWithContentsOfURL:kickURL error:nil];
            [samples addObject:sample];
            drumString = @"Kick";
            break;
        case 38:
            sample = [[AVAudioPlayer alloc] initWithContentsOfURL:snareURL error:nil];
            [samples addObject:sample];
            drumString = @"Snare";
            break;
        case 48:
            sample = [[AVAudioPlayer alloc] initWithContentsOfURL:midTomURL error:nil];
                [samples addObject:sample];
            drumString = @"Tom";
            break;
        case 45:
            sample = [[AVAudioPlayer alloc] initWithContentsOfURL:lowTomURL error:nil];
                [samples addObject:sample];
            drumString = @"Floor";
            break;
        case 46:
            sample = [[AVAudioPlayer alloc] initWithContentsOfURL:hiHatOpenURL error:nil];
                [samples addObject:sample];
            drumString = @"HiHat";
                break;
        case 49:
            sample = [[AVAudioPlayer alloc] initWithContentsOfURL:loCrashURL error:nil];
                [samples addObject:sample];
            drumString = @"Crash";
            break;
        default:
            NSLog(@"MIDI message not recognised");
            break;
            return;
    }

    [sample setVolume:volume];
    [sample prepareToPlay];
    [sample play];
    //[sample release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"drumHit" object:drumString];
}


-(void)
setupMIDI
{
    NSLog(@"Creating MIDI client");
    result = MIDIClientCreate(CFSTR("MIDI Client"), NULL, NULL, &midiClient);
    if (result != noErr) {
        NSLog(@"Error creating MIDI client: %s - %s",
              GetMacOSStatusErrorString(result),
              GetMacOSStatusCommentString(result));
        return;
    }
    result = MIDIInputPortCreate(midiClient, CFSTR("Input"), midiInputCallback, NULL, &inputPort);
    if (result != noErr) {
        NSLog(@"Error creating MIDI input port: %s - %s",
              GetMacOSStatusErrorString(result),
              GetMacOSStatusCommentString(result));
        return;
    }
    result = MIDIObjectFindByUniqueID(uniqueID, &endPoint, &foundObj);
    if (result != noErr) {
        NSLog(@"Error finding MIDI object with uniqueID: %s - %s",
              GetMacOSStatusErrorString(result),
              GetMacOSStatusCommentString(result));
        return;
    }
    result = MIDIPortConnectSource(inputPort, endPoint, NULL);
    if (result != noErr) {
        NSLog(@"Error connecting MIDI to source: %s - %s",
              GetMacOSStatusErrorString(result),
              GetMacOSStatusCommentString(result));
        return;
    }
}

-(void)
loadSamples
{
    NSString *kickPath = [NSString stringWithFormat:@"%@/Kick.wav", [[NSBundle mainBundle] resourcePath]];
    kickURL = [NSURL fileURLWithPath:kickPath];
    
    NSString *snarePath = [NSString stringWithFormat:@"%@/Snare.wav", [[NSBundle mainBundle] resourcePath]];
    snareURL = [NSURL fileURLWithPath:snarePath];
    
    NSString *midTomPath = [NSString stringWithFormat:@"%@/Tom.wav", [[NSBundle mainBundle] resourcePath]];
    midTomURL = [NSURL fileURLWithPath:midTomPath];
    
    NSString *lowTomPath = [NSString stringWithFormat:@"%@/Floor.wav", [[NSBundle mainBundle] resourcePath]];
    lowTomURL = [NSURL fileURLWithPath:lowTomPath];
    
    NSString *hiHatOpenPath = [NSString stringWithFormat:@"%@/HiHatOpen.wav", [[NSBundle mainBundle] resourcePath]];
    hiHatOpenURL = [NSURL fileURLWithPath:hiHatOpenPath];
    
    NSString *hiHatClosedPath = [NSString stringWithFormat:@"%@/HiHatClosed.wav", [[NSBundle mainBundle] resourcePath]];
    hiHatClosedURL = [NSURL fileURLWithPath:hiHatClosedPath];
    
    NSString *loCrashPath = [NSString stringWithFormat:@"%@/LoCrash.wav", [[NSBundle mainBundle] resourcePath]];
    loCrashURL = [NSURL fileURLWithPath:loCrashPath];
    
    NSString *hiCrashPath = [NSString stringWithFormat:@"%@/HiCrash.wav", [[NSBundle mainBundle] resourcePath]];
    hiCrashURL = [NSURL fileURLWithPath:hiCrashPath];
}


@end
