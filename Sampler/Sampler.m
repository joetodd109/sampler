//
//  Sampler.m
//  Sampler
//
//  Created by Joe Todd on 31/08/2015.
//  Copyright (c) 2015 Joe Todd. All rights reserved.
//
#import "Sampler.h"


@implementation Sampler

MIDIClientRef midiClient;
MIDIPortRef inputPort;
MIDIObjectRef endPoint;
MIDIObjectType foundObj;
//MIDIUniqueID uniqueID = -1669486234;  // edirol
MIDIUniqueID uniqueID = -440497731;  // touchpad

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

/*
 * MIDI note callback.
 */
static void
midiInputCallback (const MIDIPacketList *list, void *procRef, void *srcRef)
{
    const MIDIPacket *packet = &list->packet[0];
    NSLog(@"note = %d, velocity = %d", packet->data[1], packet->data[2]);
    
    NSString *drumString;
    NSUInteger length = [samples count];
    if (length > 30) {
        [samples removeObjectAtIndex:0];
    }
    //float volume = packet->data[2] / 128.0;
    
    switch (packet->data[1]) {
        case 36:
            drumString = @"Kick";
            break;
        case 38:
            drumString = @"Snare";
            break;
        case 48:
            drumString = @"Tom";
            break;
        case 45:
            drumString = @"Floor";
            break;
        case 46:
            drumString = @"HiHat";
            break;
        case 49:
            drumString = @"Crash";
            break;
        default:
            NSLog(@"MIDI message not recognised");
            break;
            return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"drumClick" object:drumString];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"drumHit" object:drumString];
}

/*
 * Play Drum Sample
 */
-(void)
playSample:(NSString *) drum amplitude:(float) volume
{
    AVAudioPlayer *sample;
    NSUInteger length = [samples count];
    
    // remove old samples from buffer
    if (length > 30) {
        [samples removeObjectAtIndex:0];
    }
    
    // add sample data to buffer
    if ([drum isEqualToString:@"Kick"]) {
        sample = [[AVAudioPlayer alloc] initWithContentsOfURL:kickURL error:nil];
        [samples addObject:sample];
    }
    else if ([drum isEqualToString:@"Snare"]) {
            sample = [[AVAudioPlayer alloc] initWithContentsOfURL:snareURL error:nil];
            [samples addObject:sample];
    }
    else if ([drum isEqualToString:@"Tom"]) {
        sample = [[AVAudioPlayer alloc] initWithContentsOfURL:midTomURL error:nil];
        [samples addObject:sample];
    }
    else if ([drum isEqualToString:@"Floor"]) {
        sample = [[AVAudioPlayer alloc] initWithContentsOfURL:lowTomURL error:nil];
        [samples addObject:sample];
    }
    else if ([drum isEqualToString:@"HiHat"]) {
        sample = [[AVAudioPlayer alloc] initWithContentsOfURL:hiHatOpenURL error:nil];
        [samples addObject:sample];
    }
    else if ([drum isEqualToString:@"Crash"]) {
        sample = [[AVAudioPlayer alloc] initWithContentsOfURL:loCrashURL error:nil];
        [samples addObject:sample];
    }
    else {
        NSLog(@"MIDI message not recognised");
        return;
    }
    
    [sample setVolume:volume];
    [sample prepareToPlay];
    [sample play];
    //[sample release];
}

/*
 * Initialise MIDI Client.
 */
-(void)
setupMIDI
{
    NSLog(@"Creating MIDI client");
    result = MIDIClientCreate(CFSTR("MIDI Client"), NULL, NULL, &midiClient);
    if (result != noErr) {
        NSLog(@"Error creating MIDI client");
        return;
    }
    result = MIDIInputPortCreate(midiClient, CFSTR("Input"), midiInputCallback, NULL, &inputPort);
    if (result != noErr) {
        NSLog(@"Error creating MIDI input port");
        return;
    }
    result = MIDIObjectFindByUniqueID(uniqueID, &endPoint, &foundObj);
    if (result != noErr) {
        NSLog(@"Error finding MIDI object with uniqueID");
        return;
    }
    result = MIDIPortConnectSource(inputPort, endPoint, NULL);
    if (result != noErr) {
        NSLog(@"Error connecting MIDI to source");
        return;
    }
    
    // load samples on initialisation or else crash
    AVAudioPlayer *kick = [[AVAudioPlayer alloc] initWithContentsOfURL:kickURL error:nil];
    AVAudioPlayer *snare = [[AVAudioPlayer alloc] initWithContentsOfURL:snareURL error:nil];
    AVAudioPlayer *tom = [[AVAudioPlayer alloc] initWithContentsOfURL:midTomURL error:nil];
    AVAudioPlayer *floor = [[AVAudioPlayer alloc] initWithContentsOfURL:lowTomURL error:nil];
    AVAudioPlayer *hhOpen = [[AVAudioPlayer alloc] initWithContentsOfURL:hiHatOpenURL error:nil];
    AVAudioPlayer *hhClosed = [[AVAudioPlayer alloc] initWithContentsOfURL:hiHatClosedURL error:nil];
    AVAudioPlayer *loCrash = [[AVAudioPlayer alloc] initWithContentsOfURL:loCrashURL error:nil];
    AVAudioPlayer *hiCrash = [[AVAudioPlayer alloc] initWithContentsOfURL:hiCrashURL error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickCallback:) name:@"drumClick" object:nil];
}

/*
 * Drum Click Event Handler.
 */
-(void)
clickCallback:(NSNotification *)callback
{
    NSString *drum = callback.object;
    [self playSample:drum amplitude:0.78f];
}

/*
 * Loads drum samples from selected directory.
 * Base directory ~/Music/Samples
 */
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


