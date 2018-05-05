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

#import "iAd/ADBannerView.h"
#import "BT_viewController.h"

@implementation BT_viewController
@synthesize screenData, progressView;
@synthesize adView, adBannerView, adBannerViewIsVisible;
@synthesize hasStatusBar, hasNavBar, hasToolBar;


//initWithScreenData
-(id)initWithScreenData:(BT_item *)theScreenData{
    if((self = [super init])){
        [BT_debugger showIt:self message:@"INIT"];
        
        //set screen data
        [self setScreenData:theScreenData];
        
        
    }
    return self;
}

//viewDidLoad...
-(void)viewDidLoad{
    [BT_debugger showIt:self theMessage:@"viewDidLoad (super)"];
    [super viewDidLoad];
    
    //adjust view edges on iOS7, depending on the navBar transparency...
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        if(![[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"navBarStyle" defaultValue:@""] isEqualToString:@"transparent"]){
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    
    
}

//viewWillAppear...
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [BT_debugger showIt:self theMessage:@"viewWillAppear (super)"];
    
    //flag this as the current screen...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.rootApp.currentScreenData = self.screenData;
    
    //setup navBar...
    [self configureNavBar];
    
    //setup background...
    [self configureBackground];
    
    //show view...
    [self fadeInOnEntry];
    
}

//viewWillDisappear...
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [BT_debugger showIt:self theMessage:@"viewWillDisappear (super)"];
    
    //hide view so next view does not overlay...
    [self fadeOutOnExit];
    
}

//fadeInOnEntry...
-(void)fadeInOnEntry{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"fadeInOnEntry (super)%@:", @""]];
    
    //animate the menu...
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}

//fadeOutOnExit...
-(void)fadeOutOnExit{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"fadeOutOnExit (super)%@:", @""]];
    
    //animate the menu...
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}




//preferredStatusBarStyle...
-(UIStatusBarStyle)preferredStatusBarStyle{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"preferredStatusBarStyle (super)%@:", @""]];
    
    //flag this as the current screen...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate statusBarStyle];
}


