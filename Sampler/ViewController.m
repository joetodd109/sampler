//
//  ViewController.m
//  Sampler
//
//  Created by Joe Todd on 01/09/2015.
//  Copyright (c) 2015 Joe Todd. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

-(void)
viewDidLoad
{
    [super viewDidLoad];
    
    [_kickOn setAlphaValue:0.0];
    [_snareOn setAlphaValue:0.0];
    [_tom setAlphaValue:0.0];
    [_floor setAlphaValue:0.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hitCallback:) name:@"drumHit" object:nil];
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
        [_kick setAlphaValue:0.0];
        [_kickOn setAlphaValue:1.0];
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:1.0];
        [[_kickOn animator] setAlphaValue:0.0];  // fade out
        [[_kick animator] setAlphaValue:1.0];   // fade in
        [NSAnimationContext endGrouping];
    }
    else if ([drum isEqualToString:@"Snare"]) {
        [_snare setAlphaValue:0.0];
        [_snareOn setAlphaValue:1.0];
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:1.0];
        [[_snareOn animator] setAlphaValue:0.0];  // fade out
        [[_snare animator] setAlphaValue:1.0];   // fade in
        [NSAnimationContext endGrouping];
    }
    else if ([drum isEqualToString:@"Tom"]) {
        [_tom setAlphaValue:0.0];
        [_tomOn setAlphaValue:1.0];
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:1.0];
        [[_tomOn animator] setAlphaValue:0.0];  // fade out
        [[_tom animator] setAlphaValue:1.0];   // fade in
        [NSAnimationContext endGrouping];
    }
    else if ([drum isEqualToString:@"Floor"]) {
        [_floor setAlphaValue:0.0];
        [_floorOn setAlphaValue:1.0];
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:1.0];
        [[_floorOn animator] setAlphaValue:0.0];  // fade out
        [[_floor animator] setAlphaValue:1.0];   // fade in
        [NSAnimationContext endGrouping];
    }
}

@end
