/*
 *	Copyright 2013, David Book, buzztouch.com
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

#import "BT_loadConfigDataViewController.h"

@implementation BT_loadConfigDataViewController

@synthesize configurationFileName, saveAsFileName, modifiedFileName;
@synthesize configData, downloader, needsRefreshed;

//viewDidLoad
-(void)viewDidLoad{
	[super viewDidLoad];
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
    
    //set background color for loading view...
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
}


//viewWillAppear...
-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[BT_debugger showIt:self theMessage:@"viewWillAppear"];
    
    
}

//viewDidAppear...
-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[BT_debugger showIt:self theMessage:@"viewDidAppear"];
    
    //get a reference to the appDelegate...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
 	//if not audio player was already initialized, we are refreshing... kill it.
	if(appDelegate.audioPlayer != nil){
		[appDelegate.audioPlayer stopAudio];
		[appDelegate.audioPlayer.audioPlayer setCurrentTime:0];
	}
    
    //show progress...
    [self showProgress];
    
    //load the app's config data after a slight delay (make sure network is initialized in rootDevice)...
    [self performSelector:@selector(loadAppData) withObject:nil afterDelay:1.5];
    
}


//loadAppData...
-(void)loadAppData{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"loadAppData%@", @""]];
	
	/*
     Application Configuration Data (JSON)
     ---------------------------------------------------------------------------
     One file holds all the configuration JSON data associated with the application. This file must exist
     in the applications bundle in Xcode. This file is normally named BT_config.txt and can be edited with
     a normal text editor. If this configuration data uses a dataURL, a remote server will be polled for content
     changes. Changes will be downloaded and saved locally on the device's file system. Once this happens,
     the BT_config.txt file included in the Xcode project is no longer used and instead the application
     refers to it's newly downloaded and cached data. In other words, if a dataURL is used then the
     configuration file in the Xcode project is only referenced so it can find the dataURL.
     If no dataURL is provided, the file in the bundle will be read and parsed everytime.
     
     Possible Scenarios:
     -------------------
     1) App DOES NOT use a dataURL. Use the JSON data in the Xcode project always.
     2) App DOES use a dataURL and no cached data is available. Download new data IF online, else use JSON in Xcode project.
     3) App DOES use a dataURL and cached data is available. Use cachedData on device.
     
     */
    
    //showProgress...
    [self showProgress];
    
    //get a reference to the appDelegate...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //asume "BT_config.txt" is the name of file holding the JSON data...
    [self setConfigurationFileName:@"BT_config.txt"];
    
    //use a remembered config file if it exists. A plugin may allow a user to change the JSON config file...
    NSString *tmpConfigFileName = [BT_strings getPrefString:@"configToUse"];
    if([tmpConfigFileName length] > 5){
        [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"Will use remembered (non-standard) JSON configuration file \"%@\" if a newer version is not cached on the device", tmpConfigFileName]];
        [self setConfigurationFileName:tmpConfigFileName];
    }else{
        [BT_debugger showIt:self theMessage:@"Will use the default JSON configuration file \"BT_config.txt\" if a newer version is not cached on the device."];
    }
    
    //the file name of the cached JSON file after downloading (if a dataURL is used)...
    [self setSaveAsFileName:@"cachedAppConfig.txt"];
    
    //the file name of the cached file that holds the last modified date after the reportToCloud method runs...
    [self setModifiedFileName:@"appModified.txt"];
    
    //remember these values in the app's delegate so we can reference them anywhere in the app...
    [appDelegate setConfigurationFileName:[self configurationFileName]];
    [appDelegate setSaveAsFileName:[self saveAsFileName]];
    [appDelegate setModifiedFileName:[self modifiedFileName]];
    
    //begin with NO JSON data...
	[self setConfigData:@""];
    
    //flag for log so we can show what JSON is being used...
    NSString *parsedDataFrom = @"";
    [self setNeedsRefreshed:FALSE];
    
    //look for a saved version of the JSON data on the device (from a previous refresh)...
	if([BT_fileManager doesLocalFileExist:[self saveAsFileName]]){
        
		//read the configuration data from the cache, assign it's value to configData property...
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"Parsing previously cached JSON data: \"%@\"", [self saveAsFileName]]];
		[self setConfigData:[BT_fileManager readTextFileFromCacheWithEncoding:[self saveAsFileName] encodingFlag:-1]];
		parsedDataFrom = [self saveAsFileName];
        
        
	}else{
        
        //no cached version of the JSON data was found, use the config data in the Xcode project...
		if([BT_fileManager doesFileExistInBundle:[self configurationFileName]]){
            
			//read the configuration data from the project bundle and assign it's value to the configData property...
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"Parsing JSON data included in the project bundle: \"%@\"", [self configurationFileName]]];
            [self setConfigData:[BT_fileManager readTextFileFromBundleWithEncoding:[self configurationFileName] encodingFlag:-1]];
            parsedDataFrom = [self configurationFileName];
            [self setNeedsRefreshed:TRUE];
            
        }
	}
    
    //make sure the config data is valid...
    if(![appDelegate.rootApp validateApplicationData:self.configData]){
        
        //delete bogus data (if it was in the cache)...
        [BT_fileManager deleteFile:self.saveAsFileName];
        
        //show message in log, delete bogus data from the cache...
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"error parsing application data from: \"%@\"", parsedDataFrom]];
        [self hideProgress];
        [self showAlert:nil message:NSLocalizedString(@"appDataInvalid", "The JSON data for this app is invalid. Restart the app to try again.") alertTag:99];
        
    }else{
        
        //ask the app to parse this config data...
        [appDelegate.rootApp parseJSONData:[self configData]];
        
        //see if the app uses a dataURL...
        if([[appDelegate.rootApp dataURL] length] > 1){
            
            //dataURL used in JSON...
            if([appDelegate.rootDevice isOnline]){
                
                //download new version of JSON if needed...
                if([self needsRefreshed]){
                    [self downloadAppData];
                }else{
                    [self configureEnvironmentUsingAppData:self.configData];
                }
                
            }else{
                
                //not online, use cached or Xcode data...
                [self configureEnvironmentUsingAppData:self.configData];
                
            }
            
        }else{
            
            //no dataURL used in JSON...
            [self configureEnvironmentUsingAppData:self.configData];
            
            
        }//dataURL...
        
        
    }//valid config data in Xcode project...
    
  	
}//load data


