/*
 *	Copyright 2014, Barry Jones
 *
 *	All rights reserved.
 *
 *  Based on the Splash Screen plugin written by David Book.
 *
 *	Redistribution and use in source and binary forms, with or without modification, are
 *	permitted provided that the following conditions are met:
 *
 *	Redistributions of source code must retain the above copyright notice which includes the
 *	name(s) of the copyright holders. It must also retain this list of conditions and the 
 *	following disclaimer. 
 *
 *	Redistributions in binary form must reproduce the above copyright notice, this list 
 *	of conditions and the following disclaimer in the documentation and/or other materials 
 *	provided with the distribution. 
 *
 *	Neither the name of David Book, or buzztouch.com nor the names of its contributors 
 *	may be used to endorse or promote products derived from this software without specific 
 *	prior written permission.
 *
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 *	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 *	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
 *	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 *	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 *	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
 *	OF SUCH DAMAGE. 
 */


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JSON.h"
#import "robocats_appDelegate.h"
#import "BT_fileManager.h"
#import "BT_color.h"
#import "BT_viewUtilities.h"
#import "BT_strings.h"
#import "BT_downloader.h"
#import "BT_item.h"
#import "BT_debugger.h"

#import "RD_simpleFence.h"



// *************************

@interface RD_simpleFence () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

// *************************




@implementation RD_simpleFence
@synthesize backgroundImageView, backgroundImage, transitionType;
@synthesize imageName, imageURL, startTransitionAfterSeconds, transitionDurationSeconds;




// *************************

@synthesize theParentMenuScreenData, url, tmpLatitude, tmpLongitude, itemId, regionRadius;

// *************************



//viewDidLoad
-(void)viewDidLoad{
    [BT_debugger showIt:self theMessage:@"viewDidLoad"];
    [super viewDidLoad];
    //	[self downloadData];
    
    //appDelegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    // *************************
    if ([appDelegate.rootLocationMonitor.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        
        [appDelegate.rootLocationMonitor.locationManager requestAlwaysAuthorization];
    
    
    
    
    
    //iOS8 handles register for push differently...
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        //use registerUserNotificationSettings
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        
    } else {
        
        //prior to iOS8, use registerForRemoteNotificationTypes...
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
        
    }
    
    
    // *************************
    
    
    
    
    //transition properties
    startTransitionAfterSeconds = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"startTransitionAfterSeconds" defaultValue:@"1"] doubleValue];
    transitionDurationSeconds = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"transitionDurationSeconds" defaultValue:@"1"] doubleValue];
    transitionType = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"transitionType" defaultValue:@"fade"];
    
    
    //////////////////////////////////////////////////////////////
    // 1) Add a full-size sub-view to hold a possible solid color
    //solid background color
    
    //solid background properties..
    UIColor *solidBgColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"backgroundColor"  defaultValue:@"#000000"]];
    NSString *solidBgOpacity = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"backgroundColorOpacity"  defaultValue:@"100"];
    if([solidBgOpacity isEqualToString:@"100"]) solidBgOpacity = @"99";
    solidBgOpacity = [NSString stringWithFormat:@".%@", solidBgOpacity];
    
    //sub-view for background color
    UIView *bgColorView;
    if([appDelegate.rootDevice isIPad]){
        bgColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1500, 1500)];
    }else{
        bgColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    }
    [bgColorView setAlpha:[solidBgOpacity doubleValue]];
    [bgColorView setBackgroundColor:solidBgColor];
    
    //add view
    [self.view addSubview:bgColorView];
    
    //////////////////////////////////////////////////////////////
    // 2) Add a full-size sub-view to hold a possible gradient background
    //gradient background color goes "on top" of solid background color
    
    UIColor *gradBgColorTop = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"backgroundColorGradientTop"  defaultValue:@"clear"]];
    UIColor *gradBgColorBottom = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"backgroundColorGradientBottom"  defaultValue:@"clear"]];
    
    //sub-view for gradient background color
    UIView *bgGradientView;
    if([appDelegate.rootDevice isIPad]){
        bgGradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1500, 1500)];
    }else{
        bgGradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    }
    
    //apply gradient
    bgGradientView = [BT_viewUtilities applyGradient:bgGradientView colorTop:gradBgColorTop colorBottom:gradBgColorBottom];
    bgGradientView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    //add view
    [self.view addSubview:bgGradientView];
    
    
    //////////////////////////////////////////////////////////////
    // 3) Add a full-size image-view to hold the background image
    
    self.imageName = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageNameSmallDevice" defaultValue:@""];
    self.imageURL = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageURLSmallDevice" defaultValue:@""];
    if([appDelegate.rootDevice isIPad]){
        self.imageName = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageNameLargeDevice" defaultValue:@""];
        self.imageURL = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageURLLargeDevice" defaultValue:@""];
    }
    
    
    //init the image view
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.backgroundImageView setContentMode:UIViewContentModeCenter];
    self.backgroundImageView. autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.backgroundImageView];
    
    //set the image's opacity
    NSString *imageBgOpacity = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"backgroundImageOpacity" defaultValue:@"100"];
    if([imageBgOpacity isEqualToString:@"100"]) imageBgOpacity = @"99";
    imageBgOpacity = [NSString stringWithFormat:@".%@", imageBgOpacity];
    [self.backgroundImageView setAlpha:[imageBgOpacity doubleValue]];
    
    
    //if we have an imageURL, and no imageName, figure out a name to use...
    if(self.imageName.length < 3 && self.imageURL.length > 3){
        self.imageName = [BT_strings getFileNameFromURL:self.imageURL];
    }
    
    //get the image
    if([self.imageName length] > 1){
        
        if([BT_fileManager doesFileExistInBundle:imageName]){
            
            [BT_debugger showIt:self theMessage:@"Image for splash-screen exists in bundle - not downloading."];
            self.backgroundImage = [UIImage imageNamed:self.imageName];
            [self setImage:self.backgroundImage];
            
        }else{
            
            if([BT_fileManager doesLocalFileExist:imageName]){
                
                [BT_debugger showIt:self theMessage:@"Image for splash-screen exists in cache - not downloading."];
                self.backgroundImage = [BT_fileManager getImageFromFile:imageName];
                [self setImage:self.backgroundImage];
                
            }else{
                
                //only do this if we have an image URL
                if([self.imageURL length] > 3 && [self.imageName length] > 3){
                    
                    [BT_debugger showIt:self theMessage:@"Image for splash-screen does not exist in cache - downloading."];
                    [self performSelector:@selector(downloadImage) withObject:nil afterDelay:.5];
                    
                }else{
                    
                    [BT_debugger showIt:self theMessage:@"No image name and no image URL provided for splash screen."];
                    
                    //make sure we have animation setting
                    if(startTransitionAfterSeconds > -1){
                        [self animateSplashScreen];
                    }
                    
                }
            }
            
        }
        
        
    }else{
        
        
        //remove screen after X seconds if we have a startTransitionAfterSeconds
        if(startTransitionAfterSeconds > -1){
            [self performSelector:@selector(animateSplashScreen) withObject:nil afterDelay:startTransitionAfterSeconds];
        }
        
    }//imageName
    
    
    //if startTransitionAfterSeconds == -1 then we need a button to tap to trigger the animation
    if(startTransitionAfterSeconds < 0){
        
        [BT_debugger showIt:self theMessage:@"Splash screen will not animate automatically, user must tap screen (begin transition seconds = -1)."];
        UIButton *coverButton = [[UIButton alloc] init];
        coverButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [coverButton setFrame:CGRectMake(0, 0, 1500, 1500)];
        coverButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleRightMargin;
        [coverButton addTarget:self action:@selector(animateSplashScreen) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:coverButton];
        
    }
    
    
}