-(void)configureNavBar{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"configureNavBar (super) for screen with itemId: %@", [self.screenData itemId]]];
    
    //need to figure out if device is iOS 7 or earlier for statusBar and navigationBar setup...
    int iosVer = 7;
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        iosVer = 6;
    }
    
    //appDelegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    /////////////////////////////////////////
    ////////  setup status bar
    
    //set the status bar style (assume default)
    int statusBarStyle = UIStatusBarStyleDefault;
    
    //if this is iOS 7, look for a global setting in the app's delegate...
    if(iosVer > 6){
        statusBarStyle = [appDelegate statusBarStyle];
    }
    
    //assume the status bar is NOT hidden...
    BOOL statusBarHidden = FALSE;
    
    //default status bar...
    if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"statusBarStyle" defaultValue:@""] isEqualToString:@"default"]){
        statusBarStyle = UIStatusBarStyleDefault;
        
        //if this is iOS 7, look for a global setting in the app's delegate...
        if(iosVer > 6){
            statusBarStyle = [appDelegate statusBarStyle];
        }
        
    }
    
    //solid status bar...
    if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"statusBarStyle" defaultValue:@""] isEqualToString:@"solid"]){
        if(iosVer == 6){
            statusBarStyle = UIStatusBarStyleBlackOpaque;
        }else{
            statusBarStyle = [appDelegate statusBarStyle];
        }
    }
    
    //transparent status bar...
    if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"statusBarStyle" defaultValue:@""] isEqualToString:@"transparent"]){
        if(iosVer == 6){
            statusBarStyle = UIStatusBarStyleBlackTranslucent;
        }else{
            statusBarStyle = [appDelegate statusBarStyle];
        }
        
    }
    
    //hiden status bar...
    if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"statusBarStyle" defaultValue:@""] isEqualToString:@"hidden"]){
        statusBarHidden = TRUE;
    }
    
    //apply status bar style...
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle];
    
    //hide or show status bar, method changed after iOS 3.0 > ...
    if([[UIApplication sharedApplication] respondsToSelector:@selector(setStatusBarHidden:withAnimation:)]){
        [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden withAnimation:UIStatusBarAnimationNone];
    }
    
    //////// end setup status bar
    /////////////////////////////////////////
    
    
    /////////////////////////////////////////
    ////////  setup nav bar
    
    //sets the title text from the jsonVars...
    NSString *navBarText = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"navBarTitleText" defaultValue:@""];
    [self.navigationItem setTitle:navBarText];
    
    ///set the nav bar background color...
    if(iosVer > 6){
        [[self.navigationController navigationBar] setBarTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:self.screenData]];
        
   	    //text and icons in the nav bar also need to be set to "title color"...
        [self.navigationController.navigationBar setTintColor:[BT_color getColorFromHexString:[appDelegate navBarTitleTextColor]]];
        
        
    }else{
        [[self.navigationController navigationBar] setTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:self.screenData]];
    }
    
    //set the nav bar style...
    if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"navBarStyle" defaultValue:@""] isEqualToString:@"transparent"]){
        [self.navigationController.navigationBar setTranslucent:TRUE];
    }else{
        [self.navigationController.navigationBar setTranslucent:FALSE];
    }
    
    //is the nav bar hidden...
    if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"navBarStyle" defaultValue:@""] isEqualToString:@"hidden"]){
        [[self navigationController] setNavigationBarHidden:TRUE animated:FALSE];
    }else{
        [[self navigationController] setNavigationBarHidden:FALSE animated:FALSE];
    }
    
    // add a back button on all screens that are not the "home" screen for non-child apps.
    if([self.navigationController.viewControllers count] < 2){
        if([appDelegate respondsToSelector:@selector(refreshAppData)]){
            if([appDelegate.rootApp.dataURL length] > 3){
                
                //tabbed apps only the first tab will show the refresh button.
                if([self.screenData isHomeScreen]){
                    
                    UIBarButtonItem *theRefreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:appDelegate action:@selector(refreshAppData)];
                    [self.navigationItem setLeftBarButtonItem:theRefreshButtonItem];
                }
                
            }
        }
    }else{
        
        SEL sel = NSSelectorFromString(@"navLeftTap");
        if([self respondsToSelector:sel]){
            
            NSString *backText = NSLocalizedString(@"back",@"back");
            if(![[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"navBarBackButtonText" defaultValue:@""] isEqualToString:@""]){
                backText = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"navBarBackButtonText" defaultValue:@""];
            }
            
            //iOS7 should show the standard left arrow...
            if(iosVer > 6){
                
                //make sure iOS7 shows the built in back button...
                [self.navigationItem setHidesBackButton:FALSE];
                
            }else{
                
                UIBarButtonItem *theBackButtonItem = theBackButtonItem = [[UIBarButtonItem alloc] initWithTitle:backText style:UIBarButtonItemStylePlain target:self action:sel];
                [self.navigationItem setLeftBarButtonItem:theBackButtonItem];
                
            }
            
        }
        
        
    }
    
    /*
     Right Side Button(s) logic...
     The right side navigation bar button will be zero, one, or two buttons.
     A navBarRightButtonType is possible.
     A "show context menu" icon is possible.
     */
    
    
    //create a toolbar to hold the the possible buttons...
    BOOL useRightButtons = false;
    
    //create an array to hold the buttons...
    NSMutableArray *rightBarButtonArray = [[NSMutableArray alloc] initWithCapacity:2];
    
    //if we're using a context menu, create another button...
    NSString *contextMenuItemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"contextMenuItemId" defaultValue:@""];
    if([contextMenuItemId length] > 1){
        useRightButtons = TRUE;
        
        //selector for right button...
        SEL sel = NSSelectorFromString(@"showContextMenu");
        
        //ios7 uses black image, else white...
        NSString *img = iosVer > 6 ? @"bt_contextMenu_black.png" : @"bt_contextMenu_white.png";
        UIImage *tmpImg = [UIImage imageNamed:img];
        CGRect imgFrame = CGRectMake(0, 0, tmpImg.size.width, tmpImg.size.height);
        
        //setup the button using the size of the image...
        UIButton *tmpButton = [[UIButton alloc] initWithFrame:imgFrame];
        [tmpButton setBackgroundImage:tmpImg forState:UIControlStateNormal];
        [tmpButton addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *contextMenuButton = [[UIBarButtonItem alloc] initWithCustomView:tmpButton];
        
        //add button to array...
        [rightBarButtonArray addObject:contextMenuButton];
        
    }
    
    //add the navBarRightButtonType if needed...
    NSString *navBarRightButtonType = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"navBarRightButtonType" defaultValue:@""];
    if([navBarRightButtonType length] > 1){
        NSArray *supportedButtonTypes = [NSArray arrayWithObjects:@"home", @"next", @"infoLight", @"infoDark", @"details", @"addBlue", @"done",
                                         @"cancel", @"edit", @"save", @"add", @"compose", @"reply", @"action", @"organize",
                                         @"bookmark", @"search", @"refresh", @"camera", @"trash", @"play", @"pause",
                                         @"stop", @"rewind", @"fastForward", nil];
        
        //navBarRightButtonType must be in our list of options...
        if([supportedButtonTypes containsObject:navBarRightButtonType]){
            useRightButtons = TRUE;
            
            //create the button
            UIButton *theButton = nil;
            UIBarButtonItem *theBarButtonItem = nil;
            
            SEL selector = NSSelectorFromString(@"navRightTap");
            
            //get the button or the bar button item type (there is a difference)
            if([navBarRightButtonType isEqualToString:@"home"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"home", @"Home") style:UIBarButtonItemStylePlain target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"infoLight"]) theButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            if([navBarRightButtonType isEqualToString:@"infoDark"]) theButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
            if([navBarRightButtonType isEqualToString:@"details"]) theButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            if([navBarRightButtonType isEqualToString:@"addBlue"]) theButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            if([navBarRightButtonType isEqualToString:@"next"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"next", @"Next") style:UIBarButtonItemStylePlain target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"done"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"cancel"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"edit"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"save"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"add"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"compose"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"reply"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"action"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"organize"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"bookmark"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"search"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"refresh"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"camera"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"trash"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"play"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"pause"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"stop"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"rewind"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:selector ];
            if([navBarRightButtonType isEqualToString:@"fastForward"]) theBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:selector ];
            
            //add it only if the view controller can respond
            if([self respondsToSelector:selector]){
                if(theButton != nil){
                    [theButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
                    UIBarButtonItem *tmpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:theButton];
                    [rightBarButtonArray addObject:tmpBarButtonItem];
                }
                if(theBarButtonItem != nil){
                    [rightBarButtonArray addObject:theBarButtonItem];
                }
            }
            
        }
    }
    
    
    
    //are we adding one or two right buttons...
    if(useRightButtons){
        
        //add the button items array as right side button...
        [self.navigationItem setRightBarButtonItems:rightBarButtonArray];
        
    }
    
    //iO6 needs to adjust the frame for to top nav bar...
    if(iosVer < 7){
        
        //is the status bar hidden?
        CGRect rect;
        CGFloat height = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 44 : 44;
        if([UIApplication sharedApplication].statusBarHidden){
            rect = CGRectMake(0, 0, self.view.bounds.size.width, height);
        }else{
            rect = CGRectMake(0, 20, self.view.bounds.size.width, height);
        }
        
        //set the frame..
        [self.navigationController.navigationBar setFrame:rect];
        
        
    }
    
    //set the title text color using the value saved in the app's delegate...
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor:[BT_color getColorFromHexString:[appDelegate navBarTitleTextColor]]};
    
    //set the back arrow and other icons to the title text color for iOS7...
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        [self.navigationController.navigationBar setTintColor:[BT_color getColorFromHexString:[appDelegate navBarTitleTextColor]]];
    }
    
    ////////  end setup nav bar
    /////////////////////////////////////////
    
    
    //tell iOS7 the top bar needs updated..
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
}

//configureNavBackground...
-(void)configureBackground{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"configureBackground (super) for screen with itemId %@:", [self.screenData itemId]]];
    
    //appDelegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //tell the global background to update itself....
    [[appDelegate.rootApp rootBackgroundView] updateProperties:self.screenData];
    
}



//show progress
-(void)showProgress{
    //[BT_debugger showIt:self message:@"showProgress (super)"];
    
    //show progress view if not showing
    if(progressView == nil){
        progressView = [BT_viewUtilities getProgressView:@""];
        [self.view addSubview:progressView];
    }
    
}

//hide progress
-(void)hideProgress{
    //[BT_debugger showIt:self message:@"hideProgress (super)"];
    
    //remove progress view if already showing
    if(progressView != nil){
        [progressView removeFromSuperview];
        progressView = nil;
    }
    
}

