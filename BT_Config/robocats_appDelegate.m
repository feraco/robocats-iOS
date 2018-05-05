/*
 *	Copyright David Book, buzztouch.com
 *
 *	All rights reserved.
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


#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BT_loadConfigDataViewController.h"
#import "BT_viewController.h"
#import "BT_navController.h"
#import "BT_tabBarController.h"
#import "robocats_appDelegate.h"


@implementation robocats_appDelegate

@synthesize showDebugInfo, statusBarStyle, navBarTitleTextColor;
@synthesize window, rootNetworkMonitor, rootApp, rootDevice, rootUser, currentMode, uiIsVisible;
@synthesize configurationFileName, saveAsFileName, modifiedFileName, isRefreshing;
@synthesize audioPlayer, soundEffectNames, soundEffectPlayers, receivedData, contextMenu;

//didFinishLaunchingWithOptions...
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"didFinishLaunchingWithOptions%@", @""]];
    
    /*
     Debugging Output
     ---------------------------------------------------------------------------
     Set showDebugInfo to TRUE to print details to the console.
     To see the console, choose Run > Show Console while the simulator or a connected device
     is running. Nearly every method has output to show you details about how the program
     is executing. It looks like lots of data (it is), but it's very useful for understanding how
     the application is behaving.
     */
    
    //show debug in output window?
    [self setShowDebugInfo:TRUE];
    
    /*
     Status Bar Style
     ---------------------------------------------------------------------------
     The built in iOS status bar changed for iOS 7. The status bar is now transparent. This could
     be problematic, depending on the color of the top navigation bar. If you're app uses a dark
     color for the top navigation bar, you may need to set this to "UIStatusBarStyleLightContent"
     so the text and icons on the status bar shows light, over the dark background. The setting
     here is ignored if the devices is running iOS 6.
     */
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        [self setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    /*
     Nav Bar Title Text Color
     ---------------------------------------------------------------------------
     Prior to iOS 7, white was the standard color for the text in the top nav bar.
     White no longer works on iOS 7 because many apps are using a lighter color
     as the navigation bar background color. Set the nav bar text color here.
     This color will also be the color of the back arrow and icosn in the nav bar.
     */
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        [self setNavBarTitleTextColor:@"#000000"];
    }else{
        [self setNavBarTitleTextColor:@"#FFFFFF"];
    }
    
    
    //init the root device...
    [self setRootDevice:[[BT_device alloc] init]];
    
    //init the root user...
    [self setRootUser:[[BT_user alloc] init]];
    
    //init the root app...
    [self setRootApp:[[BT_application alloc] init]];
    
    //start monitoring network connection type changes...
    [self setRootNetworkMonitor:[BT_reachability reachabilityWithHostname:@"www.google.com"]];
    
    //tell the networkMonitor that we DO want to be reachable on 3G/EDGE/CDMA
    [self.rootNetworkMonitor setReachableOnWWAN:YES];
    
    //setup networkMonitor NSNotification observer....
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkTypeChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [self.rootNetworkMonitor startNotifier];
    
    
    //initialize a temporary window to assign to the window property...
    UIWindow *tmpWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [tmpWindow setBackgroundColor:[UIColor whiteColor]];
    [self setWindow:tmpWindow];
    
    //the window tint color affects built in iOS7 icons in the navigation bar...
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.window.tintColor = [BT_color getColorFromHexString:@"#000000"];
    }
    
    //json data for BT_loadConfigDataViewController...
    BT_item *tmpScreen = [[BT_item alloc] init];
    [tmpScreen setItemId:@"loadConfigDataScreen"];
    [tmpScreen setItemType:@"BT_loadConfigDataViewController"];
    
    //create a dictionary for the dynamic screen.
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"loadConfigDataScreen", @"itemId",
                          @"BT_loadConfigDataViewController", @"itemType", nil];
    [tmpScreen setJsonVars:dict];
    
    //init the load config data view controller...
    BT_loadConfigDataViewController *loadDataViewController = [[BT_loadConfigDataViewController alloc] initWithScreenData:tmpScreen];
    [loadDataViewController.view setFrame:[[UIScreen mainScreen] bounds]];
    [loadDataViewController.view setTag:1];
    
    //set rootViewController...
    [self.window setRootViewController:loadDataViewController];
    
    //hide status bar on launch...
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE withAnimation:UIStatusBarAnimationNone];
    
    //hide view controllers nav bar...
    [[self.window.rootViewController navigationController] setNavigationBarHidden:TRUE];
    
    //tell iOS7 the top bar needs updated..
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        [self.window.rootViewController setNeedsStatusBarAppearanceUpdate];
    }
    
    //make the window active
    [self.window makeKeyAndVisible];
    
    //return...
    return TRUE;
    
}