//configureEnvironmentUsingAppData...
-(void)configureEnvironmentUsingAppData:(NSString *)appData{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"configureEnvironmentUsingAppData%@", @""]];
    
    //get a reference to the appDelegate...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //init context menu...
    [appDelegate setContextMenu:[[BT_contextMenu alloc] initWithMenuData:nil]];
    [appDelegate.contextMenu.view setTag:888];
    
    //init audio player in background...
    [self performSelectorInBackground:@selector(initAudioPlayer) withObject:nil];
    
    //load sound effects in background...
    [self performSelectorInBackground:@selector(loadSoundEffects) withObject:nil];
    
    
	/*
     Location Manager Logic
     ----------------------
     If the app's owner has not turned off location tracking, and the app's user has not prevented this
     from a possible settings screen... try to init a location manager.
     */
	BOOL initLocationManager = TRUE;
	NSString *locationMessage = @"";
	if(![appDelegate.rootDevice canReportLocation] == TRUE){
		initLocationManager = FALSE;
		locationMessage = [locationMessage stringByAppendingString:@"This device cannot report it's location. "];
	}
	//if a "userAllowLocation" is set to "prevent" in the NSUserDefaults, DO NOT START MONITORING LOCATION UPDATES...
	if([[BT_strings getPrefString:@"userAllowLocation"] isEqualToString:@"prevent"]){
		locationMessage = [locationMessage stringByAppendingString:@"User has prevented location monitoring. \"userAllowLocation\" is set to \"prevent\" in the NSUserDefaults."];
		initLocationManager = FALSE;
	}
    
	//does the config data want us to start the location manager?
	if([appDelegate.rootApp.jsonVars objectForKey:@"startLocationUpdates"]){
		if([[appDelegate.rootApp.jsonVars objectForKey:@"startLocationUpdates"] isEqualToString:@"0"]){
			locationMessage = [locationMessage stringByAppendingString:@"\"Start Location Updates\" = \"No\". "];
			initLocationManager = FALSE;
		}
	}
	//finally, init the manager and turn it on...
	if(initLocationManager){
		locationMessage = [locationMessage stringByAppendingString:@"starting the location monitor. "];
		appDelegate.rootLocationMonitor = [[BT_locationManager alloc] init];
		[appDelegate.rootLocationMonitor startLocationUpdates];
	}else{
		locationMessage = [locationMessage stringByAppendingString:@"NOT starting the location monitor. "];
	}
	[BT_debugger showIt:self message:locationMessage];
    
    //ask app to build it's interface...
    [appDelegate.rootApp buildInterface];
    
    //flag as visible...
    [appDelegate setUiIsVisible:TRUE];
    
    //remove all previous sub-views...
    for(UIView *view in appDelegate.window.subviews){
        if(view.tag != 1){
            [view removeFromSuperview];
        }
    }
    
    
    //if we didn't have any screens, show an error
    if([appDelegate.rootApp.screens count] < 1){
        [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"This application does not have any screens to display?%@",@""]];
        [self showAlert:nil message:NSLocalizedString(@"appNoScreensError", @"No screens to display.") alertTag:99];
        
        //remove cached data (it must be bogus)...
        [BT_fileManager deleteFile:self.saveAsFileName];
        
    }else{
        
        //fade out the BT_loadConfigData controller...
        [self fadeOutLoadView];
        
        //promptForPushNotifications...
        if([appDelegate.rootApp promptForPushNotifications]){
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"promptForPushNotifications %@",@""]];
        
            //iOS8 handles register for push differently...
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                
                //use registerUserNotificationSettings
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                
            } else {
                
                //prior to iOS8, use registerForRemoteNotificationTypes...
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
                
            }
        
        
        }
        
    }
    
    //tell app delegate we are done refreshing...
    [appDelegate setIsRefreshing:FALSE];
    
    
}

