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
#import "BT_contextMenu.h"

@implementation BT_contextMenu
@synthesize menuData, menuItems, menuTable;

-(id)initWithMenuData:(BT_item *)theMenuData{
	if((self = [super init])){
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"INIT %@", @""]];
 		
        //this screen wants a full screen layout...
        self.wantsFullScreenLayout = YES;
        
 		//set menu data...
		[self setMenuData:menuData];
        
        //set the frame for the view...
 		[self.view setFrame:[[UIScreen mainScreen] bounds]];
        self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[self.view setUserInteractionEnabled:TRUE];
        
		//mask entire screen with a subview...
		self.mask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.mask.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self.mask setBackgroundColor:[UIColor blackColor]];
        [self.mask setAlpha:.25];
        
        //add the mask as a subView...
		[self.view addSubview:self.mask];
        
        //table layout options...
        int tableRowHeight = 30;
        
        //table size depends on device, it's updated in the loadData method...
        menuTable = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStylePlain];
        [menuTable setRowHeight:tableRowHeight];
        [menuTable setBackgroundColor:[UIColor whiteColor]];
        [menuTable setSectionHeaderHeight:0];
        [menuTable setShowsVerticalScrollIndicator:FALSE];
        [menuTable setShowsHorizontalScrollIndicator:FALSE];
        [menuTable setDataSource:self];
        [menuTable setDelegate:self];
        
        //ios7 doens't extend separator to left edge for each row. Lame!
        if([menuTable respondsToSelector:@selector(setSeparatorInset:)]){
            [menuTable setSeparatorInset:UIEdgeInsetsZero];
        }
        
        //add the table as a sub-view...
        [self.view addSubview:menuTable];
        
		
    }
    return self;
}


//loadData...
-(void)loadData{
	[BT_debugger showIt:self theMessage:@"loadData"];
	
    //init the items array
    self.menuItems = [[NSMutableArray alloc] init];
    
    //fill using childItems in menuData...
	if([[self.menuData jsonVars] objectForKey:@"childItems"]){
        
		NSArray *tmpMenuItems = [[self.menuData jsonVars] objectForKey:@"childItems"];
		for(NSDictionary *tmpMenuItem in tmpMenuItems){
			BT_item *thisMenuItem = [[BT_item alloc] init];
			thisMenuItem.itemId = [tmpMenuItem objectForKey:@"itemId"];
			thisMenuItem.itemType = [tmpMenuItem objectForKey:@"itemType"];
			thisMenuItem.jsonVars = tmpMenuItem;
			[self.menuItems addObject:thisMenuItem];
		}
        
	}
    
    //add the cancel item at the end...
    BT_item *cancelItem = [[BT_item alloc] init];
    [cancelItem setItemId:@"na"];
    [cancelItem setItemType:@"BT_menuItem"];
    
    //create a dictionary for the dynamic screen.
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"na", @"itemId",
                          @"BT_menuItem", @"itemType",
                          @"Cancel", @"titleText", nil];
    [cancelItem setJsonVars:dict];
    [self.menuItems addObject:cancelItem];
    
    
    //add a blank item at end so the last element shows the bottom separator...
    BT_item *blankItem = [[BT_item alloc] init];
    [blankItem setItemId:@"na"];
    [blankItem setItemType:@"BT_menuItem"];
    
    //create a dictionary for the dynamic screen.
    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"na", @"itemId",
                          @"BT_menuItem", @"itemType",
                          @"", @"titleText", nil];
    [blankItem setJsonVars:dict2];
    [self.menuItems addObject:blankItem];
    
    //refresh table...
    [self.menuTable reloadData];
	
}



//touchesBegan...
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"touchesBegan%@", @""]];
    
    //app delegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideContextMenu];
    
}


//////////////////////////////////////////////////////////////
//UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuItems count];
}



//table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *CellIdentifier = [NSString stringWithFormat:@"cell_%li", (long)indexPath.row];
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil){
        
		//init our custom cell
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryNone;
		
	}
    
	//this menu item...
	BT_item *thisMenuItemData = [self.menuItems objectAtIndex:indexPath.row];
	NSString *title = [BT_strings getJsonPropertyValue:thisMenuItemData.jsonVars nameOfProperty:@"titleText" defaultValue:@""];
    [cell.textLabel setText:title];
    
    //set cell font...
    UIFont *rowFont = [UIFont fontWithName: @"Helvetica" size: 11.0];
    cell.textLabel.font = rowFont;
	
    //set cell selection color...
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
	//return
	return cell;
    
}

//on row select
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didSelectRowAtIndexPath: Selected Row: %li", (long)indexPath.row]];

    //appDelegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //pass this menu item to the tapForMenuItem method
	BT_item *thisMenuItem = [self.menuItems objectAtIndex:indexPath.row];
	if([thisMenuItem jsonVars] != nil){
        
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
            
            //hide table...
            [appDelegate hideContextMenu];
            
            //load screen...
            BT_viewController *parentScreen = [appDelegate getViewController];
            [parentScreen loadScreenObject:screenObjectToLoad];
            
		}else{
			
            //hide table...
            [appDelegate hideContextMenu];
            
		}
		
	}else{
        
        //hide table...
        [appDelegate hideContextMenu];
        
	}
	
}

//viewForFooterInSection...
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    return view;
}





@end