//when app becomes active again
- (void)applicationDidBecomeActive:(UIApplication *)application{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"applicationDidBecomeActive%@", @""]];
    
    //make sure we have an app...
    if([self rootApp] != nil){
        
        //flag as visible...
        [self setUiIsVisible:TRUE];
        
        //report to cloud (not all apps do this, dataURL and reportToCloudURL required)...
        if([[self.rootApp dataURL] length] > 1 && [[self.rootApp reportToCloudURL] length] > 1){
            [self reportToCloud];
        }
        
        //if we have a location manager, re-set it's "counter" and turn it back on.
        if([self rootLocationMonitor] != nil){
            [self.rootLocationMonitor setUpdateCount:0];
            [self.rootLocationMonitor.locationManager startUpdatingLocation];
        }
        
    }
}

//applicationWillTerminate...
-(void)applicationWillTerminate:(UIApplication *)application{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"applicationWillTerminate%@", @""]];
    
    //set ui as not visible...
    [self setUiIsVisible:FALSE];
    
}

//applicationWillResignActive...
-(void)applicationWillResignActive:(UIApplication *)application{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"applicationWillResignActive%@", @""]];
    
    //set ui as not visible...
    [self setUiIsVisible:FALSE];
    
}

//applicationDidEnterBackground...
-(void)applicationDidEnterBackground:(UIApplication *)application{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"applicationDidEnterBackground%@", @""]];
    
    //set ui as not visible...
    [self setUiIsVisible:FALSE];
    
}

//applicationWillEnterForeground...
-(void)applicationWillEnterForeground:(UIApplication *)application{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"applicationWillEnterForeground%@", @""]];
    
    //set ui as visible...
    [self setUiIsVisible:TRUE];
    
}



//refreshAppData...
-(void)refreshAppData{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"refreshAppData%@", @""]];
    
    //flag as refreshing...
    [self setIsRefreshing:TRUE];
    
    //remove previously cached version of config data...
    [BT_fileManager deleteFile:[self saveAsFileName]];
    
    
    //fade out the current view...
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.window.rootViewController.view.alpha = 1.0;
                         self.window.rootViewController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         
                         //reset the alpha so the loading view shows...
                         self.window.rootViewController.view.alpha = 1.0;
                         
                         //json data for BT_loadConfigDataViewController...
                         BT_item *tmpScreen = [[BT_item alloc] init];
                         [tmpScreen setItemId:@"loadConfigDataScreen"];
                         [tmpScreen setItemType:@"BT_loadConfigDataViewController"];
                         
                         //create a dictionary for the dynamic screen.
                         NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                               @"loadConfigDataScreen", @"itemId",
                                               @"BT_loadConfigDataViewController", @"itemType", nil];
                         [tmpScreen setJsonVars:dict];
                         
                         //init the load config data view controller...
                         BT_loadConfigDataViewController *loadDataViewController = [[BT_loadConfigDataViewController alloc] initWithScreenData:tmpScreen];
                         [loadDataViewController.view setFrame:[[UIScreen mainScreen] bounds]];
                         [loadDataViewController.view setTag:1];
                         
                         //set rootViewController...
                         [self.window setRootViewController:loadDataViewController];
                         
                         //hide status bar on launch...
                         [[UIApplication sharedApplication] setStatusBarHidden:TRUE withAnimation:UIStatusBarAnimationNone];
                         
                         //hide view controllers nav bar...
                         [[self.window.rootViewController navigationController] setNavigationBarHidden:TRUE];
                         
                         //tell iOS7 the top bar needs updated..
                         if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
                             [self.window.rootViewController setNeedsStatusBarAppearanceUpdate];
                         }
                         
                         
                     }];
    
}



