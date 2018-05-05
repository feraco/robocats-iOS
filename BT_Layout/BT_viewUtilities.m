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


#import "BT_viewUtilities.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "JSON.h"
#import "BT_strings.h"
#import "robocats_appDelegate.h"
#import "BT_debugger.h"
#import "BT_color.h"
#import "BT_background_view.h"
#import "BT_cell_backgroundView.h"

@implementation BT_viewUtilities

//frame for nav bar
+(CGRect)frameForNavBarAtOrientation:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData{
	CGFloat height = UIInterfaceOrientationIsPortrait(theViewController.interfaceOrientation) ? 44 : 44;
	
	//is the status bar hidden?
	if([UIApplication sharedApplication].statusBarHidden){
		return CGRectMake(0, 0, theViewController.view.bounds.size.width, height);
	}else{
		return CGRectMake(0, 20, theViewController.view.bounds.size.width, height);
	}
	
}

//frame for tool bar (same height as nav bar at bottom of screen)
+(CGRect)frameForToolBarAtOrientation:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData{
	CGFloat height = UIInterfaceOrientationIsPortrait(theViewController.interfaceOrientation) ? 44 : 44;
	CGFloat top = theViewController.view.bounds.size.height - 44;
	return CGRectMake(0, top, theViewController.view.bounds.size.width, height);
}

//frame for advertising view
+(CGRect)frameForAdView:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"frameForAdViewAtOrientation %@", @""]];
	
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
	int height = 50;
	int width = [appDelegate.rootDevice deviceWidth];
	int statusBarHeight = 20;
	int navBarHeight = 44;
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"statusBarStyle" defaultValue:@""] isEqualToString:@"hidden"]){
		statusBarHeight = 0;
	}
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarStyle" defaultValue:@""] isEqualToString:@"hidden"]){
		navBarHeight = 0;
	}
	//iPads are wider and taller...
	if([appDelegate.rootDevice isIPad]){
		height = 66;
	}
	int top = theViewController.view.bounds.size.height - height;
	
	//if we have a bottom toolbar, we need to move the add "up" a bit. Bottom toolbars have tag 49
	for(UIView* subView in [theViewController.view subviews]){
		if(subView.tag == 49){
			top -= 44;
			break;
		}	
	}
	return CGRectMake(0, top, width, height);
    
}

//loading view
+(UIView *)getProgressView:(NSString *)loadingText{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"getProgressView %@", loadingText]];
	
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
	
	//default loading if needed...
	if([loadingText length] < 1){
		loadingText = NSLocalizedString(@"loading",@"...loading...");
	}
	
	//get center point of top-most view
	CGPoint centerPoint;
	if([appDelegate.rootApp rootTabBarController] == nil && [appDelegate.rootApp rootNavController] == nil){
		centerPoint = [appDelegate.window center];
	}else{
		if([appDelegate.rootApp.tabs count] < 1){
			centerPoint = [appDelegate.rootApp.rootNavController.topViewController.view center];
		}else{
			centerPoint = [appDelegate.rootApp.rootTabBarController.selectedViewController.view center];
		}
	}
	
	UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 130)];
	[progressView setCenter:centerPoint];
	progressView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin 
                                     | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	//progress background
	UIImageView *imgView = [[UIImageView alloc] init];
	imgView.frame = CGRectMake(0, 0, 320, 110);
	UIImage *bgImage =  [UIImage imageNamed:@"bt_loadingBg.png"];
	imgView.image = bgImage;
	[progressView addSubview:imgView];
	
	//activity wheel
	UIActivityIndicatorView *tmpWheel = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(142, 30, 30, 30)];
	tmpWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[tmpWheel startAnimating];
	[progressView addSubview:tmpWheel];
	
	//label
	UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 50, 125, 50)];
	loadingLabel.numberOfLines = 2;
	loadingLabel.font = [UIFont systemFontOfSize:16];
	loadingLabel.textAlignment = UITextAlignmentCenter;
	loadingLabel.textColor = [UIColor whiteColor];
	loadingLabel.backgroundColor = [UIColor clearColor];
	loadingLabel.text = loadingText;
	[progressView addSubview:loadingLabel];
	
	return progressView;
}


/*
 This method returns the color for the text that goes on a background for a passed in screen.
 If background color is "light" then "dark" text should be used.
 
 */
