//
//  Sampler.m
//  Sampler
//
//  Created by Joe Todd on 31/08/2015.
//  Copyright (c) 2015 Joe Todd. All rights reserved.
//
#import "Sampler.h"

#define KICK    36
#define SNARE   38
#define TOM     48
#define FLOOR   45
#define HIHAT   46
#define CRASH   49

@implementation Sampler

MIDIClientRef midiClient;
MIDIPortRef inputPort;
MIDIObjectRef endPoint;
MIDIEndpointRef loopEndpoint;
MIDIObjectType foundObj;
//MIDIUniqueID uniqueID = -1669486234;  // edirol
MIDIUniqueID uniqueID = -440497731;  // touchpad

NSString *myDeviceName = @"EDIROL FA-66";
MIDIDeviceRef myDevice = 0;

NSURL *kickURL;
NSURL *snareURL;
NSURL *midTomURL;
NSURL *lowTomURL;
NSURL *hiHatOpenURL;
NSURL *hiHatClosedURL;
NSURL *loCrashURL;
NSURL *hiCrashURL;

bool looping;
bool playing;
UInt32 beats;
NSTimer *bpmTimer;
NSMutableArray *samples;

UInt32 events;
MusicSequence musicSequence;
MusicTrack tempoTrack;
MusicTrack musicTrack;
MusicPlayer musicPlayer;
MusicEventIterator eventIterator;

/*
 * MIDI event callback.
 */
static void
midiInputCallback (const MIDIPacketList *list, void *procRef, void *srcRef)
{
    NSString *drumString;
    const MIDIPacket *packet = &list->packet[0];
    uint8_t command = packet->data[0];
    //float volume = packet->data[2] / 128.0;
    //NSLog(@"note = %d, velocity = %d", packet->data[1], packet->data[2]);
    
    if ((command & 240) == 144)  {
        NSUInteger length = [samples count];
        if (length > 30) {
            [samples removeObjectAtIndex:0];
        }
        
        switch (packet->data[1]) {
            case KICK:
                drumString = @"Kick";
                break;
            case SNARE:
                drumString = @"Snare";
                break;
            case TOM:
                drumString = @"Tom";
                break;
            case FLOOR:
                drumString = @"Floor";
                break;
            case HIHAT:
                drumString = @"HiHat";
                break;
            case CRASH:
                drumString = @"Crash";
                break;
            default:
                NSLog(@"MIDI message not recognised");
                break;
                return;
        }
        
        // Play sound
        [[NSNotificationCenter defaultCenter] postNotificationName:@"drumPlay" object:drumString];
        
        // Add MIDI event to looper
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addEvent" object:drumString];
        
        // Show drum hit
        [[NSNotificationCenter defaultCenter] postNotificationName:@"drumShow" object:drumString];
    }
}

/*
 * Looper MIDI event callback.
 */
static void
loopEventCallback (const MIDIPacketList *list, void *procRef, void *srcRef)
{
    NSString *drumString;
    const MIDIPacket *packet = &list->packet[0];
    uint8_t command = packet->data[0];
    uint8_t velocity = packet->data[2];
    //NSLog(@"note = %d, velocity = %d", packet->data[1], packet->data[2]);

    if ((command & 240) == 144) {
        // ON command
        if (velocity > 0) {
            // Don't play looped MIDI off events
            switch (packet->data[1]) {
                case KICK:
                    drumString = @"Kick";
                    break;
                case SNARE:
                    drumString = @"Snare";
                    break;
                case TOM:
                    drumString = @"Tom";
                    break;
                case FLOOR:
                    drumString = @"Floor";
                    break;
                case HIHAT:
                    drumString = @"HiHat";
                    break;
                case CRASH:
                    drumString = @"Crash";
                    break;
                default:
                    NSLog(@"MIDI message not recognised");
                    break;
                    return;
            }
            // Play sound
            [[NSNotificationCenter defaultCenter] postNotificationName:@"drumPlay" object:drumString];
            // Show drum hit
            [[NSNotificationCenter defaultCenter] postNotificationName:@"drumShow" object:drumString];
        }
    }
}

/*
 * Play Drum Sample.
 */