//reportToCloud...
-(void)reportToCloud{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"reportToCloud%@", @""]];
    
    //if we do not have any reportToCloud results yet, make a fake one...
    if(![BT_fileManager doesLocalFileExist:[self modifiedFileName]]){
        [BT_fileManager saveTextFileToCacheWithEncoding:@"blankLastModified" fileName:self.modifiedFileName encodingFlag:-1];
    }
    
    
    //ignore if we are refreshing...
    if(![self isRefreshing]){
        
        //app's configuration data must have  a "dataURL" and a "reportToCloudURL"...
        NSString *useURL = @"";
        
        if([[self.rootApp dataURL] length] > 1 && [[self.rootApp reportToCloudURL] length] > 1){
            useURL = [self.rootApp reportToCloudURL];
        }else{
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"not reporting to cloud, no dataURL or reportToCloudURL%@", @""]];
        }
        
        if([useURL length] > 3){
            
            //if we have a currentMode in the BT_config.txt IN THE PROJECT, append it to the end of the URL...
            if([[self currentMode] length] > 0){
                useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&currentMode=%@", [self currentMode]]];
            }
            
            //the dataURL may contain merge fields...
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"reporting to cloud at : %@", useURL]];
            NSString *tmpURL = [BT_strings mergeBTVariablesInString:useURL];
            
            //clean-up URL, encode as UTF8
            NSURL *escapedURL = [NSURL URLWithString:[tmpURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            //make the http request
            NSMutableURLRequest  *theRequest = [NSMutableURLRequest requestWithURL:escapedURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
            [theRequest setHTTPMethod:@"GET"];
            NSURLConnection *theConnection;
            if((theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self])){
                
                //prepare to accept data
                receivedData = [NSMutableData data];
                
                //the connectionDidFinishLoading method in this class handles the reportToCloud results...
                
            }else{
                [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"reportToCloud error? Could not init request%@", @""]];
            }
        }
        
    }//isRefreshing...
    
    
}

//didReceiveResponse...
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [receivedData setLength:0];
}

//didReceiveData...
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(data != nil){
        [receivedData appendData:data];
    }
}

//didFailWithError...
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"reportToCloud FAILED with error: %@", [error localizedDescription]]];
    connection = nil;
}

//connectionDidFinishLoading (handles report to cloud results)...
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    connection = nil;
    
    //save data as "lastModified" file
    NSString *dStringData = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
    if([dStringData length] > 3){
        
        //returned data format: {"lastModifiedUTC":"2011-02-22 02:13:25"}
        NSString *lastModified = @"";
        NSString *previousModified = @"";
        
        //parse returned JSON data
        SBJsonParser *parser = [SBJsonParser new];
        id jsonData = [parser objectWithString:dStringData];
        if(jsonData){
            if([jsonData objectForKey:@"lastModifiedUTC"]){
                lastModified = [jsonData objectForKey:@"lastModifiedUTC"];
                [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"lastModified (value on server): %@", lastModified]];
            }
        }
        
        //parse previous saved data
        if([BT_fileManager doesLocalFileExist:self.modifiedFileName]){
            NSString *previousData = [BT_fileManager readTextFileFromCacheWithEncoding:self.modifiedFileName encodingFlag:-1];
            SBJsonParser *parser = [SBJsonParser new];
            id jsonData = [parser objectWithString:previousData];
            if(jsonData){
                if([jsonData objectForKey:@"lastModifiedUTC"]){
                    previousModified = [jsonData objectForKey:@"lastModifiedUTC"];
                    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"previousModified (value on device): %@", previousModified]];
                }
            }
        }
        
        //save a copy of the lastModified text for next time..
        BOOL saved = [BT_fileManager saveTextFileToCacheWithEncoding:dStringData fileName:self.modifiedFileName encodingFlag:-1];
        if(saved){};
        
        //if value are not emtpy, and different....ask user to confirm refresh...
        if([lastModified length] > 3 && [previousModified length] > 3){
            if(![lastModified isEqualToString:previousModified]){
                
                //show alert with confirmation...
                UIAlertView *modifiedAlert = [[UIAlertView alloc]
                                              initWithTitle:nil
                                              message:NSLocalizedString(@"updatesAvailable", "This app's content has changed, would you like to refresh?")
                                              delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"no", "NO")
                                              otherButtonTitles:NSLocalizedString(@"yes", "YES"), nil];
                [modifiedAlert setTag:12];
                [modifiedAlert show];
                
            }
        }else{
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@ does not exist in the cache. Not checking for updates.", self.modifiedFileName]];
            
        }
    }
    
}










