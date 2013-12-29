//
//  CICHomeScreenViewController.m
//  ChariotGauge
//
//  Created by Mike on 12/22/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import "CICHomeScreenViewController.h"

@interface CICHomeScreenViewController ()

@end

@implementation CICHomeScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(IBAction)widebandButtonPress:(id)sender
{
    NSLog(@"wideband button press");
}

-(IBAction)boostButtonPress:(id)sender
{
    NSLog(@"boost button pressed");
}

-(IBAction)oilButtonPress:(id)sender
{
    
}

-(IBAction)tempButtonPress:(id)sender
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