-(void)
playSample:(NSString *) drum amplitude:(float) volume
{
    AVAudioPlayer *sample;
    NSUInteger length = [samples count];
    //NSLog(@"Playing sound %@", drum);

    // Remove old samples from buffer
    if (length > 16) {
        [samples removeObjectAtIndex:0];
    }

    // Add sample data to buffer
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
 * Notification callback to add a 
 * MIDI event to the track.
 */
-(void)
addEventCallback:(NSNotification *)callback
{
    NSString *drum = callback.object;
    MIDINoteMessage note;

    if ([drum isEqualToString:@"Kick"]) {
        note.note = KICK;
    }
    else if ([drum isEqualToString:@"Snare"]) {
        note.note = SNARE;
    }
    else if ([drum isEqualToString:@"Tom"]) {
        note.note = TOM;
    }
    else if ([drum isEqualToString:@"Floor"]) {
        note.note = FLOOR;
    }
    else if ([drum isEqualToString:@"HiHat"]) {
        note.note = HIHAT;
    }
    else if ([drum isEqualToString:@"Crash"]) {
        note.note = CRASH;
    }
    else {
        NSLog(@"MIDI message not recognised");
        return;
    }

    note.channel = 1;
    note.velocity = 100;
    note.duration = 1.0;
    
    MusicTimeStamp currentTime;
    if (MusicPlayerGetTime(musicPlayer, &currentTime) == noErr) {
        while (currentTime > 16.0) {
            currentTime -= 16.0;
        }
        if (MusicTrackNewMIDINoteEvent(musicTrack, currentTime, &note) != noErr) {
            NSLog(@"Error adding note to track.");
        }
        else {
            NSLog(@"Added MIDI event at %f", currentTime);
            events++;
        }
    }
    else {
        NSLog(@"Error getting player timestamp");
    }
}

/*
 * Interrupt every beat.
 */
-(void)
timerHandler: (NSTimer *) bpmtimer
{
    MusicTimeStamp currentTime;
    if (MusicPlayerGetTime(musicPlayer, &currentTime) == noErr) {
        //NSLog(@"Current time = %f" , currentTime);
        if (currentTime >= 16.0) {
            currentTime -= 16.0;
            NSLog(@"Restart from %f", currentTime);
            beats = (UInt32) currentTime;
            if (MusicPlayerSetTime(musicPlayer, currentTime) != noErr) {
                NSLog(@"Error resetting time on player");
            }
            else {
                NSLog(@"Reset player");
            }
            if (!looping) {
                if (NewMusicEventIterator(musicTrack, &eventIterator) != noErr) {
                    NSLog(@"Error creating event iterator");
                }
                else {
                    while (events > 0) {
                        MusicEventIteratorPreviousEvent(eventIterator);
                        MusicEventIteratorDeleteEvent(eventIterator);
                        events--;
                    }
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bpmHit" object:nil];
}

/* 
 * Initialise timer to 120bpm.
 */
-(void)
setupTimer
{
    beats = 0;
    float interval = 60.0 / 120.0;
    bpmTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                target:self
                                              selector:@selector(timerHandler:)userInfo:nil
                                               repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTimer:) name:@"changeTimer" object:nil];
}

/*
 * Notification callback to update 
 * timer interval on bpm change.
 */
-(void)
changeTimer:(NSNotification *)callback
{
    NSString *bpmString = callback.object;
    int bpm = bpmString.intValue;
    float interval = 60.0 / bpm;
    
    [bpmTimer invalidate];
    bpmTimer = nil;
    bpmTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                               target:self
                                              selector:@selector(timerHandler:)
                                             userInfo:nil
                                              repeats:YES];
}

/*
 * Initialise MIDI Client.
 */
-(int)
setupMIDI
{
    NSLog(@"Creating MIDI client..");

    if (MIDIClientCreate(CFSTR("MIDI Client"), NULL, NULL, &midiClient) != noErr) {
        NSLog(@"Error creating MIDI client");
        return -1;
    }
    if (MIDIInputPortCreate(midiClient, CFSTR("Input"), midiInputCallback, NULL, &inputPort) != noErr) {
        NSLog(@"Error creating MIDI input port");
        return -1;
    }
    if (MIDIObjectFindByUniqueID(uniqueID, &endPoint, &foundObj) != noErr) {
        NSLog(@"Error finding MIDI object with uniqueID");
        return -1;
    }
    if (MIDIPortConnectSource(inputPort, endPoint, NULL) != noErr) {
        NSLog(@"Error connecting MIDI to source");
        return -1;
    }
    if (MIDIDestinationCreate(midiClient, CFSTR("Looper Client"), loopEventCallback, NULL, &loopEndpoint) != noErr) {
        NSLog(@"Error creating destination endpoint");
        return -1;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playCallback:) name:@"drumPlay"
                                               object:nil];

    NSLog(@"Created MIDI Client successfully.");
    
    return 0;
}

/*
 * Initialise Music Sequencer.
 */
-(int)
setupLooper
{
    NSLog(@"Creating Looper..");

    if (NewMusicSequence(&musicSequence) != noErr) {
        NSLog(@"Error creating music sequence");
        return -1;
    }

    if (MusicSequenceGetTempoTrack(musicSequence, &tempoTrack) != noErr) {
        NSLog(@"Error getting tempo track");
        return -1;
    }

    if (MusicTrackNewExtendedTempoEvent(tempoTrack, 0.0, 120.0) != noErr) {
        NSLog(@"Error adding tempo event");
        return -1;
    }

    if (MusicSequenceNewTrack(musicSequence, &musicTrack) != noErr) {
        NSLog(@"Error creating music track.");
        return -1;
    }
    
    MusicTimeStamp trackLength = 16.0f;
    uint32 trackLengthLength = sizeof(trackLength);
    if (MusicTrackSetProperty(musicTrack, kSequenceTrackProperty_TrackLength, &trackLength, &trackLengthLength) != noErr) {
        NSLog(@"Error setting track length");
    }

    if (MusicSequenceSetMIDIEndpoint(musicSequence, loopEndpoint) != noErr) {
        NSLog(@"Error setting music track endpoint");
        return -1;
    }

/*
    // Bug 21825100: Locks out after one event
    MusicTrackLoopInfo loopInfo = { 16.0, 0 };
    if (MusicTrackSetProperty(musicTrack, kSequenceTrackProperty_LoopInfo, &loopInfo, sizeof(loopInfo)) != noErr) {
        NSLog(@"Error setting looping behaviour");
        return -1;
    }
*/

    if (NewMusicPlayer(&musicPlayer) != noErr) {
        NSLog(@"Error creating music player.");
        return -1;
    }

    if (MusicPlayerSetSequence(musicPlayer, musicSequence) != noErr) {
        NSLog(@"Cannot set sequence for music player.");
        return -1;
    }

    MusicPlayerSetTime(musicPlayer, 0.0);
    MusicPlayerPreroll(musicPlayer);

    if (MusicPlayerStart(musicPlayer) != noErr) {
        NSLog(@"Error starting music player.");
        return -1;
    }
    
    events = 0;
    playing = true;
    looping = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addEventCallback:) name:@"addEvent"
                                               object:nil];
    // Button click notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startStopPlayer:) name:@"playStop"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setToLoop:) name:@"setLoop"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearTrack:) name:@"clearTrack"
                                               object:nil];

    NSLog(@"Created Looper successfully.");
    
    return 0;
}

