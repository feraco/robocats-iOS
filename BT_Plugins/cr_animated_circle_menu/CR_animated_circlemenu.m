//
// Animated Cirlce Menu
// Copyright 2013, Chris Ruddell, churchphoneapps.com
// All rights reserved.
//


//  Open Source Copyright Information:
//
//  Original files named:
//
//  KYCircleMenu.h
//  KYCircleMenu
//
//  Created by Kaijie Yu on 2/1/12.
//  Copyright (c) 2012 Kjuly. All rights reserved.
//

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


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JSON.h"
#import "BT_application.h"
#import "BT_strings.h"
#import "BT_viewUtilities.h"
#import "robocats_appDelegate.h"
#import "BT_item.h"
#import "BT_debugger.h"
#import "CR_animated_circlemenu.h"





@implementation CR_animated_circlemenu

@synthesize menuItems, buttonLabel, menu, centerButton, isOpening, isClosed, isInProcessing, centerButtonBackgroundImageName, centerButtonImageName;

- (void)loadView {
    [BT_debugger showIt:self message:@"loadView"];
    
    //start by filling the list from the configuration file, use these if we can't get anything from a URL
	if([[self.screenData jsonVars] objectForKey:@"childItems"]){
        
		//init the items array
		self.menuItems = [[NSMutableArray alloc] init];
        
		NSArray *tmpMenuItems = [[self.screenData jsonVars] objectForKey:@"childItems"];
		for(NSDictionary *tmpMenuItem in tmpMenuItems){
			BT_item *thisMenuItem = [[BT_item alloc] init];
			thisMenuItem.itemId = [tmpMenuItem objectForKey:@"itemId"];
			thisMenuItem.itemType = [tmpMenuItem objectForKey:@"itemType"];
			thisMenuItem.jsonVars = tmpMenuItem;
			[self.menuItems addObject:thisMenuItem];
		}
    }
    
    //get app Delegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //test for whether device is iPad or iPhone
    BOOL iAmiPad = [appDelegate.rootDevice isIPad];
    
    //grab menu size from JSON based on iPad or iPhone
    NSString *menuSizeString;
    if (iAmiPad) menuSizeString = [[self.screenData jsonVars] objectForKey:@"largeMenuSize"];
    else menuSizeString = [[self.screenData jsonVars] objectForKey:@"smallMenuSize"];
    
    //set default menu size to 280
    if ([menuSizeString length] == 0) menuSizeString = @"280";
    
    //get center Button Image and background image
    NSString *centerButtonImage;
    NSString *centerButtonBackground;
    if (iAmiPad) centerButtonImage = [[self.screenData jsonVars] objectForKey:@"largeCenterButtonImage"];
    else centerButtonImage = [[self.screenData jsonVars] objectForKey:@"smallCenterButtonImage"];
    if (iAmiPad) centerButtonBackground = [[self.screenData jsonVars] objectForKey:@"largeCenterButtonBackground"];
    else centerButtonBackground = [[self.screenData jsonVars] objectForKey:@"smallCenterButtonBackground"];
    //set default center button and background
    if ([centerButtonImage length] == 0) centerButtonImage = @"KYICircleMenuCenterButton.png";
    if ([centerButtonBackground length] == 0) centerButtonBackground = @"KYICircleMenuCenterButtonBackground.png";
    //get button size for all buttons
    NSString *allButtonSize;
    if (iAmiPad) allButtonSize = [[self.screenData jsonVars] objectForKey:@"largeButtonSize"];
    else allButtonSize = [[self.screenData jsonVars] objectForKey:@"smallButtonSize"];
    //set default button size to 64
    if ([allButtonSize length]==0) allButtonSize = @"64";
    

    isInProcessing = NO;
    isOpening      = NO;
    isClosed       = YES;
    shouldRecoverToNormalStatusWhenViewWillAppear = NO;
    
    buttonCount                     = [menuItems count];
    menuSize                        = [menuSizeString floatValue];
    buttonSize                      = [allButtonSize floatValue];
    centerbuttonSize                = [allButtonSize floatValue];
    centerButtonImageName           = centerButtonImage;
    centerButtonBackgroundImageName = centerButtonBackground;
    
    // Defualt value for triangle hypotenuse
    defaultTriangleHypotenuse     = (menuSize - buttonSize) / 2.f;
    minBounceOfTriangleHypotenuse = defaultTriangleHypotenuse - 12.f;
    maxBounceOfTriangleHypotenuse = defaultTriangleHypotenuse + 12.f;
    maxTriangleHypotenuse         = kKYCircleMenuViewHeight / 2.f;
    
    // Buttons' origin frame
    CGFloat originX = (menuSize - centerbuttonSize) / 2;
    
    int moveUp = 0;
    NSString *navBarStyle = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"navBarStyle" defaultValue:@""]uppercaseString];
    if ([navBarStyle isEqualToString:@"TRANSPARENT"] || [navBarStyle isEqualToString:@"HIDDEN"]) moveUp-=64;
    buttonOriginFrame = (CGRect){{originX, originX-moveUp}, {centerbuttonSize, centerbuttonSize}};
    
    
    CGFloat viewHeight = (self.navigationController.isNavigationBarHidden ? kKYCircleMenuViewHeight : kKYCircleMenuViewHeight - kKYCircleMenuNavigationBarHeight);
    CGRect frame = CGRectMake(0.f, 0.f, kKYCircleMenuViewWidth, viewHeight);
    UIView * view = [[UIView alloc] initWithFrame:frame];
    self.view = view;

    if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"includeAds" defaultValue:@"0"] isEqualToString:@"1"]){
        viewHeight -= 40;
    }
    
    if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"navBarStyle" defaultValue:@"hidden"] isEqualToString:@"solid"]){
        viewHeight -= 20;
    }

    //move label "up" a bit if app has tabs...
    if([appDelegate.rootApp.tabs count] > 0){
        viewHeight -= 50;
    }
    
    
    //set UILabel
    buttonLabel = [[UILabel alloc]init];
    CGFloat windowWidth = [UIScreen mainScreen].bounds.size.width;
    buttonLabel.frame = CGRectMake(0, viewHeight - 40, windowWidth, 40);
    buttonLabel.textAlignment = NSTextAlignmentCenter;
    buttonLabel.textColor = [UIColor blackColor];
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.text = @"";
    [self.view addSubview:buttonLabel];
    
}

