//
//  ViewController.m
//  Sampler
//
//  Created by Joe Todd on 01/09/2015.
//  Copyright (c) 2015 Joe Todd. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

NSInteger idx;
NSInteger len;
NSArray *folders;

-(void)
viewDidLoad
{
    [super viewDidLoad];
    
    idx = 0;
    NSString *directory = @"/Music/Samples";
    NSString *path = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), directory];
    
    folders = [self arrayOfFoldersInFolder:path];
    len = [folders count];
    [_pathViewer setStringValue:folders[idx]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hitCallback:) name:@"drumShow" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (bpmFlash) name:@"bpmHit" object:nil];
}

-(void)
setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
}

-(void)
hitCallback:(NSNotification *)callback
{
    NSString *drum = callback.object;
    [self hitDrum:drum];
}

-(void)
hitDrum:(NSString *) drum
{
    if ([drum isEqualToString:@"Kick"]) {
        [_kickButton highlight:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_kickButton highlight:NO];
        });
    }
    else if ([drum isEqualToString:@"Snare"]) {
        [_snareButton highlight:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_snareButton highlight:NO];
        });
    }
    else if ([drum isEqualToString:@"HiHat"]) {
        [_hiHatButton highlight:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_hiHatButton highlight:NO];
        });
    }
}

-(NSArray*)
arrayOfFoldersInFolder:(NSString*) folder
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray* files = [fm directoryContentsAtPath:folder];
    NSMutableArray *directoryList = [NSMutableArray arrayWithCapacity:10];
    
    for(NSString *file in files) {
        NSString *path = [folder stringByAppendingPathComponent:file];
        BOOL isDir = NO;
        [fm fileExistsAtPath:path isDirectory:(&isDir)];
        if(isDir) {
            [directoryList addObject:file];
        }
    }
    
    return directoryList;
}

-(void)
bpmFlash
{
    [_bpmButton highlight:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_bpmButton highlight:NO];
    });
}

- (IBAction)goBack:(id)sender {
    idx = (idx - 1) % len;
}

- (IBAction)goNext:(id)sender {
    idx = (idx + 1) % len;
}

- (IBAction)bpmChange:(id)sender {
    int bpm = [_bpmSlider intValue];
    NSString* bpmString = [NSString stringWithFormat:@"%i", bpm];
    [_bpmLabel setStringValue: bpmString];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTimer" object:bpmString];
}

- (IBAction)setLoop:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setLoop" object:nil];
}

- (IBAction)playStop:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playStop" object:nil];
}

- (IBAction)clearTrack:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clearTrack" object:nil];
}


- (IBAction)kickPush:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addEvent" object:@"Kick"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"drumPlay" object:@"Kick"];
}

- (IBAction)snarePush:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addEvent" object:@"Snare"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"drumPlay" object:@"Snare"];
}

- (IBAction)hiHatPush:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addEvent" object:@"HiHat"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"drumPlay" object:@"HiHat"];
}

@end