/*
 * Notification callback to play a sound.
 * Triggered by click or MIDI.
 */
-(void)
playCallback:(NSNotification *)callback
{
    NSString *drum = callback.object;
    [self playSample:drum amplitude:0.78f];
}

/*
 * Notification callback to play/stop player.
 */
-(void)
startStopPlayer:(NSNotification *)callback
{
    if (playing) {
        MusicPlayerStop(musicPlayer);
        playing = false;
    }
    else {
        MusicPlayerStart(musicPlayer);
        playing = true;
    }
}

/*  
 * Notification callback to set 
 * current events looping.
 */
-(void)
setToLoop:(NSNotification *)callback
{
    looping = true;
}

/*
 * Notification callback to clear all events.
 */
-(void)
clearTrack:(NSNotification *)callback
{
    MusicTimeStamp start = 0;
    MusicTimeStamp end = 16.0;
    MusicTrackClear(musicTrack, start, end);
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

    // application crashes if we don't load samples now.
    AVAudioPlayer *kick = [[AVAudioPlayer alloc] initWithContentsOfURL:kickURL error:nil];
    AVAudioPlayer *snare = [[AVAudioPlayer alloc] initWithContentsOfURL:snareURL error:nil];
    AVAudioPlayer *tom = [[AVAudioPlayer alloc] initWithContentsOfURL:midTomURL error:nil];
    AVAudioPlayer *floor = [[AVAudioPlayer alloc] initWithContentsOfURL:lowTomURL error:nil];
    AVAudioPlayer *hhOpen = [[AVAudioPlayer alloc] initWithContentsOfURL:hiHatOpenURL error:nil];
    AVAudioPlayer *hhClosed = [[AVAudioPlayer alloc] initWithContentsOfURL:hiHatClosedURL error:nil];
    AVAudioPlayer *loCrash = [[AVAudioPlayer alloc] initWithContentsOfURL:loCrashURL error:nil];
    AVAudioPlayer *hiCrash = [[AVAudioPlayer alloc] initWithContentsOfURL:hiCrashURL error:nil];
}

@end