//left button
-(void)navLeftTap{
    [BT_debugger showIt:self message:@"navLeftTap (super)"];
    
    //appDelegate remebers the screen we are unloading.
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //if the screen we are coming from has an audio track, it may have "audioStopsOnScreenExit"...
    if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"audioStopsOnScreenExit" defaultValue:@""] isEqualToString:@"1"]){
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"stopping audio on screen exit for screen with itemId:%@", [self.screenData itemId]]];
        if(appDelegate.audioPlayer != nil){
            [appDelegate.audioPlayer stopAudio];
        }
    }
    
    //our custom navigation controller has over-riden the popViewControllerAnimated method. It refers to the menu item that
    //was "remembered" in the rootApp when it was tapped. It uses this info to determine how to "reverse" the transition.
    [[self navigationController] popViewControllerAnimated:YES];
    
    
}

//right button
-(void)navRightTap{
    [BT_debugger showIt:self message:@"navRightTap (super)"];
    
    //appDelegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //get possible itemId of the screen to load
    NSString *loadScreenItemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"navBarRightButtonTapLoadScreenItemId" defaultValue:@""];
    
    //get possible nickname of the screen to load
    NSString *loadScreenNickname = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"navBarRightButtonTapLoadScreenNickname" defaultValue:@""];
    
    //bail if load screen = "none"
    if([loadScreenItemId isEqualToString:@"none"]){
        return;
    }
    
    //check for loadScreenWithItemId THEN loadScreenWithNickname THEN loadScreenObject
    BT_item *screenObjectToLoad = nil;
    if([loadScreenItemId length] > 1){
        screenObjectToLoad = [appDelegate.rootApp getScreenDataByItemId:loadScreenItemId];
    }else{
        if([loadScreenNickname length] > 1){
            screenObjectToLoad = [appDelegate.rootApp getScreenDataByNickname:loadScreenNickname];
        }else{
            if([self.screenData.jsonVars objectForKey:@"navBarRightButtonTapLoadScreenObject"]){
                screenObjectToLoad = [[BT_item alloc] init];
                [screenObjectToLoad setItemId:[[self.screenData.jsonVars objectForKey:@"navBarRightButtonTapLoadScreenObject"] objectForKey:@"itemId"]];
                [screenObjectToLoad setItemNickname:[[self.screenData.jsonVars objectForKey:@"navBarRightButtonTapLoadScreenObject"] objectForKey:@"itemNickname"]];
                [screenObjectToLoad setItemType:[[self.screenData.jsonVars objectForKey:@"navBarRightButtonTapLoadScreenObject"] objectForKey:@"itemType"]];
                [screenObjectToLoad setJsonVars:[self.screenData.jsonVars objectForKey:@"navBarRightButtonTapLoadScreenObject"]];
            }
        }
    }
    
    //if right button is "home" or "goHome"
    if([loadScreenItemId isEqualToString:@"home"] || [loadScreenItemId isEqualToString:@"goHome"]){
        
        //pop to root view controller...
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        //bail
        return;
    }
    
    
    //if it's "showAudioControls"
    if([loadScreenItemId isEqualToString:@"showAudioControls"]){
        
        //delegate controls audio, bail
        [appDelegate showAudioControls];
        return;
        
    }
    
    //load next screen if it's not nil
    if(screenObjectToLoad != nil){
        
        //build a temp menu-item to pass to screen load method. We need this because the transition type is in the menu-item
        BT_item *tmpMenuItem = [[BT_item alloc] init];
        
        //build an NSDictionary of values for the jsonVars property
        NSDictionary *tmpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"unused", @"itemId",
                                       [self.screenData.jsonVars objectForKey:@"navBarRightButtonTapTransitionType"], @"transitionType",
                                       nil];
        [tmpMenuItem setJsonVars:tmpDictionary];
        [tmpMenuItem setItemId:@"0"];
        
        //load the next screen
        [self handleTapToLoadScreen:screenObjectToLoad theMenuItemData:tmpMenuItem];
        
    }else{
        //show message
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"%@",NSLocalizedString(@"menuTapError",@"The application doesn't know how to handle this action?")]];
    }
    
    
}

//toggleTopBar...
-(void)toggleTopBar:(NSString *)withOptions{
    [BT_debugger showIt:self message:@"toggleTopBar (super)"];
    
    /*
     withOptions argument will be "status" "nav" or "both"
     iOS 7 animates status bar automatically, previous versions do not.
     This means we need to figure out how to manually animate the bar if device is
     not running iOS 7.
     */
    
    int iosVer = 7;
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        iosVer = 6;
    }
    
    //determine final position of navBar if we animate it manually...
    CGFloat navBarHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 44 : 44;
    CGRect navBarFrame;
    
    //show / hide status bar...
    if([withOptions isEqualToString:@"status"] || [withOptions isEqualToString:@"both"]){
        if([[UIApplication sharedApplication] isStatusBarHidden]){
            [[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:UIStatusBarAnimationFade];
            navBarFrame = CGRectMake(0, 20, self.view.bounds.size.width, navBarHeight);
        }else{
            [[UIApplication sharedApplication] setStatusBarHidden:TRUE withAnimation:UIStatusBarAnimationFade];
            navBarFrame = CGRectMake(0, 0, self.view.bounds.size.width, navBarHeight);
        }
        
        //manually animate navBar if not iOS 7...
        if(iosVer < 7){
            [UIView animateWithDuration:0.25
                             animations:^{
                                 [self.navigationController.navigationBar setFrame:navBarFrame];
                             }
                             completion:^(BOOL finished){
                                 
                             }];
        }
        
    }
    
    //show / hide navigation bar...
    if([withOptions isEqualToString:@"nav"] || [withOptions isEqualToString:@"both"]){
        if([[self.navigationController navigationBar] isHidden]){
            [[self navigationController] setNavigationBarHidden:FALSE animated:TRUE];
        }else{
            [[self navigationController] setNavigationBarHidden:TRUE animated:TRUE];
        }
        
    }
    
}

//setTopBarTitle...
-(void)setTopBarTitle:(NSString *)theTitle{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"setTopBarTitle (super): %@", theTitle]];
    [[self navigationItem] setTitle:theTitle];
}



//show audio controls
-(void)showAudioControls{
    [BT_debugger showIt:self message:@"showAudioControls (super)"];
    
    //appDelegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showAudioControls];
    
}