- (void)viewDidLoad {
    [BT_debugger showIt:self message:@"viewDidLoad"];
    [super viewDidLoad];
    
    // Constants
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    CGFloat viewWidth  = CGRectGetWidth(self.view.frame);

    //get app Delegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Center Menu View
    CGRect centerMenuFrame = CGRectMake((viewWidth - menuSize) / 2, (viewHeight - menuSize) / 2, menuSize, menuSize);
    menu = [[UIView alloc] initWithFrame:centerMenuFrame];
    [menu setAlpha:0.f];
    [self.view addSubview:menu];
    
    //is iPad?
    BOOL iAmiPad = [appDelegate.rootDevice isIPad];
    
    // Add buttons to |ballmenu|, set it's origin frame to center
    for (int i = 1; i <= buttonCount; ++i) {
        BT_item *currentMenuItem = [menuItems objectAtIndex:(i-1)];
        NSString *buttonImageName;
        if (iAmiPad) buttonImageName = [[currentMenuItem jsonVars] objectForKey:@"largeImageName"];
        else buttonImageName = [[currentMenuItem jsonVars] objectForKey:@"smallImageName"];
        UIButton * button = [[UIButton alloc] initWithFrame:buttonOriginFrame];
        [button setOpaque:NO];
        [button setTag:i];
        [button setImage:[UIImage imageNamed:buttonImageName]
                forState:UIControlStateNormal];
        [button addTarget:self action:@selector(runButtonActions:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(showButtonLabel:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(hideButtonlabel:) forControlEvents:UIControlEventTouchUpOutside];
        [self.menu addSubview:button];
    }
    
    //move frame "up" a bit if app has tabs...
    int moveUp = 0;
    if([appDelegate.rootApp.tabs count] > 0){
        moveUp = 50;
    }
    
    NSString *navBarStyle = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"navBarStyle" defaultValue:@""]uppercaseString];
    if ([navBarStyle isEqualToString:@"TRANSPARENT"] || [navBarStyle isEqualToString:@"HIDDEN"]) moveUp-=64;
    
    
    // Main Button
    CGRect mainButtonFrame =
    CGRectMake((CGRectGetWidth(self.view.frame) - centerbuttonSize) / 2.f,
               ((CGRectGetHeight(self.view.frame) - centerbuttonSize) / 2.f) - moveUp,
               centerbuttonSize, centerbuttonSize);
    centerButton = [[UIButton alloc] initWithFrame:mainButtonFrame];
    [centerButton setBackgroundImage:[UIImage imageNamed:self.centerButtonBackgroundImageName]
                             forState:UIControlStateNormal];
    [centerButton setImage:[UIImage imageNamed:self.centerButtonImageName]
                   forState:UIControlStateNormal];
    [centerButton addTarget:self
                      action:@selector(toggle:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:centerButton];
    
    // Setup notification observer
    [self setupNotificationObserver];
    
    //create adView?
	if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"includeAds" defaultValue:@"0"] isEqualToString:@"1"]){
	   	[self createAdBannerView];
	}
}


- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    //get app Delegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //move frame "up" a bit if app has tabs...
    int moveUp = 0;
    if([appDelegate.rootApp.tabs count] > 0){
        moveUp = 50;
    }
    NSString *navBarStyle = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"navBarStyle" defaultValue:@""]uppercaseString];
    if ([navBarStyle isEqualToString:@"TRANSPARENT"] || [navBarStyle isEqualToString:@"HIDDEN"]) moveUp-=64;
    
    centerButton.frame = CGRectMake(((CGRectGetWidth(self.view.frame) - centerbuttonSize) / 2.f), (CGRectGetHeight(self.view.frame) - centerbuttonSize) / 2.f, centerbuttonSize, centerbuttonSize);
    CGSize frameSize = self.view.frame.size;
    CGSize theMenuSize = menu.frame.size;

    menu.frame = CGRectMake((frameSize.width - theMenuSize.width)/2, ((frameSize.height-theMenuSize.height)/2) + moveUp, theMenuSize.width, theMenuSize.height);
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [self releaseSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[BT_debugger showIt:self theMessage:@"viewWillAppear"];
	
    //show adView?
	if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"includeAds" defaultValue:@"0"] isEqualToString:@"1"]){
	    [self showHideAdView];
	}
    
    
/*
#ifndef KY_CIRCLEmenuWITH_NAVIGATIONBAR
    [self.navigationController setNavigationBarHidden:YES animated:YES];
#endif
  */  
    // If it is from child view by press the buttons,
    //   recover menu to normal state
    if (shouldRecoverToNormalStatusWhenViewWillAppear)
        [self performSelector:@selector(recoverToNormalStatus)
                   withObject:nil
                   afterDelay:.3f];
}


//Hide the label when touch is cancelled
- (void)hideButtonlabel:(UIButton*)sender {
    buttonLabel.text = @"";
}


//Update label when button is pressed
- (void)showButtonLabel:(UIButton*)sender {

    BT_item *thisMenuItem = [self.menuItems objectAtIndex:(sender.tag-1)];
	if([thisMenuItem jsonVars] != nil){
    
        NSString *thisButtonLabel = [BT_strings getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"titleText" defaultValue:@"ok"];
        buttonLabel.text = thisButtonLabel;
    }
}