//networkTypeChanged...
-(void)networkTypeChanged:(NSNotification*)note{
    //[note currentReachabilityString] will equal: "Cellular", "WiFi", or "No Connection"
    BT_reachability *reach = [note object];
    if([reach isReachable]){
        [self.rootDevice setDeviceConnectionType:[reach currentReachabilityString]];
        [self.rootDevice setIsOnline:TRUE];
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"networkTypeChanged. rootDevice is connected to the network: %@", [reach currentReachabilityString]]];
    }else{
        [self.rootDevice setDeviceConnectionType:@"NA"];
        [self.rootDevice setIsOnline:FALSE];
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"networkTypeChanged%@", @"rootDevice NOT connected to the network"]];
    }
}

//show alert
-(void)showAlert:(NSString *)theTitle theMessage:(NSString *)theMessage alertTag:(int)alertTag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:theTitle message:theMessage delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", "OK") otherButtonTitles:nil];
    [alertView setTag:alertTag];
    [alertView show];
}


//clickedButtonAtIndex...
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"alertView clickedButtonAtIndex: %li", (long)buttonIndex]];
    int alertTag = (int)[alertView tag];
    
    // 0 = no, 1 = yes
    if(buttonIndex == 0){
        //do nothing...
    }
    if(buttonIndex == 1 && alertTag == 12){
        [self refreshAppData];
    }
    
}


