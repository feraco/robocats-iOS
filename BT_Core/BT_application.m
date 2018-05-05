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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "robocats_appDelegate.h"
#import "BT_navController.h"
#import "BT_tabBarController.h"
#import "BT_viewUtilities.h"
#import "BT_color.h"
#import "BT_background_view.h"
#import "BT_strings.h"
#import "JSON.h"
#import "BT_item.h"
#import "BT_plugin_missing.h"
#import "BT_debugger.h"
#import "BT_viewController.h"
#import "BT_application.h"


@implementation BT_application
@synthesize downloader, dataURL, reportToCloudURL, registerForPushURL, databaseName, jsonVars;
@synthesize menus, themes, tabs, screens;
@synthesize rootTheme, rootBackgroundView, rootNavController, rootTabBarController;
@synthesize currentMenuItemData, previousMenuItemData, currentScreenData, previousScreenData, currentItemUpload;
@synthesize transitionTypeHistory, promptForPushNotifications;



//init application...
-(id)init{
    if((self = [super init])){
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"INIT%@", @""]];
			
		//init variables.
        self.dataURL = @"";
        self.reportToCloudURL = @"";
        self.registerForPushURL = @"";
        self.databaseName = @"";
		self.jsonVars = nil;
        self.rootBackgroundView = nil;
		self.rootNavController = nil;
		self.rootTabBarController = nil;
		self.rootTheme = nil;
		self.currentItemUpload = nil;
		self.tabs = [[NSMutableArray alloc] init];
		self.menus = [[NSMutableArray alloc] init];
		self.screens = [[NSMutableArray alloc] init];
		self.themes = [[NSMutableArray alloc] init];
        self.promptForPushNotifications = FALSE;
        
        
			
	}
	return self;
}


/*
	this method validates the format of the JSON data. It checks for required elements and returns false if
	an element is missing
*/
-(BOOL)validateApplicationData:(NSString *)theAppData{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"validateApplicationData %@", @""]];
	
	//assume it's valid
	BOOL isValid = TRUE;
	
	//for debugger
	NSString *errorMessage = @"";
	
	//create dictionary from the JSON string
	SBJsonParser *parser = [SBJsonParser new];
  	id jsonData = [parser objectWithString:theAppData];
	if(!jsonData){
		
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"ERROR parsing JSON in validateApplicationData: %@", parser.errorTrace]];
		errorMessage = NSLocalizedString(@"appParseError", @"There was a problem parsing some configuration data. Please make sure that it is well-formed");
		isValid = FALSE;
	}else{
	
		if(![jsonData objectForKey:@"BT_appConfig"]){
			isValid = FALSE;
			errorMessage = [errorMessage stringByAppendingString:@"\nThe appConfig data doesn't contain the root BT_appConfig property?"];
		}else{
			//look for root items array
			if(![[jsonData objectForKey:@"BT_appConfig"] objectForKey:@"BT_items"]){
				isValid = FALSE;
				errorMessage = [errorMessage stringByAppendingString:@"\nThe appConfig data doesn't contain any root-items?"];
			}
		}
	}
		
	//if not valid, show in debugger
	if(!isValid){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"validateApplicationData: ERROR: %@", errorMessage]];
	}else{
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"The application data appears to be valid. %@", @""]];
	}
	
	//return
	return isValid;

}