+(UIColor *)getTextColorForScreen:(BT_item *)theScreenData{
	if([[theScreenData.jsonVars objectForKey:@"itemNickname"] length] > 1){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"getTextColorForScreen with nickname: \"%@\" and itemId: %@ and type: %@", [theScreenData.jsonVars objectForKey:@"itemNickname"], [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}else{
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"getTextColorForScreen with nickname: \"%@\" and itemId: %@ and type: %@", @"no nickname?", [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}
    
    
	//get textOnBackgroundColor from rootApp.rootTheme OR from screens JSON if over-riden
	UIColor *tmpColor = nil;
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"textOnBackgroundColor" defaultValue:@""] length] > 0){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"setting text on background color: %@", [BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"textOnBackgroundColor" defaultValue:@""]]];
		tmpColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listBackgroundColor" defaultValue:@""]];
	
    
    }else{
		tmpColor = [UIColor blackColor];
	}
    
	return tmpColor;
	
}




/*
 This method returns the color for the navigation bar for a passed in screen */
+(UIColor *)getNavBarBackgroundColorForScreen:(BT_item *)theScreenData{
    
	UIColor *tmpColor = nil;
    if(theScreenData != nil){
        NSString *useColor = [BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarBackgroundColor" defaultValue:@""];
        if([useColor length] > 0){
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"getNavBarBackgroundColorForScreen: Screen \"%@\" color: %@", [theScreenData.jsonVars objectForKey:@"itemNickname"], useColor]];
            tmpColor = [BT_color getColorFromHexString:useColor];
        }else{
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"getNavBarBackgroundColorForScreen: Screen \"%@\" does not use a navBarBackgroundColor%@", [theScreenData.jsonVars objectForKey:@"itemNickname"], @""]];
        
        }
    }
	return tmpColor;
	
}


//This method rounds the corners of a view
+(UIView *)applyRoundedCorners:(UIView *)theView radius:(int)radius{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"applyRoundedCorners radius:%i", radius]];
    theView.layer.cornerRadius = radius;
	return theView;
}
//This method rounds the corners of a UITextView
+(UITextView *)applyRoundedCornersToTextView:(UITextView *)theView radius:(int)radius{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"applyRoundedCornersToTextView radius:%i", radius]];
   	theView.layer.masksToBounds = YES;
	theView.layer.cornerRadius = radius;
	return theView;
}
//This method rounds the corners of a UIImageView
+(UIImageView *)applyRoundedCornersToImageView:(UIImageView *)theView radius:(int)radius{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"applyRoundedCornersToImageView radius:%i", radius]];
   	theView.layer.masksToBounds = YES;
	theView.layer.cornerRadius = radius;
	return theView;
}
//this method adds a border to a view
+(UIView *)applyBorder:(UIView *)theView borderWidth:(int)borderWidth borderColor:(UIColor *)borderColor{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"applyBorder borderWidth:%i", borderWidth]];
    theView.layer.borderWidth = borderWidth;
    theView.layer.borderColor = [borderColor CGColor];
	return theView;
}
//this method adds a drop shadow to a view
+(UIView *)applyDropShadow:(UIView *)theView shadowColor:(UIColor *)shadowColor{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"applyDropShadow", @""]];
	
	//drop shadow does not work on older devices (4.0 > required)
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	if(version >= 4.0){
    	theView.layer.shadowColor = [shadowColor CGColor];
    	theView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    	theView.layer.shadowOpacity = 0.50;
	}
	return theView;
}

//this method adds a gradient to a view
+(UIView *)applyGradient:(UIView *)theView colorTop:(UIColor *)colorTop colorBottom:(UIColor *)colorBottom {
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"applyGradient", @""]];
    
    //create a CAGradientLayer to draw the gradient on
    CAGradientLayer *layer = [CAGradientLayer layer];
	layer.colors = [NSArray arrayWithObjects:(id)[colorTop CGColor], (id)[colorBottom CGColor], nil];
    layer.frame = theView.bounds;
    [theView.layer insertSublayer:layer atIndex:0];
	return theView;
	
}


////////////////////////////////////////////////////////////////////
// BT DEPRECATED METHODS. PLUGISN SHOULD NOT USE THESE ANYMORE

/*
 this method returns a UITable view for a screen. It uses the screen data to configure options such as
 style, header/footer height, colors, background if the global theme values are over-ridden in the screen data.
 Note: lists contain cells, cells also have styles applied. This can get confusing when working with
 backgrounds and colors.
 */