//showContextMenu...
-(void)showContextMenu{
    [BT_debugger showIt:self message:@"showContextMenu (super)"];
    
    //appDelegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //get the contextMenu data for this screen...
    NSString *contextMenuItemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"contextMenuItemId" defaultValue:@""];
    BT_item *contextMenuData = nil;
    if([contextMenuItemId length] > 1){
        contextMenuData = [appDelegate.rootApp getMenuDataByItemId:contextMenuItemId];
        if(contextMenuData != nil){
            
            //tell the contextMenu to load it's data...
            [appDelegate.contextMenu setMenuData:contextMenuData];
            [appDelegate.contextMenu loadData];
            
            //show the menu...
            [appDelegate showContextMenu];
            
            
        }
    }
    
    
}

//show alert
-(void)showAlert:(NSString *)theTitle theMessage:(NSString *)theMessage alertTag:(int)alertTag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:theTitle message:theMessage delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", "OK") otherButtonTitles:nil];
    [alertView setTag:alertTag];
    [alertView show];
}


//"OK" clicks on UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"alertView (super) clickedButtonAtIndex: %li", (long)buttonIndex]];
    
    //handles OK click after emailing an image from BT_screen_imageEmail
    if([alertView tag] == 99){
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    //handles OK click after sharing from BT_screen_shareFacebook or BT_screen_shareTwitter
    if([alertView tag] == 199){
        [self navLeftTap];
    }
    
}


//createAdBannerView
-(void)createAdBannerView{
    Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if(classAdBannerView != nil){
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"createiAdBannerView (super): %@", @""]];
        self.adView = [[UIView alloc] initWithFrame:CGRectZero];
        self.adView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
        [self.adView setTag:94];
        self.adBannerView = [[classAdBannerView alloc] initWithFrame:CGRectZero];
        [self.adBannerView setDelegate:self];
        [self.adBannerView setTag:955];
        
        if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
            [adBannerView setCurrentContentSizeIdentifier: ADBannerContentSizeIdentifierLandscape];
        }else{
            [adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
        }
        
        [self.adView setFrame:[BT_viewUtilities frameForAdView:self theScreenData:screenData]];
        [adView setBackgroundColor:[UIColor clearColor]];
        [self.adView addSubview:self.adBannerView];
        [self.view addSubview:adView];
        [self.view bringSubviewToFront:adView];
    }
}

//showHideAdView
-(void)showHideAdView{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"showHideAdView (super): %@", @""]];
    if(adBannerView != nil){
        
        if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
            [adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
        }else{
            [adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
        }
        
        [UIView beginAnimations:@"positioniAdView" context:nil];
        [UIView setAnimationDuration:1.5];
        if(adBannerViewIsVisible){
            [self.adView setAlpha:1.0];
        }else{
            [self.adView setAlpha:.0];
        }
        [UIView commitAnimations];
    }
}

//banner view did load...
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"bannerViewDidLoadAd (super)%@", @""]];
    if(!adBannerViewIsVisible) {
        adBannerViewIsVisible = YES;
        [self showHideAdView];
    }
}

//banner view failed to get add
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"didFailToReceiveAdWithError (super): %@", [error localizedDescription]]];
    if (adBannerViewIsVisible){
        adBannerViewIsVisible = NO;
        [self showHideAdView];
    }
}

//loadScreenWithItemId...
-(void)loadScreenWithItemId:(NSString *)theItemId{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"loadScreenWithItemId (super) itemId:%@", theItemId]];
    
    //appDelegate...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //get the JSON data for screen with this itemId...
    BT_item *screenToLoad = [appDelegate.rootApp getScreenDataByItemId:theItemId];
    
    //use the handleTapToLoadScreen method...
    [self handleTapToLoadScreen:screenToLoad theMenuItemData:nil];
    
}

//loadScreenWithNickname...
-(void)loadScreenWithNickname:(NSString *)theNickname{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"loadScreenWithNickname (super) Nickname:%@", theNickname]];
    
    //appDelegate...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //get the JSON data for screen with this nickname...
    BT_item *screenToLoad = [appDelegate.rootApp getScreenDataByNickname:theNickname];
    
    //use the handleTapToLoadScreen method...
    [self handleTapToLoadScreen:screenToLoad theMenuItemData:nil];
}

//loadScreenObject...
-(void)loadScreenObject:(BT_item *)theScreenData{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"loadScreenObject (super) itemId:%@", [theScreenData itemId]]];
    [self handleTapToLoadScreen:theScreenData theMenuItemData:nil];
}