//////////////////////////////////////////////////////////////////////////////////////////////////
//tab-bar controller delegate methods (we may not use these if we don't have a tabbed app)
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"tabBarController selected: %lu", (unsigned long)[tabBarController selectedIndex]]];
    
    //play possible sound effect
    if(self.rootApp != nil){
        if([self.rootApp.tabs count] > 0){
            
            //always hide the audio controls when changing tabs
            [self hideAudioControls];
            
            //data associated with the tab we just tapped
            BT_item *selectedTabData = [self.rootApp.tabs objectAtIndex:[tabBarController selectedIndex]];
            
            //the screen we are leaving may have an audio file that is
            //configured with "audioStopsOnScreenExit" so we may need to turn it off
            if([[BT_strings getJsonPropertyValue:self.rootApp.currentScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3 || [[BT_strings getJsonPropertyValue:self.rootApp.currentScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 3){
                [BT_debugger showIt:self message:[NSString stringWithFormat:@"stopping sound on screen exit%@", @""]];
                if([[BT_strings getJsonPropertyValue:self.rootApp.currentScreenData.jsonVars nameOfProperty:@"audioStopsOnScreenExit" defaultValue:@"0"] isEqualToString:@"1"]){
                    if(self.audioPlayer != nil){
                        [self.audioPlayer stopAudio];
                    }
                }
            }
            
            //data associated with the screen we are about to load
            NSString *screenToLoadId = [BT_strings getJsonPropertyValue:selectedTabData.jsonVars nameOfProperty:@"homeScreenItemId" defaultValue:@""];
            BT_item *screenToLoadData = [self.rootApp getScreenDataByItemId:screenToLoadId];
            
            //play possible sound effect attached to this menu item
            if([[BT_strings getJsonPropertyValue:selectedTabData.jsonVars nameOfProperty:@"soundEffectFileName" defaultValue:@""] length] > 3){
                [self playSoundEffect:[BT_strings getJsonPropertyValue:selectedTabData.jsonVars nameOfProperty:@"soundEffectFileName" defaultValue:@""]];
            }
            
            if([[BT_strings getJsonPropertyValue:screenToLoadData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3 || [[BT_strings getJsonPropertyValue:screenToLoadData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 3){
                
                //start audio in different thread to prevent UI blocking
                [NSThread detachNewThreadSelector: @selector(loadAudioForScreen:) toTarget:self withObject:screenToLoadData];
                
            }
            
            //remember the screen we are loading in the rootApp
            [self.rootApp setCurrentScreenData:screenToLoadData];
            
        }
    }
    
}

//showContextMenu...
-(void)showContextMenu{
    [BT_debugger showIt:self message:@"showContextMenu"];
    
    //show the context menu's view...
    if(self.contextMenu != nil){
        
        //current nav controller and view controller...
        BT_navController *theNavController = [self getNavigationController];
        
        //position depends on device orientation
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        //if the view isn't already on the nav controller..add it. contextMenu view has tag "888"
        BOOL haveContextMenu = FALSE;
        for(UIView *view in theNavController.view.subviews) {
            if([view tag] == 888){
                haveContextMenu = TRUE;
                break;
            }
        }
        //add the subview to this controller if we don't already have it
        if(!haveContextMenu){
            [theNavController.view addSubview:[self.contextMenu view]];
        }
        
        //make mask and menu in context view full size...
        [self.contextMenu.mask setFrame:theNavController.view.bounds];
        [self.contextMenu.menuTable setFrame:theNavController.view.bounds];
        
        //bring context menu's view to the front so we can see it when it fades in..
        [theNavController.view bringSubviewToFront:[self.contextMenu view]];
        
        //position the menu's list to top right...
        int w = [self.rootDevice deviceWidth];
        int h = [self.rootDevice deviceHeight];
        
        //if landscape mode the values are opposite...
        if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
            w = [self.rootDevice deviceHeight];
            h = [self.rootDevice deviceWidth];
        }else{
            w = [self.rootDevice deviceWidth];
            h = [self.rootDevice deviceHeight];
        }
        
        //table top position...
        int tableTop = 0;
        
        //need status bar and navBar style to determine table top position...
        BT_item *tmpScreenData = [self.rootApp currentScreenData];
        NSString *tmpStatusStyle = [BT_strings getStyleValueForScreen:tmpScreenData nameOfProperty:@"statusBarStyle" defaultValue:@""];
        NSString *tmpNavBarStyle = [BT_strings getStyleValueForScreen:tmpScreenData nameOfProperty:@"navBarStyle" defaultValue:@""];
        if(![tmpStatusStyle isEqualToString:@"hidden"]){
            tableTop += 20;
        }
        if(![tmpNavBarStyle isEqualToString:@"hidden"]){
            
            //iOS 7 uses a different nav. bar height...
            if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
                tableTop += 45;
            }else{
                tableTop += 44;
            }
        }
        
        //if device is landscape, remove some pixels...
        if(tableTop > 0){
            if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
                tableTop -= 12;
                
                //if this is an iPad, add a few more pixels...
                if([self.rootDevice isIPad]){
                    tableTop += 12;
                }
                
            }
        }
        
        //set table size...
        [contextMenu.menuTable setFrame:CGRectMake(0, tableTop, (w / 2), 300)];
        
        //move the table to the right of the screen...
        CGRect frame = contextMenu.menuTable.frame;
        CGFloat xPosition = w / 2;
        
        //when landscape the w is the height...
        if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
            //xPosition = h / 2;
        }
        
        frame.origin.x = xPosition;
        contextMenu.menuTable.frame = frame;
        
        //animation block...
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.contextMenu.view setHidden:FALSE];
                             self.contextMenu.view.alpha = 0.0;
                             self.contextMenu.view.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             //ignore...
                         }];
        
        
    }
    
    
}

//hideContextMenu...
-(void)hideContextMenu{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"hideContextMenu %@", @""]];
    
    //move the the context menu off the screen and hide it
    if(self.contextMenu != nil){
        
        //animate context menu...
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.contextMenu.view.alpha = 1.0;
                             self.contextMenu.view.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             //ignore...
                         }];
        
    }
    
}