+(UITableView *)getTableViewForScreen:(BT_item *)theScreenData{
	if([[theScreenData.jsonVars objectForKey:@"itemNickname"] length] > 1){
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getTableViewForScreen with nickname: \"%@\" and itemId: %@ and type: %@", [theScreenData.jsonVars objectForKey:@"itemNickname"], [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}else{
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getTableViewForScreen with nickname: \"%@\" and itemId: %@ and type: %@", @"no nickname?", [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}
	
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
	//assume we are building a standard, "square" table
	UITableViewStyle tmpTableStyle = UITableViewStylePlain;
	
	//if the global theme or the screen data want a round style table
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listStyle" defaultValue:@""] isEqualToString:@"round"]){
		tmpTableStyle = UITableViewStyleGrouped;
	}
	
	//default values, may be over-ridden in global theme or screen data
	int tableRowHeight = 50;
	int tableHeaderHeight = 10;
	int tableFooterHeight = 50;
	UIColor *tableBackgroundColor = [UIColor whiteColor];
	
	//table background color
	tableBackgroundColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listBackgroundColor" defaultValue:@"clear"]];
    
	/*
     Some styles depend on the device. Use global theme settings first, then screen-data if over-ridden
     */
	if([appDelegate.rootDevice isIPad]){
		
		//use large device settings
		tableRowHeight = [[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listRowHeightLargeDevice" defaultValue:@"50"] intValue];
		tableHeaderHeight = [[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listHeaderHeightLargeDevice" defaultValue:@"10"] intValue];
		tableFooterHeight = [[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listFooterHeightLargeDevice" defaultValue:@"50"] intValue];
		
	}else{
        
		//use small device settings
		tableRowHeight = [[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listRowHeightSmallDevice" defaultValue:@"50"] intValue];
		tableHeaderHeight = [[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listHeaderHeightSmallDevice" defaultValue:@"10"] intValue];
		tableFooterHeight = [[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listFooterHeightSmallDevice" defaultValue:@"50"] intValue];
        
	}
	
	UITableView *tmpTable = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:tmpTableStyle];
	[tmpTable setRowHeight:tableRowHeight];
	[tmpTable setBackgroundColor:tableBackgroundColor];
    
	//this is a hack because iPad does not recognize UITableView background color...
	if([tmpTable respondsToSelector:@selector(backgroundView)]){
		tmpTable.backgroundView = nil;
	}
	
	[tmpTable setSectionHeaderHeight:tableHeaderHeight];
	[tmpTable setSectionFooterHeight:tableFooterHeight];
	[tmpTable setShowsVerticalScrollIndicator:FALSE];
	[tmpTable setShowsHorizontalScrollIndicator:FALSE];
	tmpTable.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
	//separator color is set to clear here. BT_viewUtilities.getCellBackgroundForListRow handles the separator color
	[tmpTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
	//we may want to prevent scrolling. This is useful if a header or footer image is used.
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listPreventScroll" defaultValue:@"0"] isEqualToString:@"1"]){
		[tmpTable setScrollEnabled:FALSE];
        
	}else{
        
		//if we are not preventing scrolling, add a table footer view so the user can always scroll to the
		//last item. This is helpful in tabbed apps where the last item doesn't quite scroll up high enough.
		UIView *tmpFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
		[tmpFooterView setBackgroundColor:[UIColor clearColor]];
		[tmpTable setTableFooterView:tmpFooterView];
        
	}
	
	//return
	return tmpTable;
    
}

/*
 This method returns a UIToolbar with buttom items configured for a web-view. The toolbar will only
 have buttons that are configured in the theScreenData
 */
+(UIToolbar *)getWebToolBarForScreen:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData{
	if([[theScreenData.jsonVars objectForKey:@"itemNickname"] length] > 1){
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getWebNavBarForScreen with nickname: \"%@\" and itemId: %@ and type: %@", [theScreenData.jsonVars objectForKey:@"itemNickname"], [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}else{
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getWebNavBarForScreen with nickname: \"%@\" and itemId: %@ and type: %@", @"no nickname?", [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}
	
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
	
	//if we have no button options set in JSON and no audioFileName, return nil for toolbar
	BOOL screenUsesToolbar = FALSE;
	UIToolbar *theToolbar = nil;
	
	// create the array to hold the buttons for the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] init];
    
	//back
	if([theViewController respondsToSelector:@selector(goBack)]){
		if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showBrowserBarBack" defaultValue:@""] isEqualToString:@"1"]){
			screenUsesToolbar = TRUE;
			UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"prev.png"] style:UIBarButtonItemStylePlain  target:theViewController action:@selector(goBack)];
			button.style = UIBarButtonItemStyleBordered;
			[button setTag:101];
			[buttons addObject:button];
		}
	}else{
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getWebToolBarForScreen: No goBack method found, cannot add back button for screen with itemId: %@", [theScreenData itemId]]];
	}
	
	//spacer forces remaining buttons to right
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:bi];
    
	//open in safari
    SEL sel = NSSelectorFromString(@"launchInNativeApp");
	if([theViewController respondsToSelector:sel]){
		if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showBrowserBarLaunchInNativeApp" defaultValue:@""] isEqualToString:@"1"]){
			screenUsesToolbar = TRUE;
			UIBarButtonItem* button = [[UIBarButtonItem alloc]	initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:theViewController action:sel];
			button.style = UIBarButtonItemStyleBordered;
			[button setTag:103];
			[buttons addObject:button];
		}
	}else{
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getWebToolBarForScreen: No launchInNativeApp method found, cannot add launch in native app button for screen with itemId: %@", [theScreenData itemId]]];
	}
	
    //allow email document?
    SEL sel2 = NSSelectorFromString(@"emailDocument");
	if([theViewController respondsToSelector:sel2]){
		if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showBrowserBarEmailDocument" defaultValue:@""] isEqualToString:@"1"]){
			screenUsesToolbar = TRUE;
			UIBarButtonItem* button = [[UIBarButtonItem alloc]	initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:theViewController action:sel2];
			button.style = UIBarButtonItemStyleBordered;
			[button setTag:104];
			[buttons addObject:button];
		}
	}else{
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getWebToolBarForScreen: No emailDocument method found, cannot add email document button for screen with itemId: %@", [theScreenData itemId]]];
	}
    
	//refresh
    SEL sel3 = NSSelectorFromString(@"refreshData");
	if([theViewController respondsToSelector:sel3]){
		if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showBrowserBarRefresh" defaultValue:@""] isEqualToString:@"1"]){
			screenUsesToolbar = TRUE;
			UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:theViewController action:sel3];
			button.style = UIBarButtonItemStyleBordered;
			[button setTag:105];
			[buttons addObject:button];
		}
	}else{
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getWebToolBarForScreen: No refreshData method found, cannot add refresh button for screen with itemId: %@", [theScreenData itemId]]];
	}
	
    
	//audio controls in toolbar if we have an audioFileName
    SEL sel4 = NSSelectorFromString(@"showAudioControls");
	if([theViewController respondsToSelector:sel4]){
		if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 0 || [[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 0){
			screenUsesToolbar = TRUE;
			UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"equalizer.png"] style:UIBarButtonItemStylePlain  target:theViewController action:sel4];
			button.style = UIBarButtonItemStyleBordered;
			[button setTag:106];
			[buttons addObject:button];
		}
	}
	
	//if we are using a toolbar
	if(screenUsesToolbar){
        
		//create a toolbar to have two buttons in the right
		theToolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolBarAtOrientation:theViewController theScreenData:theScreenData]];
		theToolbar.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
		
		//set toolbar color to nav bar color from rootApp.rootTheme OR from screens JSON if over-riden
		UIColor *tmpColor = nil;
		
		//nav bar background color
		if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarBackgroundColor" defaultValue:@""] length] > 0){
			[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"setting browser tool-bar background color: %@", [[appDelegate.rootApp.rootTheme jsonVars] objectForKey:@"navBarBackgroundColor"]]];
			tmpColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarBackgroundColor" defaultValue:@""]];
			[theToolbar setTintColor:tmpColor];
		}
		
		//set the toolbar style
		if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"toolbarStyle" defaultValue:@""] isEqualToString:@"transparent"]){
			[theToolbar setTranslucent:TRUE];
		}else{
			[theToolbar setTranslucent:FALSE];
		}
		
		//add the buttons to the toolbar
		[theToolbar setItems:buttons animated:NO];
        
	}
    
	//return
	return theToolbar;
    
}