//view will appear
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [BT_debugger showIt:self theMessage:@"viewWillAppear"];
    
    //flag this as the current screen
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.rootApp.currentScreenData = self.screenData;
    
    
    
    
    
    // *********************************
    
    [self initializeLocationManager];
    
    // *********************************
    
    
    
    
}


//do animatino then set delay to remove itself
-(void)animateSplashScreen{
    [BT_debugger showIt:self theMessage:@"animating splash screen"];
    
    //setup animation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeSplashScreen)];
    
    //shrink
    if([transitionType rangeOfString:@"shrink" options: NSCaseInsensitiveSearch].location != NSNotFound){
        self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [UIView setAnimationDuration:transitionDurationSeconds];
        self.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    }
    //fade
    if([transitionType rangeOfString:@"fade" options: NSCaseInsensitiveSearch].location != NSNotFound){
        [self.view setAlpha:1];
        [UIView setAnimationDuration:transitionDurationSeconds];
        [self.view setAlpha:0];
    }
    //curl
    if([transitionType rangeOfString:@"curl" options: NSCaseInsensitiveSearch].location != NSNotFound){
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:[self view] cache:YES];
        [self.view setAlpha:0];
        [UIView setAnimationDuration:transitionDurationSeconds];
    }
    
    //start animation
    [UIView commitAnimations];
    
}

//unloads view from stack
-(void)removeSplashScreen{
    [self.view removeFromSuperview];
}


//downloadImage
-(void)downloadImage{
    
    //only do this if we have an image URL
    if([self.imageURL length] > 3 && [self.imageName length] > 3){
        
        [BT_debugger showIt:self theMessage:@"downloadImage"];
        
        //start download
        BT_downloader *tmpDownloader = [[BT_downloader alloc] init];
        [tmpDownloader setUrlString:imageURL];
        [tmpDownloader setSaveAsFileName:imageName];
        [tmpDownloader setSaveAsFileType:@"image"];
        [tmpDownloader setDelegate:self];
        [tmpDownloader downloadFile];
        
        //clean up
        tmpDownloader = nil;
        
    }
}