//init with JSON data string
-(BOOL)parseJSONData:(NSString *)appDataString{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"parseJSONData: parsing application data %@", @""]];
	
    //get a reference to the appDelegate...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
	
	@try{	
	
		//re-set array so they are empty
		self.tabs = [[NSMutableArray alloc] init];
		self.menus = [[NSMutableArray alloc] init];
		self.screens = [[NSMutableArray alloc] init];
		self.themes = [[NSMutableArray alloc] init];
		self.transitionTypeHistory = [[NSMutableArray alloc] init];
	
		//create dictionary from the JSON string
		SBJsonParser *parser = [SBJsonParser new];
		id jsonData = [parser objectWithString:appDataString];
	   	if(!jsonData){
		
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"ERROR parsing JSON in parseJSONData: %@", parser.errorTrace]];
			return FALSE;
		
		}else{

			//get the first item in the list of BT_item, it should be a BT_item.itemType == "BT_app"
			if([[jsonData objectForKey:@"BT_appConfig"] objectForKey:@"BT_items"]){
				NSArray *tmpItems = [[jsonData objectForKey:@"BT_appConfig"] objectForKey:@"BT_items"];
				if([tmpItems count] < 1){
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"the BT_items array is empty?%@", @""]];
				}else{
					NSDictionary *thisApp = [tmpItems objectAtIndex:0];
					if([[thisApp objectForKey:@"itemType"] isEqualToString:@"BT_app"]){
						
						//set this app's json vars
						[self setJsonVars:thisApp];
						
						//First look at the basic app properties and try to find a dataURL
						if([thisApp objectForKey:@"dataURL"]){
							if([[thisApp objectForKey:@"dataURL"] length] > 3){
								//set this app's dataURL
								[self setDataURL:[thisApp objectForKey:@"dataURL"]];
							}
						}
                        
                        //set reportToCloudURL...
                        if([thisApp objectForKey:@"reportToCloudURL"]){
                            if([[thisApp objectForKey:@"reportToCloudURL"] length] > 3){
                                [self setReportToCloudURL:[thisApp objectForKey:@"reportToCloudURL"]];
                            }else{
                                [self setReportToCloudURL:@""];
                            }
                        }
                        
                        
                        //set registerForPushURL...
                        if([thisApp objectForKey:@"registerForPushURL"]){
                            if([[thisApp objectForKey:@"registerForPushURL"] length] > 3){
                                [self setRegisterForPushURL:[thisApp objectForKey:@"registerForPushURL"]];
                            }else{
                                [self setRegisterForPushURL:@""];
                            }
                        }
                        
                        //set database name...
                        if([thisApp objectForKey:@"buzztouchAppId"]){
                            if([[thisApp objectForKey:@"buzztouchAppId"] length] > 3){
                                [self setDatabaseName:[NSString stringWithFormat:@"app_%@.db", [thisApp objectForKey:@"buzztouchAppId"]]];
                            }else{
                                [self setDatabaseName:@""];
                            }
                        }
                        
                        //set promptForPushNotifications...
                        if([thisApp objectForKey:@"promptForPushNotifications"]){
                            if([[thisApp objectForKey:@"promptForPushNotifications"] isEqualToString:@"1"]){
                                [self setPromptForPushNotifications:TRUE];
                            }else{
                                [self setPromptForPushNotifications:FALSE];
                            }
                        }
                        
                        //set "currentMode" (live or design) in app's delegate...
                        if([thisApp objectForKey:@"currentMode"]){
                            if([[thisApp objectForKey:@"currentMode"] length] > 0){
                                [appDelegate setCurrentMode:[thisApp objectForKey:@"currentMode"]];
                            }else{
                                [appDelegate setCurrentMode:@"design"];
                            }
                        }
						
						
						/*
							Fill these array's...
							------------------------------------
							"BT_themes", "BT_tabs", "BT_screens"
						*/
						
						//fill possible themes array
						if([thisApp objectForKey:@"BT_themes"]){
							NSArray *tmpThemes = [thisApp objectForKey:@"BT_themes"];
							[BT_debugger showIt:self message:[NSString stringWithFormat:@"parsing themes, count: %lu", (unsigned long)[tmpThemes count]]];
							for (NSDictionary *tmpTheme in tmpThemes){
									
                                BT_item *thisTheme = [[BT_item alloc] init];
                                
                                if([tmpTheme objectForKey:@"itemId"]){
                                    thisTheme.itemId = [tmpTheme objectForKey:@"itemId"];
                                }else{
                                    thisTheme.itemId = @"0";
                                }

                                if([tmpTheme objectForKey:@"itemType"]){
                                    thisTheme.itemType = [tmpTheme objectForKey:@"itemType"];
                                }else{
                                    thisTheme.itemType = @"BT_theme";
                                }

                                if([tmpTheme objectForKey:@"itemNickname"]){
                                    thisTheme.itemNickname = [tmpTheme objectForKey:@"itemNickname"];
                                }else{
                                    thisTheme.itemNickname = @"";
                                }
                                
                                thisTheme.jsonVars = tmpTheme;
                                [self.themes addObject:thisTheme];
								
                                
							}
						}//end if themes

						//fill possible tabs array
						if([thisApp objectForKey:@"BT_tabs"]){
							NSArray *tmpTabs = [thisApp objectForKey:@"BT_tabs"];
							[BT_debugger showIt:self message:[NSString stringWithFormat:@"parsing tabs, count: %lu", (unsigned long)[tmpTabs count]]];
							for (NSDictionary *tmpTab in tmpTabs){
								if([[tmpTab objectForKey:@"itemType"] isEqualToString:@"BT_tab"]){
									BT_item *thisTab = [[BT_item alloc] init];
									thisTab.itemId = [tmpTab objectForKey:@"itemId"];
									if([tmpTab objectForKey:@"itemNickname"]){
										thisTab.itemNickname = [tmpTab objectForKey:@"itemNickname"];
									}else{
										thisTab.itemNickname = @"";
									}
									thisTab.itemType = [tmpTab objectForKey:@"itemType"];
									thisTab.jsonVars = tmpTab;
									[self.tabs addObject:thisTab];
								}
							}
						}//end if tabs
                        
						//fill possible menus array
						if([thisApp objectForKey:@"BT_menus"]){
							NSArray *tmpMenus = [thisApp objectForKey:@"BT_menus"];
							[BT_debugger showIt:self message:[NSString stringWithFormat:@"parsing menus, count: %lu", (unsigned long)[tmpMenus count]]];
							for (NSDictionary *tmpMenu in tmpMenus){
								if([[tmpMenu objectForKey:@"itemType"] isEqualToString:@"BT_menu"]){
									BT_item *thisMenu = [[BT_item alloc] init];
									thisMenu.itemId = [tmpMenu objectForKey:@"itemId"];
									if([tmpMenu objectForKey:@"itemNickname"]){
										thisMenu.itemNickname = [tmpMenu objectForKey:@"itemNickname"];
									}else{
										thisMenu.itemNickname = @"";
									}
									thisMenu.itemType = [tmpMenu objectForKey:@"itemType"];
									thisMenu.jsonVars = tmpMenu;
									[self.menus addObject:thisMenu];
								}
							}
						}//end if menus

                        
						//fill possible screens array
						if([thisApp objectForKey:@"BT_screens"]){
							NSArray *tmpScreens = [thisApp objectForKey:@"BT_screens"];
							[BT_debugger showIt:self message:[NSString stringWithFormat:@"parsing screens, count: %lu", (unsigned long)[tmpScreens count]]];
							for(NSDictionary *tmpScreen in tmpScreens){
								BT_item *thisScreen = [[BT_item alloc] init];
								thisScreen.itemId = [tmpScreen objectForKey:@"itemId"];
								if([tmpScreen objectForKey:@"itemNickname"]){
									thisScreen.itemNickname = [tmpScreen objectForKey:@"itemNickname"];
								}else{
									thisScreen.itemNickname = @"";
								}
								thisScreen.itemType = [tmpScreen objectForKey:@"itemType"];
								thisScreen.jsonVars = tmpScreen;
								[self.screens addObject:thisScreen];
							}//end for each screen
						}//end if screens		
						
														
					}//if this item was a BT_app
				}
			}else{
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"there are no BT_items in the configuration data?%@", @""]];
			}

			//done
			return TRUE;
		
		}
		
	}@catch (NSException * e) {
	
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"error parsing application data in parseJSONData: %@", e]];
		return FALSE;
	
	} 
		
	return FALSE;
}


