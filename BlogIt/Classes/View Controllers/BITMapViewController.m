//
//  BITMapViewController.m
//  BlogIt
//
//  Created by Pauli Jokela on 3.2.2015.
//  Copyright (c) 2015 Didstopia. All rights reserved.
//

#import "BITMapViewController.h"

#import "BITConfig.h"

@interface BITMapViewController ()

@end

@implementation BITMapViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CLLocationCoordinate2D coord = {.latitude =  kBIT_MAP_LATITUDE, .longitude =  kBIT_MAP_LONGITUDE};
    MKCoordinateSpan span = {.latitudeDelta =  1, .longitudeDelta =  1};
    MKCoordinateRegion region = {coord, span};
    [self.mapView setRegion:region];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