/*
 This method returns a UIToolbar with buttom items configured for a map view.
 */
+(UIToolbar *)getMapToolBarForScreen:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData{
	if([[theScreenData.jsonVars objectForKey:@"itemNickname"] length] > 1){
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getMapToolBarForScreen with nickname: \"%@\" and itemId: %@ and type: %@", [theScreenData.jsonVars objectForKey:@"itemNickname"], [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}else{
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getMapToolBarForScreen with nickname: \"%@\" and itemId: %@ and type: %@", @"no nickname?", [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}
    
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
	
	//if we have no button options set in JSON and no audioFileName, return nil for toolbar
	BOOL screenUsesToolbar = FALSE;
	UIToolbar *theToolbar = nil;
	
	// create the array to hold the buttons for the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] init];
	
	//are we showing map buttons?
	if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showMapTypeButtons" defaultValue:@""] isEqualToString:@"1"]){
        
		//flag that we are using a toolbar
		screenUsesToolbar = TRUE;
		
		//standard
        SEL sel = NSSelectorFromString(@"showMapType");
		UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_standard.png"] style:UIBarButtonItemStylePlain  target:theViewController action:sel];
		button.style = UIBarButtonItemStyleBordered;
		[button setTag:1];
		[buttons addObject:button];
        
		//terrain
		UIBarButtonItem* button_1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_terrain.png"] style:UIBarButtonItemStylePlain  target:theViewController action:sel];
		button_1.style = UIBarButtonItemStyleBordered;
		[button_1 setTag:2];
		[buttons addObject:button_1];
        
		//hybrid
		UIBarButtonItem* button_2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_hybrid.png"] style:UIBarButtonItemStylePlain  target:theViewController action:sel];
		button_2.style = UIBarButtonItemStyleBordered;
		[button_2 setTag:3];
		[buttons addObject:button_2];
        
	}//if map type buttons
	
	
	//show refresh button?
    SEL sel4 = NSSelectorFromString(@"refreshData");
	if([theViewController respondsToSelector:sel4]){
		if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showRefreshButton" defaultValue:@""] isEqualToString:@"1"]){
			UIBarButtonItem* buttonRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:theViewController action:sel4];
			buttonRefresh.style = UIBarButtonItemStyleBordered;
			[buttonRefresh setTag:102];
			[buttons addObject:buttonRefresh];
		}
	}
	
	
	//spacer forces remaining buttons to right
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:bi];
    
	//user location button
    SEL sel5 = NSSelectorFromString(@"centerDeviceLocation");
	if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showUserLocationButton" defaultValue:@""] isEqualToString:@"1"]){
		screenUsesToolbar = TRUE;
		UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_location.png"] style:UIBarButtonItemStylePlain  target:theViewController action:sel5];
		button.style = UIBarButtonItemStyleBordered;
		[button setTag:3];
		[buttons addObject:button];
	}
    
	//audio controls in toolbar if we have an audioFileName
	if([theViewController respondsToSelector:@selector(showAudioControls)]){
		if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 0 || [[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 0){
			screenUsesToolbar = TRUE;
			UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"equalizer.png"] style:UIBarButtonItemStylePlain  target:theViewController action:@selector(showAudioControls)];
			button.style = UIBarButtonItemStyleBordered;
			[button setTag:104];
			[buttons addObject:button];
		}
	}
	
	
	//if we are using a toolbar
	if(screenUsesToolbar){
		
		//create a toolbar to have two buttons in the right
		theToolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolBarAtOrientation:theViewController theScreenData:theScreenData]];
		theToolbar.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
		
		//set toolbar color to nav bar color from rootApp.rootTheme OR from screens JSON if over-riden
		UIColor *tmpColor = nil;
		
		//nav bar background color
		if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarBackgroundColor" defaultValue:@""] length] > 0){
			[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"setting map tool-bar background color: %@", [[appDelegate.rootApp.rootTheme jsonVars] objectForKey:@"navBarBackgroundColor"]]];
			tmpColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarBackgroundColor" defaultValue:@""]];
			[theToolbar setTintColor:tmpColor];
		}
		
		//set the toolbar style
		if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"toolbarStyle" defaultValue:@""] isEqualToString:@"transparent"]){
			[theToolbar setTranslucent:TRUE];
		}else{
			[theToolbar setTranslucent:FALSE];
		}
		
		//add the buttons to the toolbar
		[theToolbar setItems:buttons animated:NO];
        
	}
    
	//return
	return theToolbar;
	
}

