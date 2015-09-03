//
//  ViewController.m
//  Sampler
//
//  Created by Joe Todd on 01/09/2015.
//  Copyright (c) 2015 Joe Todd. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize kick;
@synthesize kickOn;

-(void)
viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [kickOn setHidden:true];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(hitCallback:) name:@"drumHit" object:nil];
}

-(void)
setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(void)dealloc
{
    //clean up in case viewDidUnload wasn't called (it sometimes isn't)
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

-(void)
hitCallback:(NSNotification *)callback
{
    NSString *drum = callback.object;
    
    [self showDrum:drum];
    
    //[self performSelector:@selector(hideDrum) withObject:self afterDelay: 0.2];
    [self hideDrum];
}

-(void)
showDrum:(NSString *) drum
{
    if ([drum isEqualToString:@"Kick"]) {
        [kick setHidden:true];
        [kickOn setHidden:false];
    }
}

-(void)
hideDrum
{
    [kick setHidden:false];
    [kickOn setHidden:true];
}

@end