//fadeOutLoadView...
-(void)fadeOutLoadView{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"fadeOutLoadView%@", @""]];
    
    //animation block...
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.view.alpha = 1.0;
                         self.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         
                         //fade in...
                         [self fadeInStartView];
                         [self hideProgress];
                         
                     }];
    
}


//fadeInStartView...
-(void)fadeInStartView{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"fadeInStartView%@", @""]];
    
    //get a reference to the appDelegate...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //set navigation controller or tab controller for the window...
    if([appDelegate.rootApp.tabs count] > 0){
        
        //set the windows rootViewController...
        [appDelegate.window setRootViewController:appDelegate.rootApp.rootTabBarController];
        [appDelegate.window bringSubviewToFront:[appDelegate.rootApp.rootTabBarController view]];
        [appDelegate.window.rootViewController.view setAlpha:0.0];
        
    }else{
        
        //set the windows rootViewController...
        [appDelegate.window setRootViewController:appDelegate.rootApp.rootNavController];
        [appDelegate.window bringSubviewToFront:[appDelegate.rootApp.rootNavController view]];
        [appDelegate.window.rootViewController.view setAlpha:0.0];
    }
    
    //fade this in...
    UIView *fadeView = [appDelegate.window.rootViewController view];
    
    //animation block...
    [UIView animateWithDuration:0.5
                     animations:^{
                         fadeView.alpha = 0.0;
                         fadeView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         //ignore...
                     }];
    
}


//initAudioPlayer...
-(void)initAudioPlayer{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"initAudioPlayer%@", @""]];
    
    //run in background thread...
    @autoreleasepool{
        
        //get a reference to the appDelegate...
        robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
        
        //create the player in the appDelegate...
        [appDelegate setAudioPlayer:[[BT_audioPlayer alloc] initWithScreenData:nil]];
        [appDelegate.audioPlayer.view setTag:999];
        
    }//autoreleasepool...
    
}

//initAudioPlayer...
-(void)loadSoundEffects{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"loadSoundEffects%@", @""]];
    
    //run in background thread...
    @autoreleasepool{
        
        //get a reference to the appDelegate...
        robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
        
        //fill an array of sound effect file names...
        [appDelegate setSoundEffectNames:[[NSMutableArray alloc] init]];
        [appDelegate.soundEffectNames addObject:@"bt_funk.mp3"];
        [appDelegate.soundEffectNames addObject:@"bt_glass.mp3"];
        
        //setup audio session for sound effects...
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        
        //fill an array of sound effect player objects to pre-load with each audio track...
        [appDelegate setSoundEffectPlayers:[[NSMutableArray alloc] init]];
        for(int x = 0; x < [appDelegate.soundEffectNames count]; x++){
            
            NSString *theFileName = [appDelegate.soundEffectNames objectAtIndex:x];
            if([BT_fileManager doesFileExistInBundle:theFileName]){
                NSURL *soundFileUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], theFileName]];
                NSError *error;
                AVAudioPlayer *tmpPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error:&error];
                [tmpPlayer setNumberOfLoops:0];
                [tmpPlayer setDelegate:appDelegate];
                [appDelegate.soundEffectPlayers addObject:tmpPlayer];
            }
            
        }
        
    }
    
}