//set image
-(void)setImage:(UIImage *)theImage{
    [BT_debugger showIt:self theMessage:@"setImage"];
    
    if(theImage && self.backgroundImageView){
        [self.backgroundImageView setImage:theImage];
    }
    
    //animate splash..
    if(startTransitionAfterSeconds > -1){
        [self performSelector:@selector(animateSplashScreen) withObject:nil afterDelay:startTransitionAfterSeconds];
    }
    
}

//////////////////////////////////////////////////////////////
//downloader delegate methods
-(void)downloadFileStarted:(NSString *)message{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"downloadFileStarted: %@", message]];
}
-(void)downloadFileInProgress:(NSString *)message{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"downloadFileInProgress: %@", message]];
    if(self.progressView != nil){
        UILabel *tmpLabel = (UILabel *)[self.progressView.subviews objectAtIndex:2];
        [tmpLabel setText:message];
    }
}
-(void)downloadFileCompleted:(NSString *)message{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"downloadFileCompleted: %@", message]];
    
    //set image we just downloaded and saved.
    if([BT_fileManager doesLocalFileExist:imageName]){
        self.backgroundImage = [BT_fileManager getImageFromFile:imageName];
    }else{
        self.backgroundImage = [UIImage imageNamed:@"blank.png"];
    }
    
    //set image
    [self setImage:self.backgroundImage];
    
}

// ******************** start *****************