//load audio for screen
-(void)loadAudioForScreen:(BT_item *)theScreenData{
    
    //this runs in it's own thread
    @autoreleasepool {
        
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"loadAudioForScreen with itemId: %@", [theScreenData itemId]]];
        
        //theScreenData must have an "audioFileName" or an "audioFileURL" or ignore this...
        if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3 || [[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 3){
            
            //tell audio player to load itself (this can take a moment depending on the size of the audio file)
            //[self.audioPlayer loadAudioForScreen];
            if(self.audioPlayer != nil){
                
                
                //get the file name for the existing audio player...
                NSString *playingAudioFileName = [BT_strings getJsonPropertyValue:self.audioPlayer.screenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""];
                NSString *playingAudioFileURL = [BT_strings getJsonPropertyValue:self.audioPlayer.screenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""];
                if(playingAudioFileName.length < 3 && playingAudioFileURL.length > 3){
                    playingAudioFileName = [BT_strings getFileNameFromURL:playingAudioFileURL];
                }
                
                //figure out the next file name if we're using a URL
                NSString *nextAudioFileName = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""];
                NSString *nextAudioFileURL = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""];
                if(nextAudioFileName.length < 3 && nextAudioFileURL.length > 3){
                    nextAudioFileName = [BT_strings getFileNameFromURL:nextAudioFileURL];
                }
                
                //if the audio player already has the same audio track loaded...ignore
                if(![playingAudioFileName isEqualToString:nextAudioFileName]){
                    
                    [self.audioPlayer stopAudio];
                    [self.audioPlayer loadAudioForScreen:theScreenData];
                    
                }else{
                    
                    //the same track is already loaded...make sure it's playing
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"audio track already loaded: %@", nextAudioFileName]];
                    [self.audioPlayer startAudio];
                    
                }
            }
            
        }//audioFileName
        
    }//@autoreleasepool
    
}


//show audio controls on top of the current view
-(void)showAudioControls{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"showAudioControls %@", @""]];
    
    //show the audio players view
    if(self.audioPlayer != nil){
        
        //we need to know what view to show it in...
        BT_navController *theNavController = [self getNavigationController];
        
        //find center of screen for current device orientation
        CGPoint tmpCenter;
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
        if(deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight) {
            tmpCenter = CGPointMake([self.rootDevice deviceHeight] / 2, ([self.rootDevice deviceWidth] / 2));;
        }else{
            tmpCenter = CGPointMake([self.rootDevice deviceWidth] / 2, [self.rootDevice deviceHeight] / 2);;
        }
        
        //if the view isn't already on the nav controller..add it. audioPlayer view has tag "999"
        BOOL havePlayerView = FALSE;
        for(UIView *view in theNavController.view.subviews) {
            if([view tag] == 999){
                havePlayerView = TRUE;
                break;
            }
        }
        //add the subview to this controller if we don't already have it
        if(!havePlayerView){
            [theNavController.view addSubview:[self.audioPlayer view]];
        }
        
        //bring it to the front
        [theNavController.view bringSubviewToFront:[self.audioPlayer view]];
        
        //makie it visible
        [self.audioPlayer.view setHidden:FALSE];
        
        //center it
        [self.audioPlayer.view setCenter:tmpCenter];
        
    }
    
}


//hide audio controls
-(void)hideAudioControls{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"hideAudioControls %@", @""]];
    
    //move the the audio players view off the screen and hide it
    if(self.audioPlayer != nil){
        
        //we need to know what view to hide it from...
        BT_navController *theNavController = [self getNavigationController];
        
        //find the audioPlayer's view on the controller. audioPlayer view has tag "999"
        for(UIView *view in theNavController.view.subviews) {
            if([view tag] == 999){
                
                //move it, hide it
                [view setCenter:CGPointMake(-500, -500)];
                [view setHidden:TRUE];
                break;
            }
        }
        
    }
    
}

//playSoundEffect...
-(void)playSoundEffect:(NSString *)theFileName{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"playSoundEffect %@", theFileName]];
    if([theFileName length] > 3){
        
        /*
         play sound effect logic
         a) Check the soundEffectNames array for the file name
         b) if it exists, we already instantiated an audio-player object in the soundEffectPlayers array
         c) Find the index of the player, then play it
         
         */
        
        if([self.soundEffectNames containsObject:theFileName]){
            int playerIndex = (int)[self.soundEffectNames indexOfObject:theFileName];
            //we already initialized a player for this sound. Find it, play it.
            AVAudioPlayer *tmpPlayer = (AVAudioPlayer *)[self.soundEffectPlayers objectAtIndex:playerIndex];
            if(tmpPlayer){
                [tmpPlayer play];
            }
        }else{
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"playSoundInBundle:ERROR. This sound effect is not included in the list of available sounds: %@", theFileName]];
        }
    }
    
}