//handleTapToLoadScreen...
-(void)handleTapToLoadScreen:(BT_item *)theScreenData theMenuItemData:(BT_item *)theMenuItemData{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"handleTapToLoadScreen (super) loading nickname: \"%@\" itemId: %@ itemType: %@", [theScreenData itemNickname], [theScreenData itemId], [theScreenData itemType]]];
    
    //if the loadScreenItemId == "none".....
    if([[BT_strings getJsonPropertyValue:theMenuItemData.jsonVars nameOfProperty:@"loadScreenWithItemId" defaultValue:@""] isEqualToString:@"none"]){
        return;
    }
    
    //find the nav controller
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    //if the screen we are loading requires a login, we can't continue unless the user is logged in.
    //assume that the screen does not require a login.
    BOOL allowNextScreen = TRUE;
    if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"loginRequired" defaultValue:@"0"] isEqualToString:@"1"]){
        if(![[appDelegate.rootUser userIsLoggedIn] isEqualToString:@"1"]){
            allowNextScreen = FALSE;
        }
    }
    
    //show password protected message or continue...
    if(!allowNextScreen){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginRequired",@"~ Login Required ~")
                                                            message:NSLocalizedString(@"loginRequiredMessage", @"You are not logged in. A login is required to access this screen.")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                  otherButtonTitles:nil];
        [alertView setTag:101];
        [alertView show];
        
        //bail
        return;
        
    }
    if(allowNextScreen){
        
        //play a possible sound effect attached to the menu/button
        if([[BT_strings getJsonPropertyValue:theMenuItemData.jsonVars nameOfProperty:@"soundEffectFileName" defaultValue:@""] length] > 3){
            [appDelegate playSoundEffect:[BT_strings getJsonPropertyValue:theMenuItemData.jsonVars nameOfProperty:@"soundEffectFileName" defaultValue:@""]];
        }
        
        //if the screen we are coming from has an audio track, it may have "audioStopsOnScreenExit"...
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"audioStopsOnScreenExit" defaultValue:@""] isEqualToString:@"1"]){
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"stopping audio on screen exit for screen with itemId:%@", [self.screenData itemId]]];
            if(appDelegate.audioPlayer != nil){
                [appDelegate.audioPlayer stopAudio];
            }
        }
        
        //remember previous menu item before setting current menu item...
        [appDelegate.rootApp setPreviousMenuItemData:[appDelegate.rootApp currentMenuItemData]];
        
        //remember this  menu item as current...
        [appDelegate.rootApp setCurrentMenuItemData:theMenuItemData];
        
        //remember current screen object...
        [appDelegate.rootApp setCurrentScreenData:theScreenData];
        
        //remember previous screen object...
        [appDelegate.rootApp setPreviousScreenData:self.screenData];
        
        
        //some screens aren't screens at all! Like "Call Us" and "Email Us" item. In these cases, we only
        //trigger a method and do not load a BT_screen view controller.
        
        //place call
        if([[theScreenData itemType] isEqualToString:@"BT_screen_call"] ||
           [[theScreenData itemType] isEqualToString:@"BT_placeCall"]){
            
            if([appDelegate.rootDevice canMakePhoneCalls]){
                
                //trigger the place-call method
                [self placeCallWithScreenData:theScreenData];
                
            }else{
                
                //show error message
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"callsNotSupportedTitle",@"Calls Not Supported")
                                                                    message:NSLocalizedString(@"callsNotSupportedMessage", @"Placing calls is not supported on this device.")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                          otherButtonTitles:nil];
                [alertView setTag:102];
                [alertView show];
            }
            
            //bail
            return;
        }
        
        //send email or share email
        if([[theScreenData itemType] isEqualToString:@"BT_screen_email"] ||
           [[theScreenData itemType] isEqualToString:@"BT_sendEmail"] ||
           [[theScreenData itemType] isEqualToString:@"BT_shareEmail"] ||
           [[theScreenData itemType] isEqualToString:@"BT_screen_shareEmail"]){
            
            if([appDelegate.rootDevice canSendEmails]){
                
                //trigger the email method
                [self sendEmailWithScreenData:theScreenData imageAttachment:nil imageAttachmentName:nil];
                
            }else{
                
                //show error message
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"emailsNotSupportedTitle",@"Email Not Supported")
                                                                    message:NSLocalizedString(@"emailsNotSupportedMessage", @"Sending eamils is not supported on this device.")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                          otherButtonTitles:nil];
                [alertView setTag:103];
                [alertView show];
                
            }
            
            //bail
            return;
            
        }
        
        //send SMS or share SMS
        if([[theScreenData itemType] isEqualToString:@"BT_screen_sms"] ||
           [[theScreenData itemType] isEqualToString:@"BT_sendSms"] ||
           [[theScreenData itemType] isEqualToString:@"BT_sendSMS"] ||
           [[theScreenData itemType] isEqualToString:@"BT_shareSms"] ||
           [[theScreenData itemType] isEqualToString:@"BT_shareSMS"] ||
           [[theScreenData itemType] isEqualToString:@"BT_screen_shareSms"]){
            
            if([appDelegate.rootDevice canSendSMS]){
                
                //trigger the SMS method
                [self sendTextMessageWithScreenData:theScreenData];
                
            }else{
                
                //show error message
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"textMessageNotSupportedTitle", "SMS Not Supported")
                                                                    message:NSLocalizedString(@"textMessageNotSupportedMessage",  "Sending SMS / Text messages is not supported on this device.")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                          otherButtonTitles:nil];
                [alertView setTag:104];
                [alertView show];
            }
            
            //bail
            return;
            
        }
        
        //BT_screen_video
        if([[theScreenData itemType] isEqualToString:@"BT_screen_video"]){
            
            NSString *localFileName = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"localFileName" defaultValue:@""];
            NSString *dataURL = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@""];
            NSURL *escapedUrl = nil;
            
            /*
             video file
             --------------------------------
             a)	No dataURL is provided in the screen data - use the localFileName configured in the screen data
             b)	A dataURL is provided, check for local copy, download if not available
             
             */
            if([dataURL length] < 3){
                if([localFileName length] > 3){
                    if([BT_fileManager doesFileExistInBundle:localFileName]){
                        NSString *rootPath = [[NSBundle mainBundle] resourcePath];
                        NSString *filePath = [rootPath stringByAppendingPathComponent:localFileName];
                        escapedUrl = [NSURL fileURLWithPath:filePath isDirectory:NO];
                    }
                }
            }else{
                //merge possible varialbes in url
                dataURL = [BT_strings mergeBTVariablesInString:dataURL];
                escapedUrl = [NSURL URLWithString:[dataURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
            
            //show movie player controller...
            if(escapedUrl != nil){
                [BT_debugger showIt:self message:[NSString stringWithFormat:@"Showing moving player controller%@", @""]];
                AVPlayerViewController *moviePlayerController = [[AVPlayerViewController alloc] init];
                [moviePlayerController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                
                //get the navigation controller...
                //BT_navController *tmpController = [appDelegate getNavigationController];
                //[tmpController presentModalViewController:moviePlayerController animated:YES];
                
                //[self.navigationController presentModalViewController:moviePlayerController animated:YES];
                [self presentViewController:moviePlayerController animated:TRUE completion:^{}];
                
                
                
            }
            
            //bail
            return;
            
        }//end if video
        
        //BT_screen_launchNativeApp
        if([[theScreenData itemType] isEqualToString:@"BT_screen_launchNativeApp"] ||
           [[theScreenData itemType] isEqualToString:@"BT_launchNativeApp"]){
            /*
             Launching native app requires an "appType" and a "dataURL"
             App Types:	browser, youTube, googleMaps, musicStore, appStore, mail, dialer, sms
             */
            NSString *appToLaunch = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"appToLaunch" defaultValue:@""];
            NSString *dataURL = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@""];
            NSString *encodedURL = @"";
            NSString *alertTitle = @"";
            NSString *alertMessage = @"";
            if([dataURL length] > 1){
                encodedURL =  [dataURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            }
            if([appToLaunch length] > 1 && [encodedURL length] > 3){
                
                //browser, musicStore, appStore
                if([appToLaunch isEqualToString:@"browser"] || [appToLaunch isEqualToString:@"googleMaps"]
                   || [appToLaunch isEqualToString:@"musicStore"] || [appToLaunch isEqualToString:@"appStore"]
                   || [appToLaunch isEqualToString:@"youTube"]){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedURL]];
                }
                
                //google maps
                if([appToLaunch isEqualToString:@"googleMaps"]){
                    NSString *toAddress = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", encodedURL];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:toAddress]];
                }
                
                //mail
                if([appToLaunch isEqualToString:@"mail"]){
                    if([appDelegate.rootDevice canSendEmails]){
                        NSString *emailAddress = [NSString stringWithFormat:@"mailto:%@", encodedURL];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailAddress]];
                    }else{
                        alertTitle = NSLocalizedString(@"emailsNotSupportedTitle", "Email Not Supported");
                        alertMessage = NSLocalizedString(@"emailsNotSupportedMessage", "Sending emails is not supported on this device");
                    }
                }
                
                //dialer
                if([appToLaunch isEqualToString:@"dialer"]){
                    if([appDelegate.rootDevice canMakePhoneCalls]){
                        NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@", encodedURL];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
                    }else{
                        alertTitle = NSLocalizedString(@"callsNotSupportedTitle", "Calls Not Supported");
                        alertMessage = NSLocalizedString(@"emailsNotSupportedTitle", "Placing calls is not supported on this device");
                    }
                }
                
                //sms
                if([appToLaunch isEqualToString:@"sms"]){
                    if([appDelegate.rootDevice canSendSMS]){
                        NSString *smsAddress = [NSString stringWithFormat:@"sms:%@", encodedURL];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:smsAddress]];
                    }else{
                        alertTitle = NSLocalizedString(@"textMessageNotSupportedTitle", "SMS Not Supported");
                        alertMessage = NSLocalizedString(@"textMessageNotSupportedMessage", "Sending SMS / Text messages is not supported on this device");
                    }
                }
                
                
                //book store URL
                if([appToLaunch isEqualToString:@"bookStore"]){
                    NSString *iBooksAddress = [NSString stringWithFormat:@"itms-books:%@", encodedURL];
                    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:iBooksAddress]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iBooksAddress]];
                    }else{
                        alertTitle = NSLocalizedString(@"customURLSchemeNotSupported", "Can't Open Application");
                        alertMessage = NSLocalizedString(@"customURLSchemeNotSupportedMessage", "This device cannot open the application with this URL Scheme");
                    }
                }
                
                
                //customURLScheme
                if([appToLaunch isEqualToString:@"customURLScheme"]){
                    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:encodedURL]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedURL]];
                    }else{
                        alertTitle = NSLocalizedString(@"customURLSchemeNotSupported", "Can't Open Application");
                        alertMessage = NSLocalizedString(@"customURLSchemeNotSupportedMessage", "This device cannot open the application with this URL Scheme");
                    }
                }
                
                //show alert?
                if([alertMessage length] > 3){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                        message:alertMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                              otherButtonTitles:nil];
                    [alertView setTag:105];
                    [alertView show];
                }
                
                
            }//dataURL, encodedURL length
            
            //bail
            return;
            
        }//end if launching native app
        
        
        ////////////////////////////////////////////////////////////////////////
        //if we are here, we are loading a new screen object
        UIViewController *theNextViewController = [appDelegate.rootApp getViewControllerForScreen:theScreenData];
        if(theNextViewController != nil){
            
            
            //if the screen we are loading has an audio track, spawn a new thread to load it...
            if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3 || [[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 3){
                
                if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3){
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"this screen uses a background sound from the project bundle: %@", [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""]]];
                }else{
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"this screen uses a background sound from a URL: %@", [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""]]];
                }
                
                //load audio for this screen in another thread
                [NSThread detachNewThreadSelector: @selector(loadAudioForScreen:) toTarget:appDelegate withObject:theScreenData];
                
            }
            
            //always hide the lower tab-bar when screens transition in unless it's overridden
            BOOL hideBottomBar = FALSE;
            if([[BT_strings getJsonPropertyValue:appDelegate.rootApp.rootTheme.jsonVars nameOfProperty:@"hideBottomTabBarWhenScreenLoads" defaultValue:@""] isEqualToString:@"1"]){
                hideBottomBar = TRUE;
            }
            if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"hideBottomTabBarWhenScreenLoads" defaultValue:@""] length] > 0){
                if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"hideBottomTabBarWhenScreenLoads" defaultValue:@"1"] isEqualToString:@"0"]){
                    hideBottomBar = FALSE;
                }else{
                    hideBottomBar = TRUE;
                }
            }
            
            //always hide the bottom tab-bar for quiz screens
            if([[theScreenData itemType] isEqualToString:@"BT_screen_quiz"]){
                hideBottomBar = TRUE;
            }
            
            //hide bottom bar if needed
            [theNextViewController setHidesBottomBarWhenPushed:hideBottomBar];
            
            //always hide the "back" button. A custom button is added in BT_viewUtilities.configureBackgroundAndNavBar
            [theNextViewController.navigationItem setHidesBackButton:TRUE];
            
            //tabbed app's handle pushing views different than non-tabbed apps...
            if([appDelegate.rootApp.tabs count] < 1){
                
                //non-tabbed app, ask self to push the next view...
                [appDelegate.rootApp.rootNavController pushViewController:theNextViewController animated:YES];
                
            }else{
                
                //ask the navigation controller for the selected tab to push the next view...
                BT_navController *selNavController = (BT_navController *)[appDelegate.rootApp.rootTabBarController selectedViewController];
                [selNavController pushViewController:theNextViewController animated:TRUE];
                
            }
            
            
            
            
            
            
        }//theNextViewController...
    }//allowNextScreen
}





