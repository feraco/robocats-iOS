//
//  ViewController.m
//  AugmentedReality
//
//  Created by Sergey Koval on 19/07/16.
//  Copyright © 2016 Sergey Koval. All rights reserved.
//

#import "FF_gpsar.h"
#import <CoreLocation/CoreLocation.h>
#import "UIImage+animatedGIF.h"
#import "UIImageView+WebCache.h"
#import "Scene.h"

@interface FF_gpsar () <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *myLocation;
    NSArray *locationsAR;
    BOOL shouldStartAR;
    double minimumShowDistance;
}

@end

@implementation FF_gpsar

- (void)viewDidLoad {
    [BT_debugger showIt:self theMessage:@"viewDidLoad"];
    [super viewDidLoad];
    
    [self checkLocationServicesAndStartUpdates];
    
    selectedIndex = -1;
    
    minimumShowDistance = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"minimumShowDistance" defaultValue:@""] doubleValue];
    
    id json = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"locationsAR" defaultValue:@""];
    if ([json isKindOfClass:[NSArray class]]) {
        locationsAR = json;
    }
    
    if (!locationsAR || locationsAR.count == 0) { // this is dummy data
        NSLog(@"I HOPE THIS IS SKIPPED?");
        locationsAR = @[
                        @{@"shortText" : @"Prime: An American Kitchen & Bar",
                          @"longText" : @"Prime: An American Kitchen & Bar\nHuntington 117 New York Avenue, NY 11743\nSeafood, Steakhouse, Sushi\n(631) 385-1515",
                          @"image" : @"lighthouse2.png",
                          @"destinationId" : @"",
                          @"coordinates" : @{@"latitude" : @"40.886439", @"longitude" : @"-73.418136"}},
                        
                        @{@"shortText" : @"Little Vincent's Pizza & Restaurant",
                          @"longText" : @"Little Vincent's Pizza & Restaurant\nHuntington 329 New York Ave, Huntington, NY 11743\nItalian, Pizza\n(631) 423-9620",
                          @"image" : @"lighthouse2.png",
                          @"destinationId" : @"",
                          @"coordinates" : @{@"latitude" : @"40.870975", @"longitude" : @"-73.426444"}},
                        
                        @{@"shortText" : @"Besito",
                          @"longText" : @"Besito\nHuntington 402 New York Ave, Huntington, NY 11743\nMexican, Spanish\n(631) 549-0100",
                          @"image" : @"lighthouse2.png",
                          @"destinationId" : @"",
                          @"coordinates" : @{@"latitude" : @"40.868679", @"longitude" : @"-73.425631"}},
                        
                        @{@"shortText" : @"Oaxaca Mexican Food Treaure",
                          @"longText" : @"Oaxaca Mexican Food Treaure\nHuntington 385 New York Ave, Huntington, NY\nMexican, Southwestern\n(631) 547-1232",
                          @"image" : @"lighthouse2.png",
                          @"destinationId" : @"",
                          @"coordinates" : @{@"latitude" : @"40.869463", @"longitude" : @"-73.426355"}},
                        
                        @{@"shortText" : @"Café Buenos Aires",
                          @"longText" : @"Café Buenos Aires\nHuntington 23 Wall St, Huntington, NY 11743\nLatin American, Tapas\n(631) 603-3600",
                          @"image" : @"lighthouse2.png",
                          @"destinationId" : @"",
                          @"coordinates" : @{@"latitude" : @"40.871923", @"longitude" : @"-73.427751"}},
                        
                        @{@"shortText" : @"Swallow Huntington",
                          @"longText" : @"Swallow Huntington\n366 New York Avenue, Huntington, NY 11743\nAmerican\n(631) 547-5388",
                          @"image" : @"lighthouse2.png",
                          @"destinationId" : @"",
                          @"coordinates" : @{@"latitude" : @"40.869827", @"longitude" : @"-73.425793"}},
                        
                        @{@"shortText" : @"Brussels neigbourhood",
                          @"longText" : @"Brussels neigbourhood\nVlaams Ministerie van Onderwijs en Vorming\nonderwijs.vlaanderen.be\n02 553 17 00",
                          @"image" : @"http://onderwijs.vlaanderen.be/sites/default/files/paddle_core_plugin_data/branding/logomettekst_versie2_transparant_0.png",
                          @"destinationId" : @"A554884E601B9B36BE95D36",
                          @"coordinates" : @{@"latitude" : @"50.858656", @"longitude" : @"4.356905"}},
                        
                        @{@"shortText" : @"Antwerp neigbourhood",
                          @"longText" : @"Antwerp neigbourhood\nVlaams Ministerie van Onderwijs en Vorming\nonderwijs.vlaanderen.be\n02 553 17 00",
                          @"image" : @"http://onderwijs.vlaanderen.be/sites/default/files/paddle_core_plugin_data/branding/logomettekst_versie2_transparant_0.png",
                          @"destinationId" : @"A554884E601B9B36BE95D36",
                          @"coordinates" : @{@"latitude" : @"51.155962", @"longitude" : @"4.419108"}}
                        ];
    }
    //NSLog(@"LOCATIONS = %@", locationsAR);
    
    points = [NSMutableArray new];
    for (NSDictionary *item in locationsAR) {
        double lat = [item[@"latitude"] doubleValue];
        double lon = [item[@"longitude"] doubleValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        ARGeoCoordinate *loc = [ARGeoCoordinate coordinateWithLocation:location];
        NSString *text = (NSString*)item[@"shortText"];
        loc.dataObject = text;
        [points addObject:loc];
    }
    shouldStartAR = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self validateAR];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    shouldStartAR = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)checkLocationServicesAndStartUpdates {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    //Checking authorization status
    if (![CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Location Services Disabled!"
                                     message:@"Please enable Location Based Services for better results! We promise to keep your location private"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *settings;
        if (![CLLocationManager locationServicesEnabled]) {
            settings = [UIAlertAction
                        actionWithTitle:@"Settings"
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
                        }];
        }
        else {
            settings = [UIAlertAction
                        actionWithTitle:@"Settings"
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }];
        }
        
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                                 handler:nil];
        
        [alert addAction:settings];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    else {
        //Location Services Enabled, let's start location updates
        [locationManager startUpdatingLocation];
    }
}