//didRegisterForRemoteNotificationsWithDeviceToken...
-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didRegisterForRemoteNotificationsWithDeviceToken: Device Token: %@", deviceToken]];
    
    
    /*
     
    	iOS will only prompt for this ONCE per app, even if the app is deleted and re-installed.
    	To re-set the APN prompt, do this:
    	
    	1)	Delete your app from the device.
     2)	Turn the device off completely and turn it back on.
     3)	Go to Settings > General > Date & Time and set the date ahead a day or more.
     4)	Turn the device off completely again and turn it back on.
     
     
     */
    
    
    //if we have a token, and a  register it...
    if([deviceToken length] > 1 && [[self.rootApp registerForPushURL] length] > 1){
        
        //clean up token...
        NSString *useToken = [NSString stringWithFormat:@"%@", deviceToken];
        useToken = [useToken stringByReplacingOccurrencesOfString:@"<"withString:@""];
        useToken = [useToken stringByReplacingOccurrencesOfString:@">"withString:@""];
        useToken = [useToken stringByReplacingOccurrencesOfString:@" "withString:@""];
        
        //save it for next time...
        [BT_strings setPrefString:@"lastDeviceToken" valueOfPref:useToken];
        
        //append deviceToken and deviceType to end of URL...
        NSString *useURL = [[self.rootApp registerForPushURL] stringByAppendingString:[NSString stringWithFormat:@"&deviceType=%@", @"ios"]];
        useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&deviceToken=%@", useToken]];
        
        //append currentMode ("Live" or "Design") to end of URL...
        useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&currentMode=%@", [self currentMode]]];
        
        //merge environment variables in URL...
        useURL = [BT_strings mergeBTVariablesInString:useURL];
        
        //escape the URL...
        NSString *escapedUrl = [useURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //tell the BT_device to register on the server (the device class makes the URL request)...
        [BT_device registerForPushNotifications:escapedUrl];
        
        
    }
    
}

//unRegisterForPushNotifications...
-(void)unRegisterForPushNotifications{
    
    //look for last token...
    NSString *deviceToken = [BT_strings getPrefString:@"lastDeviceToken"];
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"unRegisterForPushNotifications Device Token: %@", deviceToken]];
    
    //if we have a token, and a  register it...
    if([deviceToken length] > 1 && [[self.rootApp registerForPushURL] length] > 1){
        
        //clean up token...
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@"<"withString:@""];
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@">"withString:@""];
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" "withString:@""];
        
        //erase last token...
        [BT_strings setPrefString:@"lastDeviceToken" valueOfPref:@""];
        
        //append deviceToken and deviceType and apnCommand to end of URL...
        NSString *useURL = [[self.rootApp registerForPushURL] stringByAppendingString:[NSString stringWithFormat:@"&deviceType=%@", @"ios"]];
        useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&apnCommand=%@", @"unregisterDevice"]];
        useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&deviceToken=%@", deviceToken]];
        
        //append currentMode ("Live" or "Design") to end of URL...
        useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&currentMode=%@", [self currentMode]]];
        
        //merge environment variables in URL...
        useURL = [BT_strings mergeBTVariablesInString:useURL];
        
        //escape the URL...
        NSString *escapedUrl = [useURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //tell the BT_device to unRegister on the server (the device class makes the URL request)...
        [BT_device unRegisterForPushNotifications:escapedUrl];
        
    }
    
}

//didFailToRegisterForRemoteNotificationsWithError...
-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didFailToRegisterForRemoteNotificationsWithError: ERROR: %@", error]];
    
    
    
    /*
    	Simulators ALWAYS fail with this error and will NEVER prompt the user to allow APN.
     
     
    	iOS will only prompt for this ONCE per app, even if the app is deleted and re-installed.
    	To re-set the APN prompt, do this:
    	
    	1)	Delete your app from the device.
     2)	Turn the device off completely and turn it back on.
     3)	Go to Settings > General > Date & Time and set the date ahead a day or more.
     4)	Turn the device off completely again and turn it back on.
     
     
     */
    
    
    
    
}