//placeCallWithScreenData...
-(void)placeCallWithScreenData:(BT_item *)theScreenData{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"placeCallWithScreenData (super). Nickname: \"%@\" itemId: %@ itemType: %@", [theScreenData itemNickname], [theScreenData itemId], [theScreenData itemType]]];
    
    //WE WILL NOT BE HERE IF THE DEVICE IS NOT CAPABLE OF MAKING CALLS
    
    //appDelegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate.rootDevice canMakePhoneCalls] == TRUE){
        
        
        /*
         IMPORTANT. Numbers should not contain parenthesis, dashes are better.
         Exmaple: 123-123-1234 is better than (123)123-1234
         Not sure why but crazy results happen sometimes?
         */
        
        NSString *numberToCall = [NSString stringWithFormat:@"tel:%@", [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"number" defaultValue:@""]];
        if([numberToCall length] > 5){
            
#if TARGET_IPHONE_SIMULATOR
            
            //show alert
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"callsNotSupportedTitle", "Calls Not Supported")
                                                                message:NSLocalizedString(@"callsNotSupportedMessage", "Placing calls is not supported on this device")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                      otherButtonTitles:nil];
            [alertView show];
            
#else
            //not in simulator...
            
            
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"launching dialer (super): %@", numberToCall]];
            if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:numberToCall]]){
                
                //show alert
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:NSLocalizedString(@"errorTitle", "~ Error ~")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                          otherButtonTitles:nil];
                [alertView show];
                
            }
            