//getScreenDataByItemId...
-(BT_item *)getScreenDataByItemId:(NSString *)theScreenItemId{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"getScreenDataByItemId %@", theScreenItemId]];
	int foundIt = 0;
	BT_item *returnScreen = nil;
	for(int i = 0; i < [[self screens] count]; i++){
		BT_item *thisScreen = (BT_item *)[[self screens] objectAtIndex:i];
		if([[thisScreen itemId] isEqualToString:theScreenItemId]){
			foundIt = 1;
			returnScreen = thisScreen;
			break;
		}			
	}
	if(foundIt == 1){
		if([returnScreen.itemNickname length] > 1){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"screenType is %@ for screen with nickname: \"%@\" and itemId: %@", [returnScreen itemType], [returnScreen itemNickname], theScreenItemId]];
		}else{
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"screenType is %@ for screen with nickname: \"%@\" and itemId: %@", [returnScreen itemType], @"no nickname?", theScreenItemId]];
		}
	}else{
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"could not find screen with itemId: %@", theScreenItemId]];
	
        //json data for error screen...
        returnScreen = [[BT_item alloc] init];
        [returnScreen setItemId:@"error view controller has no itemId"];
        [returnScreen setItemType:@"BT_screen_menuList"];
        
        //create a dictionary for the dynamic screen.
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"error view controller has no itemId", @"itemId",
                              @"BT_screen_menuList", @"itemType",
                              @"Plugin not found?", @"navBarTitleText", nil];
        [returnScreen setJsonVars:dict];
    
    }
	return returnScreen;
}