-(void)validateAR {
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (hasCamera) {
        if (shouldStartAR) {
            [self showAR];
        }
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"No Camera Detected!" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
    }
}

- (void)showAR {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    ARKitConfig *config = [ARKitConfig defaultConfigFor:self];
    config.orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGSize s = [UIScreen mainScreen].bounds.size;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        config.radarPoint = CGPointMake(s.width - 50, s.height - 50);
    } else {
        config.radarPoint = CGPointMake(s.height - 50, s.width - 50);
    }
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"cancel_filled"] forState:UIControlStateNormal];
    [closeBtn sizeToFit];
    closeBtn.showsTouchWhenHighlighted = YES;
    [closeBtn addTarget:self action:@selector(closeAR) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.center = CGPointMake(30, 30);
    
    UIImageView *overlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"monoview_holed.png"]];
    overlay.frame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height);
    overlay.contentMode = UIViewContentModeScaleAspectFill;
    
    engine = [[ARKitEngine alloc] initWithConfig:config];
    
    [engine addExtraView:overlay];
    
    Scene *scene3D = [[Scene alloc] initWithFrame:self.view.bounds];
    [engine addExtraView:scene3D];
    
    //[engine addCoordinates:points];
    [engine addExtraView:closeBtn];
    
    [engine startListening];
}