/*
 This method returns a UIToolbar with buttom items configured for an image gallery screen.
 */

+(UIToolbar *)getImageToolBarForScreen:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData{
	if([[theScreenData.jsonVars objectForKey:@"itemNickname"] length] > 1){
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getImageToolBarForScreen with nickname: \"%@\" and itemId: %@ and type: %@", [theScreenData.jsonVars objectForKey:@"itemNickname"], [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}else{
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getImageToolBarForScreen with nickname: \"%@\" and itemId: %@ and type: %@", @"no nickname?", [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}
	
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
	
	//if we have no button options set in JSON and no audioFileName, return nil for toolbar
	UIToolbar *theToolbar = nil;
	BOOL showBar = FALSE;
	
	// create the array to hold the buttons for the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] init];
	
	//are showing prev / next buttons?
    if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showImageNavButtons" defaultValue:@""] isEqualToString:@"1"]){
		showBar = TRUE;
		
        SEL sel6 = NSSelectorFromString(@"gotoPreviousPage");
        UIBarButtonItem* buttonPrev = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"prev.png"] style:UIBarButtonItemStylePlain  target:theViewController action:sel6];
		buttonPrev.style = UIBarButtonItemStyleBordered;
		[buttonPrev setTag:1];
		[buttons addObject:buttonPrev];
        
        SEL sel7 = NSSelectorFromString(@"gotoNextPage");
		UIBarButtonItem* buttonNext = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"next.png"] style:UIBarButtonItemStylePlain  target:theViewController action:sel7];
		buttonNext.style = UIBarButtonItemStyleBordered;
		[buttonNext setTag:2];
		[buttons addObject:buttonNext];
        
	}
	
	//show refresh button?
    SEL sel8 = NSSelectorFromString(@"refreshData");
	if([theViewController respondsToSelector:sel8]){
		if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showRefreshButton" defaultValue:@""] isEqualToString:@"1"]){
			showBar = TRUE;
			UIBarButtonItem* buttonRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:theViewController action:sel8];
			buttonRefresh.style = UIBarButtonItemStyleBordered;
			[buttonRefresh setTag:102];
			[buttons addObject:buttonRefresh];
		}
	}
    
	//spacer forces remaining buttons to right
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:bi];
	
	//email image button
    SEL sel9 = NSSelectorFromString(@"showImageFunctions");
	if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showEmailImageButton" defaultValue:@""] isEqualToString:@"1"] ||
       [[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showSaveImageButton" defaultValue:@""] isEqualToString:@"1"] ){
		showBar = TRUE;
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:theViewController action:sel9];
		button.style = UIBarButtonItemStyleBordered;
		[button setTag:3];
		[buttons addObject:button];
	}
	
	//audio controls in toolbar if we have an audioFileName
    SEL sel10 = NSSelectorFromString(@"showAudioControls");
    if([theViewController respondsToSelector:sel10]){
		if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 0 || [[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 0){
			showBar = TRUE;
			UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"equalizer.png"] style:UIBarButtonItemStylePlain  target:theViewController action:sel10];
			button.style = UIBarButtonItemStyleBordered;
			[button setTag:104];
			[buttons addObject:button];
		}
	}
	
	//create a toolbar to have two buttons in the right
	theToolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolBarAtOrientation:theViewController theScreenData:theScreenData]];
	theToolbar.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
	
	//set toolbar color to nav bar color from rootApp.rootTheme OR from screens JSON if over-riden
	UIColor *tmpColor = nil;
	
	//nav bar background color
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarBackgroundColor" defaultValue:@""] length] > 0){
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"setting image tool-bar background color: %@", [[appDelegate.rootApp.rootTheme jsonVars] objectForKey:@"navBarBackgroundColor"]]];
		tmpColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarBackgroundColor" defaultValue:@""]];
		[theToolbar setTintColor:tmpColor];
	}
	
	//set the toolbar style
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"toolbarStyle" defaultValue:@""] isEqualToString:@"transparent"]){
		[theToolbar setTranslucent:TRUE];
	}else{
		[theToolbar setTranslucent:FALSE];
	}
	
	//add the buttons to the toolbar
	[theToolbar setItems:buttons animated:NO];
    
	//if we did not have any buttons...remove the bar
	if(showBar){
		return theToolbar;
	}else{
		theToolbar = nil;
		return theToolbar;
	}
}