//getScreenDataByNickname...
-(BT_item *)getScreenDataByNickname:(NSString *)theScreenNickname{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"getScreenDataByNickname %@", theScreenNickname]];
	int foundIt = 0;
	BT_item *returnScreen = nil;
	for(int i = 0; i < [[self screens] count]; i++){
		BT_item *thisScreen = (BT_item *)[[self screens] objectAtIndex:i];
		if([[thisScreen itemNickname] isEqualToString:theScreenNickname]){
			foundIt = 1;
			returnScreen = thisScreen;
			break;
		}
	}
	if(foundIt == 1){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"screenType is %@ for screen with nickname: %@", [returnScreen itemType], theScreenNickname]];
	}else{
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"could not find screen with nickname: %@", theScreenNickname]];
	
        //json data for error screen...
        returnScreen = [[BT_item alloc] init];
        [returnScreen setItemId:@"error view controller has no itemId"];
        [returnScreen setItemType:@"BT_screen_menuList"];
        
        //create a dictionary for the dynamic screen.
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"error view controller has no itemId", @"itemId",
                              @"BT_screen_menuList", @"itemType",
                              @"Plugin not found?", @"navBarTitleText", nil];
        [returnScreen setJsonVars:dict];
    
    }
	return returnScreen;
}


//getThemeDataByItemId...
-(BT_item *)getThemeDataByItemId:(NSString *)theThemeItemId{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"getThemeDataByItemId %@", theThemeItemId]];
	int foundIt = 0;
	BT_item *returnTheme = nil;
	for(int i = 0; i < [[self themes] count]; i++){
		BT_item *thisTheme = (BT_item *)[[self themes] objectAtIndex:i];
		if([[thisTheme itemId] isEqualToString:theThemeItemId]){
			foundIt = 1;
			returnTheme = thisTheme;
			break;
		}			
	}
	if(foundIt == 1){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"returning BT_theme object with itemId: %@",theThemeItemId]];
	}else{
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"could not find BT_theme with this itemId: %@", theThemeItemId]];
	}
	return returnTheme;
}