#endif
            
            
        }else{
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"Could not launch dialer, no phone number?%@", @""]];
            
        }
        
        
    }else{
        
        //show alert...
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"callsNotSupportedTitle", "Calls Not Supported")
                                                        message:NSLocalizedString(@"callsNotSupportedMessage", "You need to be using an iPhone to make phone calls")
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"ok", "OK") otherButtonTitles:nil];
        [alert show];
        
    }
}



//sendEmailWithScreenData...
-(void)sendEmailWithScreenData:(BT_item *)theScreenData imageAttachment:(UIImage *)imageAttachment imageAttachmentName:(NSString *)imageAttachmentName{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"sendEmailWithScreenData (super) nickname: \"%@\" itemId: %@ itemType: %@", [theScreenData itemNickname], [theScreenData itemId], [theScreenData itemType]]];
    
    //mail composer
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if(mailClass != nil){
        if([mailClass canSendMail]){
            
            //ask the app's delegate for the current view controller...
            robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
            BT_viewController *theViewController = [appDelegate getViewController];
            
            //setup the built in compose sheet...
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            //get subject
            if([theScreenData.jsonVars objectForKey:@"emailSubject"]){
                [picker setSubject:[theScreenData.jsonVars objectForKey:@"emailSubject"]];
            }
            
            //get to address
            if([theScreenData.jsonVars objectForKey:@"emailToAddress"]){
                NSArray *toRecipients = [NSArray arrayWithObject:[theScreenData.jsonVars objectForKey:@"emailToAddress"]];
                [picker setToRecipients:toRecipients];
            }
            
            //attach image if included
            if(imageAttachment != nil){
                NSData *imageData = UIImageJPEGRepresentation(imageAttachment, 1.0);
                if(imageData){
                    [picker addAttachmentData:imageData mimeType:@"image/jpeg" fileName:imageAttachmentName];
                }
            }
            
            
            //get body
            if([theScreenData.jsonVars objectForKey:@"emailMessage"]){
                
                NSString *emailMessage = [theScreenData.jsonVars objectForKey:@"emailMessage"];
                [picker setMessageBody:emailMessage isHTML:NO];
                
            }else{
                
                //if we have a subject set...
                NSString *emailSubject = @"";
                if([theScreenData.jsonVars objectForKey:@"emailSubject"]){
                    emailSubject = [theScreenData.jsonVars objectForKey:@"emailSubject"];
                }
                
                //empty message body or the imageTitle of an image we are emailing (if it has an imageTitle)..
                NSString *imageTitle = [BT_strings getPrefString:@"emailImageTitle"];
                if([emailSubject length] < 1){
                    [picker setSubject:imageTitle];
                }
                
                //erase emailImageTitle for next time...
                [BT_strings setPrefString:@"emailImageTitle" valueOfPref:@""];
                
            }
            
            //navigation bar color depends on iOS7 or lower...
            if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
                [[picker navigationBar] setTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:theScreenData]];
            }else{
                [[picker navigationBar] setBarTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:self.screenData]];
            }
            
            //show the model view...
            [theViewController presentViewController:picker animated:YES completion:nil];
            
            
        }//can send mail
    }
    
}


//sendEmailWithAttachmentFromScreenData...
-(void)sendEmailWithAttachmentFromScreenData:(BT_item *)theScreenData theAttachmentData:(NSData *)theAttachmentData attachmentName:(NSString *)attachmentName{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"sendEmailWithAttachmentFromScreenData (super) nickname: \"%@\" itemId: %@ itemType: %@", [theScreenData itemNickname], [theScreenData itemId], [theScreenData itemType]]];
    
    //mail composer
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if(mailClass != nil){
        if([mailClass canSendMail]){
            
            //ask the app's delegate for the current view controller...
            robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
            BT_viewController *theViewController = [appDelegate getViewController];
            
            //setup the built in compose sheet...
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            //set possible subject
            if([theScreenData.jsonVars objectForKey:@"emailSubject"]){
                [picker setSubject:[theScreenData.jsonVars objectForKey:@"emailSubject"]];
            }
            
            //set possible to address
            if([theScreenData.jsonVars objectForKey:@"emailToAddress"]){
                NSArray *toRecipients = [NSArray arrayWithObject:[theScreenData.jsonVars objectForKey:@"emailToAddress"]];
                [picker setToRecipients:toRecipients];
            }
            
            //set possible email message
            if([theScreenData.jsonVars objectForKey:@"emailMessage"]){
                NSString *emailMessage = [theScreenData.jsonVars objectForKey:@"emailMessage"];
                [picker setMessageBody:emailMessage isHTML:NO];
            }
            
            
            //set possible attachment
            if(theAttachmentData != nil){
                [picker addAttachmentData:theAttachmentData mimeType:@"application/octet-stream" fileName:attachmentName];
            }
            
            
            //navigation bar color depends on iOS7 or lower...
            if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
                [[picker navigationBar] setTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:theScreenData]];
            }else{
                [[picker navigationBar] setBarTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:self.screenData]];
            }
            
            //show the model view...
            [theViewController presentViewController:picker animated:YES completion:nil];
            
            
        }//can send mail
    }
    
}



//sendEmailFromWebLink... (triggered when link with "mailto" is clicked in a web-view)
-(void)sendEmailFromWebLink:(BT_item *)theScreenData toAddress:(NSString *)toAddress{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"sendEmailFromWebView (super): %@", toAddress]];
    
    //mail composer
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if(mailClass != nil){
        if([mailClass canSendMail]){
            
            //ask the app's delegate for the current view controller...
            robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
            BT_viewController *theViewController = [appDelegate getViewController];
            
            //setup the built in compose sheet...
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            //set to address
            NSArray *toRecipients = [NSArray arrayWithObject:toAddress];
            [picker setToRecipients:toRecipients];
            
            //empty message body
            NSString *emailBody = @"";
            [picker setMessageBody:emailBody isHTML:NO];
            
            //navigation bar color depends on iOS7 or lower...
            if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
                [[picker navigationBar] setTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:theScreenData]];
            }else{
                [[picker navigationBar] setBarTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:self.screenData]];
            }
            
            //show the model view...
            [theViewController presentViewController:picker animated:YES completion:nil];
            
            
        }//can send mail
    }
    
}