// Run action depend on button, it'll be implemented by subclass
- (void)runButtonActions:(UIButton*)sender {
    
    //Explode buttons out and fade to 0
    [UIView animateWithDuration:.5f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Show buttons & slide in to center
                         [self.menu setAlpha:1.f];
                         [self updateButtonsLayoutWithTriangleHypotenuse:maxBounceOfTriangleHypotenuse];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.6f
                                               delay:0.f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              buttonLabel.text = @"";
                                              [self.menu setAlpha:0.f];
                                              [self.centerButton setAlpha:0.f];
                                              [self updateButtonsLayoutWithTriangleHypotenuse:maxTriangleHypotenuse];
                                          }
                                          completion:nil];
                     }];
    
    
    //pass this menu item to the tapForMenuItem method
	BT_item *thisMenuItem = [self.menuItems objectAtIndex:(sender.tag-1)];
	if([thisMenuItem jsonVars] != nil){
        
		//appDelegate
		robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
        
		//get possible itemId of the screen to load
        NSString *loadScreenItemId = [BT_strings getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"loadScreenWithItemId" defaultValue:@""];
		
		//get possible nickname of the screen to load
		NSString *loadScreenNickname = [BT_strings getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"loadScreenWithNickname" defaultValue:@""];
        
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
				if([thisMenuItem.jsonVars objectForKey:@"loadScreenObject"]){
					screenObjectToLoad = [[BT_item alloc] init];
					[screenObjectToLoad setItemId:[[thisMenuItem.jsonVars objectForKey:@"loadScreenObject"] objectForKey:@"itemId"]];
					[screenObjectToLoad setItemNickname:[[thisMenuItem.jsonVars objectForKey:@"loadScreenObject"] objectForKey:@"itemNickname"]];
					[screenObjectToLoad setItemType:[[thisMenuItem.jsonVars objectForKey:@"loadScreenObject"] objectForKey:@"itemType"]];
					[screenObjectToLoad setJsonVars:[thisMenuItem.jsonVars objectForKey:@"loadScreenObject"]];
				}
			}
		}
        
		//load next screen if it's not nil
		if(screenObjectToLoad != nil){
            NSArray *loadingScreenObject = [[NSArray alloc]initWithObjects:[self screenData], thisMenuItem, screenObjectToLoad, nil];
            [self performSelector:@selector(loadNextScreen:) withObject:loadingScreenObject afterDelay:1.7f];
		}else{
			//show message
			[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@",NSLocalizedString(@"menuTapError",@"The application doesn't know how to handle this click?")]];
		}
		
	}else{
        
		//show message
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@",NSLocalizedString(@"menuTapError",@"The application doesn't know how to handle this action?")]];
        
	
    }
    
    
    
    
    
    // Close center menu
   //   [self closeCenterMenuView:nil];
    shouldRecoverToNormalStatusWhenViewWillAppear = YES;
}

//load screen
- (void)loadNextScreen:(NSArray *)loadingScreen {
    [self handleTapToLoadScreen:[loadingScreen objectAtIndex:2] theMenuItemData:[loadingScreen objectAtIndex:1]];

#ifndef KY_CIRCLEmenuWITH_NAVIGATIONBAR
    [self.navigationController setNavigationBarHidden:NO animated:NO];
#endif

}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    //get app Delegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //move frame "up" a bit if app has tabs...
    int moveUp = 0;
    if([appDelegate.rootApp.tabs count] > 0){
        moveUp = 50;
    }
    NSString *navBarStyle = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"navBarStyle" defaultValue:@""]uppercaseString];
    if ([navBarStyle isEqualToString:@"TRANSPARENT"] || [navBarStyle isEqualToString:@"HIDDEN"]) moveUp-=64;
    
    
    
    CGSize centerSize = centerButton.frame.size;
    CGSize frameSize = self.view.frame.size;
    CGSize theMenuSize = menu.frame.size;
    centerButton.frame = CGRectMake((frameSize.height - centerSize.height)/2, ((frameSize.width - centerSize.width)/2) + moveUp, centerSize.width, centerSize.height);
    menu.frame = CGRectMake((frameSize.height - theMenuSize.height)/2, ((frameSize.width-theMenuSize.width)/2) + moveUp, theMenuSize.width, theMenuSize.height);

}

// Open center menu view
- (void)open {
    if (isOpening)
        return;
    isInProcessing = YES;
    
    // Show buttons with animation
    [UIView animateWithDuration:.6f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.menu setAlpha:1.f];
                         // Compute buttons' frame and set for them, based on |buttonCount|
                         [self updateButtonsLayoutWithTriangleHypotenuse:maxBounceOfTriangleHypotenuse];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.1f
                                               delay:0.f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              [self updateButtonsLayoutWithTriangleHypotenuse:defaultTriangleHypotenuse];
                                          }
                                          completion:^(BOOL finished) {
                                              isOpening = YES;
                                              isClosed = NO;
                                              isInProcessing = NO;
                                          }];
                     }];
}