//rgetMenuDataByItemId...
-(BT_item *)getMenuDataByItemId:(NSString *)theMenuItemId{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"getMenuDataByItemId %@", theMenuItemId]];
	int foundIt = 0;
	BT_item *returnMenu = nil;
	for(int i = 0; i < [[self menus] count]; i++){
		BT_item *thisMenu = (BT_item *)[[self menus] objectAtIndex:i];
		if([[thisMenu itemId] isEqualToString:theMenuItemId]){
			foundIt = 1;
			returnMenu = thisMenu;
			break;
		}
	}
	if(foundIt == 1){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"returning BT_menu object with itemId: %@", theMenuItemId]];
	}else{
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"could not find BT_menu with this itemId: %@", theMenuItemId]];
	}
	return returnMenu;
}



//build application interface.
-(void)buildInterface{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"buildInterface app interface%@",@""]];
	
	/*
		1) 	Create a navigation controller interface or a tabbed navigation interface if we have an array of tabs.
		2) 	Create an optional splash screen, bring it to the front (splash screens remove themselves).
	*/
    
    //need to figure out if device is iOS 7 or earlier for statusBar and navigationBar setup...
    int iosVer = 7;
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        iosVer = 6;
    }
	
	//before we start, set the rootTheme if we have one..
	if([self.themes count] > 0){
 		self.rootTheme = [self.themes objectAtIndex:0];
	}
    
    //init the rootBackgroundView...
    rootBackgroundView = [[BT_background_view alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    rootBackgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	1A) If this app does NOT have any tabs in it's tabs array, create a single navigation controller app with 
	//		the first screen in the list of screens as the home screen
	if([self.tabs count] < 1){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"building a single navigation controller app%@", @""]];
		if([self.screens count] > 0){
			
			//screen data for the home screen
			BT_item *theScreen = [self.screens objectAtIndex:0];
			[theScreen setIsHomeScreen:TRUE];
			
			//remember this screen as the "currently loaded screen", also make it the "previously loaded screen"
			[self setCurrentScreenData:theScreen];
			[self setPreviousScreenData:theScreen];

			//if theScreen has an audio file..load it in the delegate
			if([[BT_strings getJsonPropertyValue:theScreen.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3){
			
				//appDelegate
				robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
			
				//start audio in different thread to prevent UI blocking
				[NSThread detachNewThreadSelector: @selector(loadAudioForScreen:) toTarget:appDelegate withObject:theScreen];

			}
			
			//initialize a view controller for the appropriate screen type for the home screen
			BT_viewController *useViewController = (BT_viewController *)[self getViewControllerForScreen:theScreen];
			
			//initizlize the navigation controller
			rootNavController = [[BT_navController alloc] initWithRootViewController:useViewController];
            
            //add the background view to the nav controller's view...
            [rootNavController.view addSubview:rootBackgroundView];
            [rootNavController.view sendSubviewToBack:rootBackgroundView];
			
            //finish rootNavController setup...
            rootNavController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
			[rootNavController setDelegate:self];
            
			
		}else{
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"The application does not have any screens?%@", @""]];
		}
	}//end singleNavController	


	///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	1B) If this app uses tabs, create a tabbed navigation application and set the default screen for each tab
	//		to the defaultScreenGuid in the tabs data
	if([self.tabs count] > 0){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"building a tabbed based navigation app%@", @""]];
		
		if([self.screens count] > 0){
		
			//appDelegate
			robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
		
			//initialize the tab bar controller
			rootTabBarController = [[BT_tabBarController alloc] init];
			[rootTabBarController setDelegate:appDelegate];
			rootTabBarController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
			
            //add the background view to the tab controller's view...
            [rootTabBarController.view addSubview:rootBackgroundView];
            [rootTabBarController.view sendSubviewToBack:rootBackgroundView];

			//fill a temporary array of view controllers to assign to tab bar controller...
			NSMutableArray *tmpViewControllers = [[NSMutableArray alloc] init];	
			
			//loop through each tab bar item in application data
			for(int i = 0; i < [[self tabs] count]; i++){
							
				//this tab
				BT_item *thisTab = (BT_item *)[[self tabs] objectAtIndex:i];
				NSString *textLabel = [[thisTab jsonVars] objectForKey:@"textLabel"];				
				UIImage *tabIcon = [UIImage imageNamed:[[thisTab jsonVars] objectForKey:@"iconName"]];				

				//get the screen from the apps array of screens for this tab's view controller
				if([[thisTab jsonVars] objectForKey:@"homeScreenItemId"]){
				
					BT_item *thisTabsDefaultScreenData = [self getScreenDataByItemId:[[thisTab jsonVars] objectForKey:@"homeScreenItemId"]];
					
					//if this is the first tab in the list, remember it as the "currently loaded screen", also make it the "previously loaded screen"
					if(i == 0){
						[self setCurrentScreenData:thisTabsDefaultScreenData];
						[self setPreviousScreenData:thisTabsDefaultScreenData];
						[thisTabsDefaultScreenData setIsHomeScreen:TRUE];
						
						//if theScreen has an audio file..load it in the delegate
						if([[BT_strings getJsonPropertyValue:thisTabsDefaultScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3){
						
							//appDelegate
							robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
						
							//initialize audio in different thread to prevent UI blocking
							[NSThread detachNewThreadSelector: @selector(loadAudioForScreen:) toTarget:appDelegate withObject:thisTabsDefaultScreenData];

						}						
						
					}	
					
					//initialize a view controller for this type of screen (ClassName == BT_item.screenType)
					BT_viewController *thisTabsDefaultViewController = (BT_viewController *)[self getViewControllerForScreen:thisTabsDefaultScreenData];
					thisTabsDefaultViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

					//initialize a navigation controller using the view controller
					BT_navController *thisTabsNavController = [[BT_navController alloc] initWithRootViewController:thisTabsDefaultViewController];
					[thisTabsNavController setDelegate:self];
					[thisTabsNavController.tabBarItem setTitle:textLabel];
					[thisTabsNavController.tabBarItem setImage:tabIcon];
					
					//add this navigation controller to the temporary array of view controllers
					[tmpViewControllers addObject:thisTabsNavController];
                    
					
					
				}else{
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"ERROR: This tab does not have a homeScreenItemId in it's configuration data%@", @""]];
				}
				
			}//end for each tab in this apps list array of tabs
            

			//customize the tab bar color...
            if(self.rootTheme != nil){
				NSString *tabBarColor = [BT_strings getStyleValueForScreen:self.rootTheme nameOfProperty:@"tabBarColor" defaultValue:@""];
                if([tabBarColor length] > 1){
                    UIColor *tmpColor = [BT_color getColorFromHexString:tabBarColor];
                    [[rootTabBarController tabBar] setBackgroundColor:tmpColor];
                    
                    /*  UCOMMENT THIS TO SET THE TAB BAR BACKGROUND IMAGE AND SELECTED IMAGES
                        UIImage *tabBackgroundImg = [[UIImage imageNamed:@"tab-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
                        UIImage *tabSelectedImage = [UIImage imageNamed:@"tab-background-selected.png"];
                        [[rootTabBarController tabBar] setBackgroundImage:tabBackgroundImg];
                        [[rootTabBarController tabBar] setSelectionIndicatorImage:tabSelectedImage];
                        [[rootTabBarController tabBar] setSelectedImageTintColor:[UIColor whiteColor]];
                     */
                }
                
            }
				
			//assign temporary array of view controllers to tab bar controller
			rootTabBarController.viewControllers = tmpViewControllers;
			
			//if we have tabs..(something seriously wrong if we don't!)
			if([tmpViewControllers count] > 0){
				
				//select first tab
				[rootTabBarController setSelectedIndex:0];
			
				//fire the viewWillAppear method in the selected tab
				[rootTabBarController.navigationController viewWillAppear:NO];
			}
		
		
		}else{
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"The application is a tabbed app but it does not have any screens?%@", @""]];
		}
		
	}//end tabBarController

	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	2) 	Add a splash screen if the selected theme uses one. This screen will remove itself after the
	//		screen.startTransitionAfterSeconds expires. This is normally set to a few seconds.
	if(self.rootTheme != nil && [self.themes count] > 0 && [self.screens count] > 0){
		if([[self.rootTheme.jsonVars objectForKey:@"splashScreenItemId"] length] > 0){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"initialzing a splash screen with itemId: %@", [self.rootTheme.jsonVars objectForKey:@"splashScreenItemId"]]];
			
			//get the BT_item from the screens array
			BT_item *splashScreenData = [self getScreenDataByItemId:[self.rootTheme.jsonVars objectForKey:@"splashScreenItemId"]];
			
			//initialize a view controller with ClassName == screenType
			UIViewController *splashViewController = [self getViewControllerForScreen:splashScreenData];
			[splashViewController.view setFrame:[[UIScreen mainScreen] bounds]];

			//add splash screen to appropriate navigation controller (see step 1)
			if(self.tabs.count > 0 && self.screens.count > 0){
				[rootTabBarController.view addSubview:[splashViewController view]];
				[rootTabBarController.view bringSubviewToFront:[splashViewController view]];
			}else{
				if(self.screens.count > 0){
					[rootNavController.view addSubview:[splashViewController view]];
					[rootNavController.view bringSubviewToFront:[splashViewController view]];
				}
			}
		
		}else{
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"This app does not use a splash screen%@", @""]];
		}
	}
	

}


