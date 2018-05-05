/*
 *	Copyright 2015, Chris Ruddell
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

#import "CR_eventList.h"
#import "CR_calendarViewCell.h"
#import <EventKit/EventKit.h>
#import "CR_eventViewController.h"
#import "BT_imageTools.h"

@interface CR_eventList ()<EKEventEditViewDelegate>
@property (nonatomic, retain) EKEvent *selectedEvent;
@property (nonatomic, retain) UIView *backgroundView;
@end

@implementation CR_eventList
@synthesize menuItems, myTableView, headerImage;
@synthesize saveAsFileName, downloader, isLoading, didInit;
@synthesize imageHeight, imageWidth, tableHeight;
@synthesize imageFileName, imageURL,backgroundView;
@synthesize selectedEvent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    backgroundView = [UIView new];
    backgroundView.frame = self.view.frame;
    
    //init screen properties
    [self setDidInit:0];
    
    //flag not loading
    [self setIsLoading:FALSE];
    
    ////////////////////////////////////////////////////////////////////////////////////////
    //build the table that holds the menu items.
    self.myTableView = [BT_viewUtilities getTableViewForScreen:[self screenData]];
    self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.myTableView setDataSource:self];
    [self.myTableView setDelegate:self];
    
    //prevent scrolling?
    if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"preventAllScrolling" defaultValue:@""] isEqualToString:@"1"]){
        [self.myTableView setScrollEnabled:FALSE];
    }
    
    
    //check to see if iPad or which size iPhone and create different frame sizes if that is the case.
    robocats_appDelegate *appDelegate = (robocats_appDelegate *) [[UIApplication sharedApplication] delegate];
    if([appDelegate.rootDevice isIPad]){
        //imageHeight = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars:@"imageHeightIPad":@"300"] intValue];
        imageHeight = 360;
        imageWidth = 768;
        tableHeight = 1024 - imageHeight;
    }else {
        
        
        //imageHeight = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars:@"imageHeight":@"150"] intValue];
        imageHeight = 150;
        imageWidth = 320;
        if([UIScreen mainScreen].bounds.size.height == 568)
        {
            tableHeight = 568 -imageHeight;
        }else{
            tableHeight = 480 -imageHeight;
        }
    }
    
    //needs to take background color from the BT_Config file?
    
    
    //generate the frame and image for the header.
    headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,imageWidth,imageHeight)];
    [headerImage setContentMode:UIViewContentModeScaleAspectFit];
    headerImage.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin);
    UIImage *tmpImage = nil;
    imageFileName = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"imageFileName" defaultValue:@""];
    imageURL = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"imageURL" defaultValue:@""];
    
    
    //decided whether to get the image from project or one from a URL.  Default is from file if both possible.
    if([imageFileName length] > 0){
        //is it in the project?...
        if([BT_fileManager doesFileExistInBundle:imageFileName]){
            tmpImage = [UIImage imageNamed:imageFileName];
        }
    }else{
        if([imageURL length] > 0){
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"getting header image from:%@",imageURL]];
            //            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
            //            tmpImage =  [[UIImage alloc] initWithData:imageData];
            [self performSelectorInBackground:@selector(loadHeaderImage) withObject:nil];
        }
    }
    
    
    //sets the header image
    if(tmpImage != nil){
        [headerImage setImage:tmpImage];
        [backgroundView addSubview:headerImage];
    }
    
    
    //generate the frame for tableview right below the image.
    [backgroundView addSubview:myTableView];
    [self.myTableView setFrame:CGRectMake(0, imageHeight, imageWidth, tableHeight)];
    
    myTableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin);
    
    
    
    
    //create adView?
    if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"includeAds" defaultValue:@"0"] isEqualToString:@"1"]){
        [self createAdBannerView];
    }
    
    [self.view addSubview:backgroundView];
    
    self.saveAsFileName = [NSString stringWithFormat:@"screenData_%@.txt", [self.screenData itemId]];//original
    if ([BT_fileManager doesLocalFileExist:self.saveAsFileName]) [BT_fileManager deleteFile:self.saveAsFileName];
}


-(void)loadHeaderImage {
    headerImage.image = [self getImage:imageURL];
    [backgroundView addSubview:headerImage];
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [BT_debugger showIt:self theMessage:@"viewWillAppear"];
    
    //if we have not yet inited data..
    if(self.didInit == 0){
        [self performSelector:(@selector(loadData)) withObject:nil afterDelay:0.1];
        [self setDidInit:1];
    }
    
    //show adView?
    if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"includeAds" defaultValue:@"0"] isEqualToString:@"1"]){
        [self showHideAdView];
    }
    
    
    //set backgroundView image/color
    robocats_appDelegate*appDelegate = (robocats_appDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *bgColor = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundColor" defaultValue:@"clear"];
    NSString *bgImage = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageNameSmallDevice" defaultValue:@""];
    if ([appDelegate.rootDevice isIPad]) {
        bgImage = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageNameLargeDevice" defaultValue:@""];
    }
    
    if ([bgColor length]>0) {
        UIColor *bgColorObj = [BT_color getColorFromHexString:bgColor];
        backgroundView.backgroundColor = bgColorObj;
    }
    if ([bgImage length]>0) {
        UIImageView *bgImageView = [UIImageView new];
        bgImageView.frame = backgroundView.frame;
        [bgImageView setContentMode:UIViewContentModeScaleToFill];
        if ([BT_fileManager doesFileExistInBundle:bgImage]) {
            bgImageView.image = [UIImage imageNamed:bgImage];
        }
        else if ([BT_fileManager doesLocalFileExist:bgImage]) {
            bgImageView.image = [BT_fileManager getImageFromFile:bgImage];
        }
        [backgroundView addSubview:bgImageView];
        [backgroundView sendSubviewToBack:bgImageView];
    }
    

    
    self.myTableView.separatorColor = [UIColor blackColor];
    self.myTableView.separatorInset = UIEdgeInsetsZero;
    self.myTableView.backgroundColor = [UIColor clearColor];
    self.myTableView.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;

}

-(void)loadData {
    [self downloadData];
}

//download data
-(void)downloadData{
    
    //flag this as the current screen
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.rootApp.currentScreenData = self.screenData;
    
    //prevent interaction during operation
    [myTableView setScrollEnabled:FALSE];
    [myTableView setAllowsSelection:FALSE];
    
    //show progress
    [self showProgress];
    
    
    
    
    NSString *tmpURL = [NSString stringWithFormat:@"%@?action=getGoogleEvents&calendarId=%@",[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@""],[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"calendarId" defaultValue:@""]];
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"downloading events from:%@",tmpURL]];
    
        //fire downloader to fetch and results
        downloader = [[BT_downloader alloc] init];
        [downloader setSaveAsFileName:[self saveAsFileName]];
        [downloader setSaveAsFileType:@"text"];
        [downloader setUrlString:tmpURL];
        [downloader setDelegate:self];
        [downloader downloadFile];
    
}

//parse screen data
-(void)parseScreenData:(NSString *)theData{
    [BT_debugger showIt:self theMessage:@"parseScreenData"];
    
    //prevent interaction during operation
    [myTableView setScrollEnabled:FALSE];
    [myTableView setAllowsSelection:FALSE];
    
    @try {
        
        //arrays for screenData
        self.menuItems = [[NSMutableArray alloc] init];
        
        //create dictionary from the JSON string
        SBJsonParser *parser = [SBJsonParser new];
        id jsonData = [parser objectWithString:theData];
        
        
        if(!jsonData){
            
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"ERROR parsing JSON: %@ from:\n%@", parser.errorTrace, theData]];
            [self showAlert:NSLocalizedString(@"errorTitle",@"~ Error ~") theMessage:NSLocalizedString(@"appParseError", @"There was a problem parsing some configuration data. Please make sure that it is well-formed") alertTag:0];
            [BT_fileManager deleteFile:[self saveAsFileName]];
            
        }else{
            
            if([jsonData objectForKey:@"childItems"]){
                NSArray *tmpMenuItems = [jsonData objectForKey:@"childItems"];
                for(NSDictionary *tmpMenuItem in tmpMenuItems){
                    BT_item *thisMenuItem = [[BT_item alloc] init];
                    thisMenuItem.itemId = [tmpMenuItem objectForKey:@"itemId"];
                    thisMenuItem.itemType = [tmpMenuItem objectForKey:@"itemType"];
                    thisMenuItem.jsonVars = tmpMenuItem;
                    [self.menuItems addObject:thisMenuItem];
                }
            }
            
            //layout screen
            [self layoutScreen];
            
        }
        
    }@catch (NSException * e) {
        
        //delete bogus data, show alert
        [BT_fileManager deleteFile:[self saveAsFileName]];
        [self showAlert:NSLocalizedString(@"errorTitle",@"~ Error ~") theMessage:NSLocalizedString(@"appParseError", @"There was a problem parsing some configuration data. Please make sure that it is well-formed") alertTag:0];
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"error parsing screen data: %@", e]];
        
    }
    
}

//build screen
-(void)layoutScreen{
    [BT_debugger showIt:self theMessage:@"layoutScreen"];
    
    //if we did not have any menu items...
    if(self.menuItems.count < 1){
        
        for(int i = 0; i < 5; i++){
            
            //create a menu item from the data
            BT_item *thisMenuItemData = [[BT_item alloc] init];
            [thisMenuItemData setJsonVars:nil];
            [thisMenuItemData setItemId:@""];
            [thisMenuItemData setItemType:@"BT_menuItem"];
            [self.menuItems addObject:thisMenuItemData];
            
        }
        
        //show message
        //[self showAlert:nil:NSLocalizedString(@"noListItems",@"This menu has no list items?"):0];
        [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@",NSLocalizedString(@"noListItems",@"This menu has no list items?")]];
        
    }
    
    //enable interaction again (unless owner turned it off)
    if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"preventAllScrolling" defaultValue:@""] isEqualToString:@"1"]){
        [self.myTableView setScrollEnabled:FALSE];
    }else{
        [myTableView setScrollEnabled:TRUE];
    }
    [myTableView setAllowsSelection:TRUE];
    
    //reload table
    [self.myTableView reloadData];
    
    //flag done loading
    self.isLoading = FALSE;
    
    
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




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell_%li", (long)indexPath.row];
    CR_calendarViewCell *cell = (CR_calendarViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        
        //init our custom cell
        cell = [[CR_calendarViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    //this menu item
    BT_item *thisMenuItemData = [self.menuItems objectAtIndex:indexPath.row];
    [cell setTheMenuItemData:thisMenuItemData];
    [cell setTheParentMenuScreenData:[self screenData]];
    [cell configureCell];
    
    
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    //return
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didSelectRowAtIndexPath: Selected Row: %li", (long)indexPath.row]];
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    //on iOS 6.0+, we must ask for access to calendar before we can show an event page
    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        //        //NSLog(@"requesting access");
        //iOS >= 6.0
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
            if (granted){
                [self showEvent:(int)indexPath.row];
            }
            else {
                [self showAlert:@"Oops" theMessage:@"You denied access to the calendar.  You can change this in the privacy section in the 'Settings' app." alertTag:0];
            }
        }];
    }
    else [self showEvent:(int)indexPath.row];
    
    
    
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    if (action==EKEventEditViewActionCanceled) {
        //        //NSLog(@"event cancelled");
    }
    else if (action==EKEventEditViewActionSaved) {
        //        //NSLog(@"event done");
        [self addToCalendar];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)showEvent:(int)menuItem {
    [BT_debugger showIt:self message:@"showEvent"];
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    //pass this menu item to the tapForMenuItem method
    BT_item *thisMenuItem = [self.menuItems objectAtIndex:menuItem];
    
    NSString *summary = [BT_strings getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"titleText" defaultValue:@""];
    
    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
    event.title = summary;
    event.URL = [NSURL URLWithString:[BT_strings getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"htmlLink" defaultValue:@""]];
    
    //get dates
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *startDate = [dateFormatter dateFromString:[BT_strings getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"startDate" defaultValue:@""]];
    NSDate *endDate = [dateFormatter dateFromString:[BT_strings getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"endDate" defaultValue:@""]];
    
    //event.attendees = controller2.who;
    // Display a details screen for the selected event/row.
    event.startDate = startDate;
    event.endDate = endDate;
    event.location = [BT_strings getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"location" defaultValue:@""];
    CR_eventViewController *vc = [CR_eventViewController new];
    
    vc.event = event;
    vc.editViewDelegate = self;
    vc.eventStore = eventStore;
    
    //change the font of the nav title
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    label.text = @"";
    
    // emboss in the same way as the native title
    [label setShadowColor:[UIColor darkGrayColor]];
    [label setShadowOffset:CGSizeMake(0, -0.5)];
    vc.navigationItem.titleView = label;
    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Add to Calendar"
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(addToCalendar)];
    
    vc.navigationItem.leftBarButtonItem = addButton;
    [self presentViewController:vc animated:YES completion:nil];
    
    selectedEvent = event;
}

-(void)addToCalendar {
    EKEvent *eventToSave = selectedEvent;
    
    EKEventStore *store = [[EKEventStore alloc] init];
    
    if([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {

        //iOS >= 6.0
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
            if (granted){
                //                //NSLog(@"user did allow access to calendar");
                NSError *error;
                //                //NSLog(@"adding the event to calendar on 6");
                @try {
                    EKEvent *tmpEvent = [EKEvent eventWithEventStore:store];
                    //                    //NSLog(@"tmpEvent created");
                    tmpEvent.title = eventToSave.title;
                    tmpEvent.notes = eventToSave.notes;
                    tmpEvent.endDate = eventToSave.endDate;
                    tmpEvent.startDate = eventToSave.startDate;
                    tmpEvent.calendar = eventToSave.calendar;
                    //                    //NSLog(@"attempting to save");
                    [store saveEvent:tmpEvent span:EKSpanThisEvent commit:YES error:&error];
                    if (error) //NSLog(@"there was an error:%@", error);
                        //                    //NSLog(@"saved...");
                        
                        
                        [self alertEventAdded];
                    
                    
                }
                @catch (NSException *e) {
                    //                    //NSLog(@"could not add:%@", e);
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"exception adding event to calendar:%@",e]];
                }
            }
            else {
                //                //NSLog(@"User did not allow access to calendar");
            }
        }];
        
    }
    else {
        //iOS < 6.0
        NSError *error;
        //        //NSLog(@"adding the event to calendar");
        EKEvent *tmpEvent = [EKEvent eventWithEventStore:store];
        tmpEvent.title = eventToSave.title;
        tmpEvent.notes = eventToSave.notes;
        tmpEvent.endDate = eventToSave.endDate;
        tmpEvent.startDate = eventToSave.startDate;
        tmpEvent.calendar = eventToSave.calendar;
        [store saveEvent:tmpEvent span:EKSpanThisEvent commit:YES error:&error];
        if (error) [BT_debugger showIt:self message:[NSString stringWithFormat:@"There was an error:%@", error]];
        [self performSelector:@selector(alertEventAdded)];
    }
    //NSLog(@"finished");
}

- (void)alertEventAdded{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Added"
                                                    message:@"Event was added to your default calendar"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
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
    [self hideProgress];
    
    //if message contains "error", look for previously cached data...
    if([message rangeOfString:@"ERROR-1968" options:NSCaseInsensitiveSearch].location != NSNotFound){
        [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"download error: There was a problem downloading data from the internet.%@", message]];
        ////NSLog(@"Message: %@", message);
        
        //show alert
        [self showAlert:nil theMessage:NSLocalizedString(@"downloadError", @"There was a problem downloading some data. Check your internet connection then try again.") alertTag:0];
        
        //show local data if it exists
        if([BT_fileManager doesLocalFileExist:[self saveAsFileName]]){
            
            //use stale data if we have it
            NSString *staleData = [BT_fileManager readTextFileFromCacheWithEncoding:self.saveAsFileName encodingFlag:-1];
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"building screen from stale configuration data: %@", [self saveAsFileName]]];
            [self parseScreenData:staleData];
            
        }else{
            
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"There is no local data availalbe for this screen?%@", @""]];
            
            //if we have items... else.. show alert
            if(self.menuItems.count > 0){
                [self layoutScreen];
            }
            
        }
        
        
    }else{
        
        //parse previously saved data
        if([BT_fileManager doesLocalFileExist:[self saveAsFileName]]){
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"parsing downloaded screen data.%@", @""]];
            NSString *downloadedData = [BT_fileManager readTextFileFromCacheWithEncoding:[self saveAsFileName] encodingFlag:-1];
            [self parseScreenData:downloadedData];
            
        }else{
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"Error caching downloaded file: %@", [self saveAsFileName]]];
            [self layoutScreen];
            
            //show alert
            [self showAlert:nil theMessage:NSLocalizedString(@"appDownloadError", @"There was a problem saving some data downloaded from the internet.") alertTag:0];
            
        }
        
    }
    
}

//allows us to check to see if we pulled-down to refresh
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [self checkIsLoading];
}
-(void)checkIsLoading{
    if(isLoading){
        return;
    }else{
        //how far down did we pull?
        double down = myTableView.contentOffset.y;
        if(down <= -65){
            if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@"1"] length] > 3){
                [self downloadData];
            }
        }
    }
}

//get image
-(UIImage*)getImage:(NSString *)imageLocation {
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"getImage:%@",imageLocation]];
    UIImage *tmpImage = [[UIImage alloc]init];
    
    //check if this is from a URL or not
    if (imageLocation.length<4) {
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"\n\n\ngetImage: image location is empty!"]];
        return nil;
    }
    NSString *firstFour = [imageLocation substringToIndex:4];
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"First Four Characters of Image Location:%@", firstFour]];
    if ([[firstFour uppercaseString] isEqualToString:@"HTTP"]) {
        //found url - check if cached image exists. If so, use it. If not, download and cache
        NSString *imageName = [BT_strings getFileNameFromURL:imageLocation];
        
        if ([BT_fileManager doesLocalFileExist:imageName]) tmpImage = [BT_fileManager getImageFromFile:imageName];
        else {
            tmpImage = [BT_imageTools getImageFromURL:imageLocation];
            [BT_fileManager saveImageToFile:tmpImage fileName:imageName];
        }
    }
    else {
        //not a url - attempt to get from bundle
        if ([BT_fileManager doesFileExistInBundle:imageLocation])
            tmpImage = [UIImage imageNamed:imageLocation];
    }
    
    return tmpImage;
}


@end
