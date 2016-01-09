//
//  ViewController.h
//  Sampler
//
//  Created by Joe Todd on 01/09/2015.
//  Copyright (c) 2015 Joe Todd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@import AppKit;

@interface ViewController : NSViewController

@property (strong) IBOutlet NSButton *backButton;
@property (strong) IBOutlet NSButton *nextButton;
@property (strong) IBOutlet NSTextField *pathViewer;

@property (strong) IBOutlet NSTextField *bpmLabel;
@property (strong) IBOutlet NSSlider *bpmSlider;
@property (strong) IBOutlet NSButton *bpmButton;
@property (strong) IBOutlet NSButton *loopButton;
@property (strong) IBOutlet NSButton *stopButton;
@property (strong) IBOutlet NSButton *clearButton;

@property (strong) IBOutlet NSButton *kickButton;
@property (strong) IBOutlet NSButton *snareButton;
@property (strong) IBOutlet NSButton *hiHatButton;

@end