//getViewControllerForScreen...
-(BT_viewController *)getViewControllerForScreen:(BT_item *)theScreenData{
	if([theScreenData itemId] == nil){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"getViewControllerForScreen: ERROR finding screen with itemId: %@", [theScreenData itemId]]];
	}else{
		if([theScreenData.itemNickname length] > 1){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"getViewControllerForScreen nickname: \"%@\" itemId: %@ type: %@", [theScreenData itemNickname], [theScreenData itemId], [theScreenData itemType]]];
		}else{
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"getViewControllerForScreen nickname: \"%@\" itemId: %@ type: %@", @"no nickname?", [theScreenData itemId], [theScreenData itemType]]];
		}
	}
	
	/*
     Instantiate a view controller with ClassName == BT_item.itemType. If the itemType is a custom plug-in we need to get
     the type of view controller to allocate from the JSON data...
     */
	
	//return this view controller.
	BT_viewController *theViewController = nil;
	NSString *theClassName = [theScreenData itemType];
    
    
    //are we loading a custom plugin?
    if([[theScreenData itemType] isEqualToString:@"BT_screen_plugIn"]){
        
        //get the class name of the custom UIViewController we want to load...
        theClassName = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"classFileName" defaultValue:@""];
        
    }
    
	//screenType required...
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if([theClassName length] > 0){
		Class theClass = NSClassFromString(theClassName);
		if(theClass != nil){
            SEL selector = NSSelectorFromString(@"alloc");
            if([theClass respondsToSelector:selector]){
				theViewController = [[theClass performSelector:selector] initWithScreenData:theScreenData];
				return theViewController;
			}
		}
		
	}//screenType length
    #pragma clang diagnostic pop
    
	if(theViewController == nil){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"getViewControllerForScreen: ERROR, could not initialize view controller for screen with itemId: %@", [theScreenData itemId]]];
		
        //json data for error screen...
        BT_item *errorData = [[BT_item alloc] init];
        [errorData setItemId:@"error view controller has no itemId"];
        [errorData setItemType:@"BT_screen_menuList"];
        
        //create a dictionary for the dynamic screen.
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"error view controller has no itemId", @"itemId",
                              @"BT_screen_menuList", @"itemType",
                              @"Plugin not found?", @"navBarTitleText", nil];
        [errorData setJsonVars:dict];
		
        //init the missing plugin vew config data view controller...
        theViewController = [[BT_plugin_missing alloc] initWithScreenData:errorData];
        
        
	}
	
	//should not be here.
	return theViewController;
	
}




@end