//sendTextMessageWithScreenData...
-(void)sendTextMessageWithScreenData:(BT_item *)theScreenData{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"sendTextMessageWithScreenData (super) nickname: \"%@\" itemId: %@ itemType: %@", [theScreenData itemNickname], [theScreenData itemId], [theScreenData itemType]]];
    
    //SMS composer
    Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if(smsClass != nil && [MFMessageComposeViewController canSendText]){
        
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText]){
            
            //ask the app's delegate for the current view controller...
            robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
            BT_viewController *theViewController = [appDelegate getViewController];
            
            //set delegate on the picker...
            picker.messageComposeDelegate = self;
            
            //set recipients
            if([theScreenData.jsonVars objectForKey:@"textToNumber"]){
                NSArray *toRecipients = [NSArray arrayWithObject:[theScreenData.jsonVars objectForKey:@"textToNumber"]];
                [picker setRecipients:toRecipients];
            }
            
            //set message body
            if([theScreenData.jsonVars objectForKey:@"textMessage"]){
                [picker setBody:[theScreenData.jsonVars objectForKey:@"textMessage"]];
            }
            
            //navigation bar color depends on iOS7 or lower...
            if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
                [[picker navigationBar] setTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:theScreenData]];
            }else{
                [[picker navigationBar] setBarTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:self.screenData]];
            }
            
            //show the model view...
            [theViewController presentViewController:picker animated:YES completion:nil];
            
        }
    }
    
    
}



//mailComposeController...
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [BT_debugger showIt:self message:@"mailComposeController (super):didFinishComposingMail"];
    [self dismissModalViewControllerAnimated:YES];
    
    //delegate.
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //if this is an iPad AND our "currentScreenData" is BT_screen_imageEmail
    if([appDelegate.rootDevice isIPad]){
        if([[appDelegate.rootApp.currentScreenData.jsonVars objectForKey:@"itemType"] isEqualToString:@"BT_screen_imageEmail"]){
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"emailImageDone", "Re-load this screen to re-start the process or to send another message") delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", "OK") otherButtonTitles:nil];
            [alertView show];
            
        }
        
    }//is iPad
    
}


//messageComposeViewController...
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [BT_debugger showIt:self message:@"messageComposeViewController (super): didFinishComposingSMS"];
    [self dismissModalViewControllerAnimated:YES];
    
}





/////////////////////////////////////////////////////////////////////
//rotation methods...
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"shouldAutorotateToInterfaceOrientation (super) screen itemId: %@", [self.screenData itemId]]];
    
    //appDelegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //allow / dissallow rotations
    BOOL canRotate = TRUE;
    
    if([appDelegate.rootDevice isIPad]){
        canRotate = TRUE;
    }else{
        //should we prevent rotations on small devices?
        if([appDelegate.rootApp.jsonVars objectForKey:@"allowRotation"]){
            if([[appDelegate.rootApp.jsonVars objectForKey:@"allowRotation"] isEqualToString:@"largeDevicesOnly"]){
                canRotate = FALSE;
            }
        }
    }
    
    //can it rotate?
    if(canRotate){
        return YES;
    }else{
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
    //we should not get here
    return YES;
    
}



//will rotate
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"willRotateToInterfaceOrientation (super) screen itemId: %@", [self.screenData itemId]]];
    
    //delegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //some screens need to reload...
    UIViewController *theViewController;
    int selectedTab = 0;
    if([appDelegate.rootApp.tabs count] > 0){
        selectedTab = (int)[appDelegate.rootApp.rootTabBarController selectedIndex];
        theViewController = [[appDelegate.rootApp.rootTabBarController.viewControllers objectAtIndex:selectedTab] visibleViewController];
    }else{
        theViewController = [appDelegate.rootApp.rootNavController visibleViewController];
    }
    
    //if we have an ad view we may need to modify it's layout...
    for(UIView* subView in [theViewController.view subviews]){
        if(subView.tag == 94){
            for(UIView* subView_2 in [subView subviews]){
                if(subView_2.tag == 955){
                    
                    ADBannerView *theAdView = (ADBannerView *)subView_2;
                    SEL selector = NSSelectorFromString(@"setCurrentContentSizeIdentifier:");
                    if([subView_2 respondsToSelector:selector]){
                        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
                            [theAdView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
                        }else{
                            [theAdView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
                        }
                    }
                    
                    
                }
            }
            break;
        }
    }
    
    
    
    //if this view controller has a property named "rotating" set it to false...
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = NSSelectorFromString(@"setIsRotating");
    if ([theViewController respondsToSelector:selector]) {
        [theViewController performSelector:selector];
    }
#pragma clang diagnostic pop
    
    
}


//did rotate
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"didRotateFromInterfaceOrientation (super) screen itemId: %@", [self.screenData itemId]]];
    
    //delegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //hide context menu...
    [appDelegate hideContextMenu];
    
    UIViewController *theViewController;
    int selectedTab = 0;
    if([appDelegate.rootApp.tabs count] > 0){
        selectedTab = (int)[appDelegate.rootApp.rootTabBarController selectedIndex];
        theViewController = [[appDelegate.rootApp.rootTabBarController.viewControllers objectAtIndex:selectedTab] visibleViewController];
    }else{
        theViewController = [appDelegate.rootApp.rootNavController visibleViewController];
    }
    
    //if this view controller has a property named "rotating" set it to false...
    SEL sel1 = NSSelectorFromString(@"rotating");
    if([theViewController respondsToSelector:sel1]) {
        [theViewController setValue:0 forKey:@"rotating"];
    }
    
    
    //some screens need to re-build their layout...If a plugin has a method called
    //"layoutScreen" we trigger it everytime the device rotates. The plugin author can
    //create this method in the UIViewController (layoutScreen) if they need something to
    //happen after rotation occurs.
    
    
    //if this view controller has a property named "rotating" set it to false...This for sure
    //is used in the Image Gallery plugin...
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel2 = NSSelectorFromString(@"setNotRotating");
    if ([theViewController respondsToSelector:sel2]) {
        [theViewController performSelector:sel2];
    }
#pragma clang diagnostic pop
    
    
    //some screens need to re-build their layout...If a plugin has a method called
    //"layoutScreen" we trigger it everytime the device rotates. The plugin author can
    //create this method in the UIViewController (layoutScreen) if they need something to
    //happen after rotation occurs.
    
    //if this view controller has a "layoutScreen" method, trigger it...
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel3 = NSSelectorFromString(@"layoutScreen");
    if([theViewController respondsToSelector:sel3]){
        [theViewController performSelector:sel3];
    }
#pragma clang diagnostic pop
    
    
}



@end