/*
 This method returns a UIToolbar with buttom items configured for an aduio screen.
 */

+(UIToolbar *)getAudioToolBarForScreen:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData{
	if([[theScreenData.jsonVars objectForKey:@"itemNickname"] length] > 1){
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getAudioToolBarForScreen with nickname: \"%@\" and itemId: %@ and type: %@", [theScreenData.jsonVars objectForKey:@"itemNickname"], [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}else{
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getAudioToolBarForScreen with nickname: \"%@\" and itemId: %@ and type: %@", @"no nickname?", [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}
	
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
	
	//if we have no button options set in JSON and no audioFileName, return nil for toolbar
	UIToolbar *theToolbar = nil;
	
	// create the array to hold the buttons for the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] init];
	
    SEL sel10 = NSSelectorFromString(@"playAudio");
	UIBarButtonItem* buttonPlay = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:theViewController action:sel10];
	buttonPlay.style = UIBarButtonItemStyleBordered;
	[buttonPlay setTag:1];
	[buttons addObject:buttonPlay];
    
    SEL sel11 = NSSelectorFromString(@"pauseAudio");
	UIBarButtonItem* buttonPause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:theViewController action:sel11];
	buttonPause.style = UIBarButtonItemStyleBordered;
	[buttonPause setTag:2];
	[buttons addObject:buttonPause];
    
	//show refresh button?
    SEL sel12 = NSSelectorFromString(@"refreshData");
	if([theViewController respondsToSelector:sel12]){
		if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showRefreshButton" defaultValue:@""] isEqualToString:@"1"]){
			UIBarButtonItem* buttonRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:theViewController action:sel12];
			buttonRefresh.style = UIBarButtonItemStyleBordered;
			[buttonRefresh setTag:5];
			[buttons addObject:buttonRefresh];
		}
	}
    
	//spacer forces remaining buttons to right
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:bi];
	
	//audio tools button
    SEL sel13 = NSSelectorFromString(@"showAudioFunctions");
	if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"showAudioToolsButton" defaultValue:@""] isEqualToString:@"1"]){
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:theViewController action:sel13];
		button.style = UIBarButtonItemStyleBordered;
		[button setTag:5];
		[buttons addObject:button];
	}
	
	//create a toolbar to have two buttons in the right
	theToolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolBarAtOrientation:theViewController theScreenData:theScreenData]];
	theToolbar.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
	
	//set toolbar color to nav bar color from rootApp.rootTheme OR from screens JSON if over-riden
	UIColor *tmpColor = nil;
	
	//nav bar background color
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarBackgroundColor" defaultValue:@""] length] > 0){
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"setting audio tool-bar background color: %@", [[appDelegate.rootApp.rootTheme jsonVars] objectForKey:@"navBarBackgroundColor"]]];
		tmpColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarBackgroundColor" defaultValue:@""]];
		[theToolbar setTintColor:tmpColor];
	}
	
	//set the toolbar style
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"toolbarStyle" defaultValue:@""] isEqualToString:@"transparent"]){
		[theToolbar setTranslucent:TRUE];
	}else{
		[theToolbar setTranslucent:FALSE];
	}
	
	//add the buttons to the toolbar
	[theToolbar setItems:buttons animated:NO];
    
	//clean up button
    
	//return
	return theToolbar;
	
}