//download app data...
-(void)downloadAppData{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloadAppData%@", @""]];
    
    //get a reference to the appDelegate...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //start spinner...
    [self.spinner startAnimating];
    
    //the dataURL may contain merge fields...
    NSString *tmpURL = [BT_strings mergeBTVariablesInString:[appDelegate.rootApp dataURL]];
    
    //clean up URL
    NSString *escapedUrl = [tmpURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //download data (when it's done it will continue, see downloadFileCompleted at bottom)
    downloader = [[BT_downloader alloc] init];
    [downloader setSaveAsFileName:[self saveAsFileName]];
    [downloader setSaveAsFileType:@"return"];
    [downloader setUrlString:escapedUrl];
    [downloader setDelegate:self];
    [downloader downloadFile];
    
    
}





//showProgress...
-(void)showProgress{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"showProgress%@", @""]];
    
    //start spinner...
    [self.spinner startAnimating];
    
}

//hideProgress...
-(void)hideProgress{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"hideProgress%@", @""]];
    
    //stop spinner...
    [self.spinner stopAnimating];
}


//showAlert...
-(void)showAlert:(NSString *)theTitle message:(NSString *)theMessage alertTag:(int)alertTag{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"showAlert%@", @""]];
    
    //show alert without yes/no if we have 99 for the tag...
    UIAlertView *alertView;
    if(alertTag != 99){
        alertView = [[UIAlertView alloc]
                     initWithTitle:theTitle
                     message:theMessage
                     delegate:self
                     cancelButtonTitle:NSLocalizedString(@"no", "NO")
                     otherButtonTitles:NSLocalizedString(@"yes", "YES"), nil];
    }else{
        alertView = [[UIAlertView alloc]
                     initWithTitle:theTitle
                     message:theMessage
                     delegate:self
                     cancelButtonTitle:NSLocalizedString(@"Close", "Close")
                     otherButtonTitles:nil, nil];
    }
    [alertView setTag:alertTag];
    [alertView show];
    
}

//alert view delgate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"alertView clickedButtonAtIndex: %ld", (long)buttonIndex]];

    //if tag == 99 we had invalid JSON data, kill the app...
    if(alertView.tag == 99 || buttonIndex == 0){
        exit(0);
        return;
    }
    
    //YES confirms try again...
	if(buttonIndex == 1){
		[self downloadAppData];
	}
    
	
}


//////////////////////////////////////////////////////////////////////////////////////////////////
//downloader delegate methods. Called when refreshing app data.


//downloadFileStarted...
-(void)downloadFileStarted:(NSString *)message{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloadFileStarted: %@", message]];
}

//downloadFileInProgress...
-(void)downloadFileInProgress:(NSString *)message{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloadFileInProgress: %@", message]];
}

//downloadFileCompleted...
-(void)downloadFileCompleted:(NSString *)message{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloadFileCompleted%@", @""]];
	[self hideProgress];
    
    //get a reference to the appDelegate...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
	//message from downloader will be an error or a valid JSON...
	if([message rangeOfString:@"ERROR-1968" options:NSCaseInsensitiveSearch].location != NSNotFound){
		
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"the download process reported an error?: %@", message]];
		[self showAlert:nil message:NSLocalizedString(@"appDownloadErrorTryAgain", @"There was a problem downloading some required data. Try again?") alertTag:68];
        [BT_fileManager deleteFile:self.saveAsFileName];
        [self setNeedsRefreshed:TRUE];
        
	}else{
        
		//save the version we just downloaded...
		if([BT_fileManager saveTextFileToCacheWithEncoding:message fileName:[self saveAsFileName] encodingFlag:-1]){
			
			//the data we just got must be valid
			if([appDelegate.rootApp validateApplicationData:message]){
                
				//delete previously cached data (this does not remove a cached JSON config file)...
				[BT_fileManager deleteAllLocalData];
                
                //parse newly downloaded data...
                [appDelegate.rootApp parseJSONData:message];
                
                //flag as not needing refreshed anymore...
                [self setNeedsRefreshed:FALSE];
                
				//rebuild environment...
				[self configureEnvironmentUsingAppData:message];
                
                
			}else{
                
                //remove bogus download...
                [BT_fileManager deleteFile:self.saveAsFileName];
                
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"error parsing downloaded app config data%@", @""]];
				[self showAlert:nil message:NSLocalizedString(@"appDownloadErrorInvalidJSON", @"There was a problem reading some required data. Try again?") alertTag:68];
                [self setNeedsRefreshed:TRUE];
                
			}
			
		}else{
            
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"error saving downloaded app config data%@", @""]];
			[self showAlert:nil message:NSLocalizedString(@"appDownloadErrorCouldNotSave", @"There was a problem saving some required data. Try again?") alertTag:68];
            [self setNeedsRefreshed:TRUE];
            
		}
		
	}//no error
	
	
}


//dealloc...
-(void)dealloc{
    
}

@end