- (void)closeAR {
    [engine hide];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Location methods

-(double)distanceFrom:(CLLocation*)location {
    CLLocationDistance meters = [location distanceFromLocation:myLocation];
    return meters;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    myLocation = locations.lastObject;
    NSLog(@"LOCATION = %@", myLocation);
    [engine addCoordinates:points];
    //[self validateAR];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Failed to get location!" message:@"You will still see your location." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
    //[self validateAR];
}

#pragma mark - ARViewDelegate

- (ARObjectView *)viewForCoordinate:(ARGeoCoordinate *)coordinate floorLooking:(BOOL)floorLooking {
    NSString *shortText = (NSString *)coordinate.dataObject;
    
    ARObjectView *view = nil;
    
    if (floorLooking) {
        UIImage *arrowImg = [UIImage imageNamed:@"arrow.png"];
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:arrowImg];
        view = [[ARObjectView alloc] initWithFrame:arrowView.bounds];
        [view addSubview:arrowView];
        view.displayed = NO;
    } else {
        CGFloat width = self.view.bounds.size.width;
        
        double maxRatio = 2.0;
        double ratio = 0;
        double changeDistance = minimumShowDistance;
        NSLog(@"MINIMUM DISTANCE = %f meters", minimumShowDistance);
        double distance = 0.0;
        if (myLocation) {
            distance = [self distanceFrom:coordinate.geoLocation];
            NSLog(@"DISTANCE = %f meters", distance);
        }
        
        if (distance < changeDistance) {
            ratio = distance/changeDistance;
            width = self.view.bounds.size.width*maxRatio/ratio;
            if (width >= self.view.bounds.size.width*maxRatio) {
                width = self.view.bounds.size.width*maxRatio;
            }
        }
        
        NSLog(@"WIDTH = %f", width);
        CGRect frame = CGRectMake(0, 0, width, width);
        UIView *container = [[UIView alloc] initWithFrame:frame];
        container.backgroundColor = [UIColor clearColor];
        
        CGRect labelFrame = CGRectMake(0, container.frame.size.height/4, container.frame.size.width/2, container.frame.size.height/4);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.font = [UIFont systemFontOfSize:12];
        [label setMinimumScaleFactor:2.0/[UIFont labelFontSize]];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor orangeColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = shortText;
        label.numberOfLines = 0;
        
        if (width > self.view.bounds.size.width) {
            [container addSubview:label];
        }
        
        // ==============================================================
        
        // GIF file load
        /*
         CGRect imageFrame = CGRectMake(0, 0, container.frame.size.width/2, container.frame.size.height/4);
         UIImageView *dataImageView = [[UIImageView alloc] initWithFrame:imageFrame];
         NSURL *url = [[NSBundle mainBundle] URLForResource:@"lighthouse_animated" withExtension:@"gif"];
         dataImageView.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
         dataImageView.contentMode = UIViewContentModeScaleAspectFit;
         dataImageView.backgroundColor = [UIColor whiteColor];
         dataImageView.layer.cornerRadius = 20;
         [container addSubview:dataImageView];
         */
        
        
        // PNG file load
        CGRect imageFrame = CGRectMake(0, 0, container.frame.size.width/2, container.frame.size.height/4);
        UIImageView *dataImageView = [[UIImageView alloc] initWithFrame:imageFrame];
        
        NSString *imageName = @"lighthouse2.png";
        for (NSDictionary *item in locationsAR) {
            if ([item[@"shortText"] isEqualToString:shortText]) {
                imageName = item[@"image"];
                break;
            }
        }
        
        dataImageView = [self imageForName:imageName];
        dataImageView.frame = imageFrame;
        dataImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        if (width > self.view.bounds.size.width) {
            [container addSubview:dataImageView];
        }
        
        // 3D file load
        //Scene *scene3D = [[Scene alloc] initWithFrame:self.view.bounds];
        //[container addSubview:scene3D];
        
        // ==============================================================
        
        view = [[ARObjectView alloc] initWithFrame:container.frame];
        [view addSubview:container];
    }
    
    [view sizeToFit];
    return view;
}

-(UIImageView*)imageForName:(NSString*)name {
    
    UIImageView *imageView = [UIImageView new];
    if ([name hasPrefix:@"http"]) {
        if (name.length > 10) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:name]];
        } else {
            imageView.image = [UIImage imageNamed:@"placeholder"];
        }
    }
    else {
        imageView.image = [UIImage imageNamed:name];
    }
    return imageView;
}

- (void) itemTouchedWithIndex:(NSInteger)index {
    selectedIndex = index;
    
    currentDetailView = [[NSBundle mainBundle] loadNibNamed:@"ARDetailView" owner:nil options:nil][0];
    currentDetailView.delegate = self;
    
    NSDictionary *item = locationsAR[index];
    currentDetailView.nameLbl.text = item[@"longText"];
    
    NSString *name = item[@"image"];
    if ([name hasPrefix:@"http"]) {
        if (name.length > 10) {
            [currentDetailView.imageView sd_setImageWithURL:[NSURL URLWithString:name]];
        } else {
            currentDetailView.imageView.image = [UIImage imageNamed:@"placeholder"];
        }
    }
    else {
        currentDetailView.imageView.image = [UIImage imageNamed:name];
    }
    
    currentDetailView.button.enabled = ![item[@"destinationId"] isEqualToString:@""] ? YES : NO;
    [engine addExtraView:currentDetailView];
}

- (void) didChangeLooking:(BOOL)floorLooking {
    if (floorLooking) {
        if (selectedIndex != -1) {
            [currentDetailView removeFromSuperview];
            ARObjectView *floorView = [engine floorViewWithIndex:selectedIndex];
            floorView.displayed = YES;
        }
    } else {
        if (selectedIndex != -1) {
            ARObjectView *floorView = [engine floorViewWithIndex:selectedIndex];
            floorView.displayed = NO;
            selectedIndex = -1;
        }
    }
}

-(void)didCloseARDetailView {
    NSDictionary *item = locationsAR[selectedIndex];
    if (![item[@"destinationId"] isEqualToString:@""]) {
        [engine hide];
        [self loadScreenWithItemId:item[@"destinationId"]];
        shouldStartAR = NO;
        engine = nil;
    }
}

@end