// Recover to normal status
- (void)recoverToNormalStatus {
    [self updateButtonsLayoutWithTriangleHypotenuse:maxTriangleHypotenuse];
    [UIView animateWithDuration:.6f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Show buttons & slide in to center
                         [self.menu setAlpha:1.f];
                         
                         [self updateButtonsLayoutWithTriangleHypotenuse:minBounceOfTriangleHypotenuse];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.5f
                                               delay:0.f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              [self.centerButton setAlpha:1.f];
                                              [self updateButtonsLayoutWithTriangleHypotenuse:defaultTriangleHypotenuse];
                                          }
                                          completion:nil];
                     }];
}

// Setup notification observer
- (void)setupNotificationObserver {
    // Add Observer for close self
    // If |centerMainButton_| post cancel notification, do it
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(close:)
                                                 name:kKYNCircleMenuClose
                                               object:nil];
}

// Toggle Circle Menu
- (void)toggle:(id)sender {
    
    (isClosed ? [self open] : [self close:nil]);
}

// Close menu to hide all buttons around
- (void)close:(NSNotification *)notification {
    if (isClosed)
        return;
    
    isInProcessing = YES;
    // Hide buttons with animation
    [UIView animateWithDuration:.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         for (UIButton * button in [self.menu subviews])
                             [button setFrame:buttonOriginFrame];
                         [self.menu setAlpha:0.f];
                     }
                     completion:^(BOOL finished) {
                         isClosed       = YES;
                         isOpening      = NO;
                         isInProcessing = NO;
                     }];
}

// Update buttons' layout with the value of triangle hypotenuse that given
- (void)updateButtonsLayoutWithTriangleHypotenuse:(CGFloat)triangleHypotenuse {

    
    //get app Delegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //move frame "up" a bit if app has tabs...
    int moveUp = 0;
    if([appDelegate.rootApp.tabs count] > 0){
        moveUp = 50;
    }
    NSString *navBarStyle = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"navBarStyle" defaultValue:@""]uppercaseString];
    if ([navBarStyle isEqualToString:@"TRANSPARENT"] || [navBarStyle isEqualToString:@"HIDDEN"]) moveUp-=64;
    
    CGFloat centerBallMenuHalfSize = menuSize         / 2.f;
    CGFloat buttonRadius           = centerbuttonSize / 2.f;
    if (! triangleHypotenuse) triangleHypotenuse = defaultTriangleHypotenuse; // Distance to Ball Center
    
    //      Starting position in degrees for button 1
    //      (Note that we have inverted the circle to show buttons clockwise rather than counter-clockwise)
    //
    //          270
    //        /    \
    //       180   360/0
    //       |      |
    //        \    /
    //          90
    
    
    
    for (int i=0; i<buttonCount; i++) {
        
        CGFloat degree = ((i+1) * (360 / buttonCount));
        CGFloat baseDegree = 270 - (360 / buttonCount);         //sets button 1 to 270 degrees (top)
        CGFloat degreeToUse = degree + baseDegree;
        CGFloat radian = degreeToUse * M_PI / 180;
        
        CGFloat buttonX = triangleHypotenuse * cos(radian);
        CGFloat buttonY = triangleHypotenuse * sin(radian);
        
        CGPoint buttonOrigin = CGPointMake(centerBallMenuHalfSize + buttonX - buttonRadius, (centerBallMenuHalfSize + buttonY - buttonRadius) - moveUp);
        [self setButtonWithTag:(i+1) origin:buttonOrigin];
    }
     
}

// Set Frame for button with special tag
- (void)setButtonWithTag:(NSInteger)buttonTag origin:(CGPoint)origin {
    UIButton * button = (UIButton *)[self.menu viewWithTag:buttonTag];
    [button setFrame:CGRectMake(origin.x, origin.y, centerbuttonSize, centerbuttonSize)];
    
    button = nil;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kKYNCircleMenuClose object:nil];
}

- (void)releaseSubviews {
    self.centerButton = nil;
    self.menu         = nil;
}


@end