/*
 This method returns a UIToolbar with buttom items configured for a quiz.
 */

+(UIToolbar *)getQuizToolBarForScreen:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData{
	if([[theScreenData.jsonVars objectForKey:@"itemNickname"] length] > 1){
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getQuizToolBarForScreen with nickname: \"%@\" and itemId: %@ and type: %@", [theScreenData.jsonVars objectForKey:@"itemNickname"], [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}else{
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getQuizToolBarForScreen with nickname: \"%@\" and itemId: %@ and type: %@", @"no nickname?", [theScreenData.jsonVars objectForKey:@"itemId"], [theScreenData.jsonVars objectForKey:@"itemType"]]];
	}
	
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
	
	//if we have no button options set in JSON and no audioFileName, return nil for toolbar
	UIToolbar *theToolbar = nil;
	
	// create the array to hold the buttons for the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] init];
	
	//if we have a sound file, add a left refresh and a right audio... else just add timer...
	if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3 || [[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 3){
        
        
		//refresh button.
        SEL sel14 = NSSelectorFromString(@"refreshData");
        UIBarButtonItem* buttonRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:theViewController action:sel14];
		buttonRefresh.style = UIBarButtonItemStyleBordered;
		[buttonRefresh setTag:102];
		[buttons addObject:buttonRefresh];
		//disable it if not dataURL is provided for the parent screen
		if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@""] length] < 3){
			[buttonRefresh setEnabled:FALSE];
		}
        
	}
	
	
	//spacer forces buttons to left
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:bi];
	
	//quiz timer..(leave space on each end for buttons...
	UILabel *quizTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(75 , 11.0f, theViewController.view.frame.size.width - 150, 21.0f)];
	[quizTimeLabel setFont:[UIFont systemFontOfSize:16]];
	[quizTimeLabel setBackgroundColor:[UIColor clearColor]];
	[quizTimeLabel setTextColor:[UIColor whiteColor]];
	[quizTimeLabel setTag:105];
	[quizTimeLabel setText:@""];
	[quizTimeLabel setTextAlignment:NSTextAlignmentCenter];
	UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:quizTimeLabel];
	[buttons addObject:title];
	
	//spacer forces buttons to right
	UIBarButtonItem* bi_2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:bi_2];
    
	//ALWAYS add the audio button in the quiz toolbar so timer label centers. Disable it if no background audio..
	if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3 || [[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 3){
		UIBarButtonItem* button;
		button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"equalizer.png"] style:UIBarButtonItemStylePlain  target:theViewController action:@selector(showAudioControls)];
		button.style = UIBarButtonItemStyleBordered;
		[buttons addObject:button];
		
	}
    
	//create a toolbar to have two buttons in the right
	theToolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolBarAtOrientation:theViewController theScreenData:theScreenData]];
	theToolbar.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
	
	//set toolbar color to nav bar color from rootApp.rootTheme OR from screens JSON if over-riden
	UIColor *tmpColor = nil;
	
	//nav bar background color
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarBackgroundColor" defaultValue:@""] length] > 0){
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"setting quiz tool-bar background color: %@", [[appDelegate.rootApp.rootTheme jsonVars] objectForKey:@"navBarBackgroundColor"]]];
		tmpColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"navBarBackgroundColor" defaultValue:@""]];
		[theToolbar setTintColor:tmpColor];
	}
	
	//set the toolbar style
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"toolbarStyle" defaultValue:@""] isEqualToString:@"transparent"]){
		[theToolbar setTranslucent:TRUE];
	}else{
		[theToolbar setTranslucent:FALSE];
	}
	
	//add the buttons to the toolbar
	[theToolbar setItems:buttons animated:NO];
    
	//return
	return theToolbar;
	
}

