//
//  HZFMapViewController.m
//  twosquare
//
//  Created by Axel Hernández Ferrera on 19/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HZFMapViewController.h"
#import "HZFCheckin.h"

@interface HZFMapViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) UIPopoverController *sharePopover;
- (void)configureView;
@end

@implementation HZFMapViewController

@synthesize mapView = _mapView, checkin;
@synthesize sharePopover;

@synthesize masterPopoverController;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated {    
    [self showCheckinAnnotation];
    [self centerMapInCheckin];
}

- (CLLocationCoordinate2D) checkinCoordinate {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.checkin.latitud;
    coordinate.longitude = self.checkin.longitud;
    return coordinate;
}

- (void)showCheckinAnnotation {
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = [self checkinCoordinate];
    annotationPoint.title = self.checkin.nombre;
    annotationPoint.subtitle = self.checkin.description;
    [self.mapView addAnnotation:annotationPoint];    
}

- (void)centerMapInCheckin {
    MKCoordinateRegion region;
    region.center = [self checkinCoordinate];
    region.span.latitudeDelta = 1;
    region.span.longitudeDelta = 1;
    
    [self.mapView setRegion:region animated:YES];    
}

- (void)viewDidUnload {
    self.checkin = nil;
    self.mapView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    MKAnnotationView *annotationView= nil; 
    if(annotation != mapView.userLocation) {
        static NSString *annotationViewId = @"annotationViewId";
        annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewId];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewId];
        }
        
        NSString *img = [NSString stringWithFormat:@"%@.png", self.checkin.categoria];
        annotationView.image = [UIImage imageNamed:img];
    }
    return annotationView;
}

- (IBAction)showMapTypeSelector:(id)sender {    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Tipo de mapa" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Standard", @"Hybrid", @"Satellite", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)showPopover:(id)sender {
    if(self.sharePopover){
        [self.sharePopover dismissPopoverAnimated:YES];
    }else{
        [self performSegueWithIdentifier:@"showPopover" sender:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destination = segue.destinationViewController;
    SEL selector = @selector(setCheckin:);
    if([destination respondsToSelector:selector]){
        [destination performSelector:selector withObject:self.checkin];
    }
    self.sharePopover = [(UIStoryboardPopoverSegue *)segue popoverController];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
            
        case 1:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
            
        case 2:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
            
        default:
            break;
    }
}

- (void)configureView {    
    if (self.checkin) {
        self.title = [self.checkin nombre];
        [self showCheckinAnnotation];
        [self centerMapInCheckin];
    }
}

- (void)setCheckin:(HZFCheckin *)newCheckin {
    if (![checkin.nombre isEqualToString:newCheckin.nombre]) {
        checkin = newCheckin;
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Checkins", @"Checkins");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