// Ask user to allow location services
- (void)initializeLocationManager
{
    
    if(![CLLocationManager locationServicesEnabled]) {
        // handle loc services disabled
        return;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    [self initializeRegionMonitoring:[self buildGeofenceData]];
}

// Start collecting Geofence Data
- (NSArray*)buildGeofenceData


{
    NSMutableArray *geofences = [NSMutableArray array];
    
    return [NSArray arrayWithArray:geofences];
    
    
}


// Check to ensure location services are enabled
- (void) initializeRegionMonitoring:(NSArray*)geofences

{
    if(![CLLocationManager locationServicesEnabled]) {
        // handle this
        return;
        //   }
        
        if (self.locationManager == nil) {
            [NSException raise:@"Location Manager Not Initialized" format:@"You must initialize location manager first."];
        }
        
        if(![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]) {
            // handle
            return;
        }
        
        //start monitoring regions after stop previous monitoring
        for(CLRegion *geofence in geofences) {
            
            for (CLRegion *monitored in [_locationManager monitoredRegions])
                [_locationManager stopMonitoringForRegion:monitored];
            
            [_locationManager startMonitoringForRegion:geofence];
        }
    }
    
    if(![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]) {
        return;
        //- (CLRegion*)mapDictionaryToRegion:(NSDictionary*)dictionary
    }
 
    
    for (CLRegion *geofences in [_locationManager monitoredRegions])
        [_locationManager stopMonitoringForRegion:geofences];
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify1" defaultValue:@"item1"];
    

    
    CLLocationDegrees tmpLatitude1 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude1" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude1 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude1" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius1 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius1" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate1 = CLLocationCoordinate2DMake(tmpLatitude1, tmpLongitude1);
    
    
    CLRegion *geoFence1 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate1
                                                            radius:regionRadius1
                                                        identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence1];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify2" defaultValue:@"item2"];
    
   
    
    CLLocationDegrees tmpLatitude2 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude2" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude2 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude2" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius2 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius2" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate2 = CLLocationCoordinate2DMake(tmpLatitude2, tmpLongitude2);
    
    
    CLRegion *geoFence2 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate2
                                                            radius:regionRadius2
                                                        identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence2];
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify3" defaultValue:@"item3"];
    
    
    
    CLLocationDegrees tmpLatitude3 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude3" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude3 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude3" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius3 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius3" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate3 = CLLocationCoordinate2DMake(tmpLatitude3, tmpLongitude3);
    
    
    CLRegion *geoFence3 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate3
                                                            radius:regionRadius3
                                                        identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence3];
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify4" defaultValue:@"item4"];
    
   
    
    CLLocationDegrees tmpLatitude4 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude4" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude4 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude4" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius4 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius4" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate4 = CLLocationCoordinate2DMake(tmpLatitude4, tmpLongitude4);
    
    
    CLRegion *geoFence4 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate4
                                                            radius:regionRadius4
                                                        identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence4];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify5" defaultValue:@"item5"];
    
  
    
    CLLocationDegrees tmpLatitude5 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude5" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude5 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude5" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius5 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius5" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate5 = CLLocationCoordinate2DMake(tmpLatitude5, tmpLongitude5);
    
    
    CLRegion *geoFence5 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate5
                                                            radius:regionRadius5
                                                        identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence5];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify6" defaultValue:@"item6"];
    
    
    
    CLLocationDegrees tmpLatitude6 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude6" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude6 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude6" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius6 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius6" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate6 = CLLocationCoordinate2DMake(tmpLatitude6, tmpLongitude6);
    
    
    CLRegion *geoFence6 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate6
                                                            radius:regionRadius6
                                                        identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence6];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify7" defaultValue:@"item7"];
    
    
    
    CLLocationDegrees tmpLatitude7 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude7" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude7 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude7" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius7 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius7" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate7 = CLLocationCoordinate2DMake(tmpLatitude7, tmpLongitude7);
    
    
    CLRegion *geoFence7 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate7
                                                            radius:regionRadius7
                                                        identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence7];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify8" defaultValue:@"item8"];
    
    
    
    CLLocationDegrees tmpLatitude8 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude8" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude8 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude8" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius8 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius8" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate8 = CLLocationCoordinate2DMake(tmpLatitude8, tmpLongitude8);
    
    
    CLRegion *geoFence8 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate8
                                                            radius:regionRadius8
                                                        identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence8];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify9" defaultValue:@"item9"];
    
    
    
    CLLocationDegrees tmpLatitude9 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude9" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude9 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude9" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius9 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius9" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate9 = CLLocationCoordinate2DMake(tmpLatitude9, tmpLongitude9);
    
    
    CLRegion *geoFence9 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate9
                                                            radius:regionRadius9
                                                        identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence9];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify10" defaultValue:@"item10"];
    
    
    
    CLLocationDegrees tmpLatitude10 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude10" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude10 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude10" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius10 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius10" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate10 = CLLocationCoordinate2DMake(tmpLatitude10, tmpLongitude10);
    
    
    CLRegion *geoFence10 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate10
                                                            radius:regionRadius10
                                                        identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence10];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify11" defaultValue:@"item11"];
    
    
    
    CLLocationDegrees tmpLatitude11 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude11" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude11 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude11" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius11 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius11" defaultValue:@"50"] doubleValue];

    CLLocationCoordinate2D centerCoordinate11 = CLLocationCoordinate2DMake(tmpLatitude11, tmpLongitude11);
    
    
    CLRegion *geoFence11 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate11
                                                             radius:regionRadius11
                                                         identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence11];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify12" defaultValue:@"item12"];
    
    
    
    CLLocationDegrees tmpLatitude12 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude12" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude12 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude12" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius12 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius12" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate12 = CLLocationCoordinate2DMake(tmpLatitude12, tmpLongitude12);
    
    
    CLRegion *geoFence12 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate12
                                                             radius:regionRadius12
                                                         identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence12];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify13" defaultValue:@"item13"];
    
    
    
    CLLocationDegrees tmpLatitude13 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude13" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude13 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude13" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius13 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius13" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate13 = CLLocationCoordinate2DMake(tmpLatitude13, tmpLongitude13);
    
    
    CLRegion *geoFence13 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate13
                                                             radius:regionRadius13
                                                         identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence13];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify14" defaultValue:@"item14"];
    
    
    
    CLLocationDegrees tmpLatitude14 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude14" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude14 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude14" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius14 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius14" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate14 = CLLocationCoordinate2DMake(tmpLatitude14, tmpLongitude14);
    
    
    CLRegion *geoFence14 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate14
                                                             radius:regionRadius14
                                                         identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence14];
    
    
    
    
    
    
    itemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"notify15" defaultValue:@"item15"];
    
    
    
    CLLocationDegrees tmpLatitude15 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"latitude15" defaultValue:@""] doubleValue];
    
    CLLocationDegrees tmpLongitude15 = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"longitude15" defaultValue:@""] doubleValue];
    
    CLLocationDistance regionRadius15 =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"radius15" defaultValue:@"50"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate15 = CLLocationCoordinate2DMake(tmpLatitude15, tmpLongitude15);
    
    
    CLRegion *geoFence15 = [[CLCircularRegion alloc] initWithCenter:centerCoordinate15
                                                             radius:regionRadius15
                                                         identifier:itemId];
    
    [_locationManager startMonitoringForRegion:geoFence15];
    
    
    
    
}

// fired when user enters geofence
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSLog(@"Entering region %@", region.identifier);
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if (notification == nil){return;}
    
    notification.alertBody = region.identifier;
    
 
    
    
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    

    
    
    
    
    
    }

@end