/*
 This method build a UISegementedControl that we use as a "button" so we can show "selected states"
 */
+(UISegmentedControl *)getButtonForQuiz:(UIViewController *)theViewController theFrame:(CGRect)theFrame theTag:(int)theTag buttonColor:(UIColor *)buttonColor{
	//[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getButtonForQuiz%@", @""]];
    
    SEL sel15 = NSSelectorFromString(@"refresanswerClickhData");

	NSArray *txt = [NSArray arrayWithObjects:@"",nil];
	UISegmentedControl *tmpBtn = [[UISegmentedControl alloc] initWithItems:txt];
	tmpBtn.frame = theFrame;
	tmpBtn.segmentedControlStyle = UISegmentedControlStyleBar;
	tmpBtn.momentary = YES;
	[tmpBtn setTintColor:buttonColor];
	[tmpBtn addTarget:theViewController action:sel15 forControlEvents:UIControlEventValueChanged];
	[tmpBtn setTag:theTag];
	return tmpBtn;
    
}

/*
 This method build a simple label that goes on top of a quiz-button (see previous method). We use this approach
 because the buttons are UISegementedControls and do not allow for font-size changes
 */
+(UILabel *)getLabelForQuizButton:(CGRect)theFrame fontSize:(int)fontSize fontColor:(UIColor *)fontColor{
	//[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getLabelForQuizButton%@", @""]];
    
	UILabel *tmpLbl = [[UILabel alloc] initWithFrame:theFrame];
	[tmpLbl setBackgroundColor:[UIColor clearColor]];
	[tmpLbl setTextAlignment:NSTextAlignmentCenter];
	[tmpLbl setFont:[UIFont systemFontOfSize:fontSize]];
	[tmpLbl setTextColor:fontColor];
	[tmpLbl setNumberOfLines:2];
	[tmpLbl setText:@""];
	
	return tmpLbl;
    
}



/*
 This method returns a custom view for a table view cell's background. It's the only way to add a background
 color without cutting off the rounded corners on a "round" style table.
 */
+(UIView *)getCellBackgroundForListRow:(BT_item *)theScreenData theIndexPath:(NSIndexPath *)theIndexPath numRows:(int)numRows{
	//[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"getCellBackgroundForListRow for screen with itemId: %@", [theScreenData itemId]]];
    
    BT_cell_backgroundView *bgView = [[BT_cell_backgroundView alloc] initWithFrame:CGRectZero];
	UIColor *borderColor = [UIColor grayColor];
	UIColor *backgroundColor = [UIColor clearColor];
	BOOL isRoundTable = FALSE;
	
	//if the global theme or the screen data want a round style table
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listStyle" defaultValue:@""] isEqualToString:@"round"]){
		isRoundTable = TRUE;
	}
	
	//cell background color
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listRowBackgroundColor" defaultValue:@""] length] > 0){
		backgroundColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listRowBackgroundColor" defaultValue:@""]];
	}
    
	//cell border color
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listRowSeparatorColor" defaultValue:@""] length] > 0){
		borderColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"listRowSeparatorColor" defaultValue:@""]];
	}
	
	//set colors
	[bgView setFillColor:backgroundColor];
	[bgView setBorderColor:borderColor];
	
	
	//position is important to maintain rounded corners if this is a "round" table.
	if(isRoundTable == FALSE){
       	bgView.position = CustomCellBackgroundViewPositionMiddle;
	}else{
		if(theIndexPath.row == 0){
			bgView.position = CustomCellBackgroundViewPositionTop;
    	}else if(theIndexPath.row == numRows - 1){
     		bgView.position = CustomCellBackgroundViewPositionBottom;
		}else{
			bgView.position = CustomCellBackgroundViewPositionMiddle;
    	}
	}
	
	//return
	return bgView;
	
}




@end