//didReceiveRemoteNotification..
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didReceiveRemoteNotification %@", @""]];
    
    //don't do anything if the app is not in the foreground. iOS handles inbound APNS message when app is in the background...
    if(application.applicationState == UIApplicationStateActive){
        
        
        NSString *alertMsg;
        NSString *badge;
        NSString *sound;
        
        //alert message...
        if([[userInfo objectForKey:@"aps"] objectForKey:@"alert"] != NULL){
            alertMsg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        }
        
        //badge...
        if([[userInfo objectForKey:@"aps"] objectForKey:@"badge"] != NULL){
            badge = [[userInfo objectForKey:@"aps"] objectForKey:@"badge"];
        }
        
        //sound...
        if([[userInfo objectForKey:@"aps"] objectForKey:@"sound"] != NULL){
            sound = [[userInfo objectForKey:@"aps"] objectForKey:@"sound"];
        }
        
        //if we have a sound...
        if([sound length] > 1){
            [self performSelector:@selector(playSoundFromPushMessage:) withObject:sound afterDelay:.1];
        }
        
        //show messsage...
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                              otherButtonTitles:nil];
        [alert show];
        
        
    }//in foreground...
}

//playSoundFromPushMessage...
-(void)playSoundFromPushMessage:(NSString *)soundEffectFileName{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"playSoundFromPushMessage: %@", soundEffectFileName]];
    
    NSString *theFileName = soundEffectFileName;
    if([BT_fileManager doesFileExistInBundle:theFileName]){
        NSURL *soundFileUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], theFileName]];
        NSError *error;
        AVAudioPlayer *tmpPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error:&error];
        if(!error){
            [tmpPlayer setNumberOfLoops:0];
            [tmpPlayer prepareToPlay];
            [tmpPlayer play];
        }else{
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didReceiveRemoteNotification soundEffectPlayer ERROR: %@", [error description]]];
        }
    }
    
}


//getNavigationController...
-(BT_navController *)getNavigationController{
    
    BT_navController *theNavController;
    if([self.rootApp.tabs count] > 0){
        
        /*
         NOTE:
         rootApp.rootTabBarController is instantiated with an array of NAVIGATION controllers, not
         view controllers. This means the "selectedViewController" property returns an NAV controller,
         not a VIEW controller. Note how we cast this to a BT_navigationController before returning it.
         */
        
        theNavController = (BT_navController *)[self.rootApp.rootTabBarController selectedViewController];
        
    }else{
        theNavController = (BT_navController *)[self.rootApp rootNavController];
    }
    
    //return the nav controller...
    return theNavController;
    
}

//getViewController...
-(BT_viewController *)getViewController{
    
    BT_viewController *theViewController;
    if([self.rootApp.tabs count] > 0){
        
        /*
         NOTE:
         rootApp.rootTabBarController is instantiated with an array of NAVIGATION controllers, not
         view controllers. This means we can't reference the tab bars selectedViewController becuase it
         will return a navigation controller (not a view controller). We reference this navigation
         controllers "visibleViewController" property to ge the current view controller.
         */
        
        BT_navController *theNavController = [self getNavigationController];
        theViewController = (BT_viewController *)[theNavController visibleViewController];
        
    }else{
        theViewController = (BT_viewController *)[self.rootApp.rootNavController visibleViewController];
    }
    
    //return the view controller...
    return theViewController;
    
}



//supportedInterfaceOrientations is needed for iOS 6 >
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"supportedInterfaceOrientationsForWindow %@", @""]];
    
    /*
     This method only used on iOS 6.0 >. The UIApplicationClass did not
     handle the supportedInterfaceOrientationsForWindow method prior to iOS 6.
     */
    
    
    
    //allow / dissallow rotations, asume we do NOT allow rotations...
    BOOL canRotate = FALSE;
    
    //appDelegate
    if([self.rootDevice isIPad]){
        
        //iPads always support rotations...
        canRotate = TRUE;
        
    }else{
        
        //should we allow rotations on all devices?
        if([self.rootApp.jsonVars objectForKey:@"allowRotation"]){
            if([[self.rootApp.jsonVars objectForKey:@"allowRotation"] isEqualToString:@"allDevices"]){
                canRotate = TRUE;
            }
        }
    }
    
    //bitwise OR operator...
    NSUInteger mask = 0;
    mask |= UIInterfaceOrientationMaskPortrait;
    if(canRotate){
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
        mask |= UIInterfaceOrientationMaskLandscapeRight;
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
    //return...
    return mask;
    
}




@end










