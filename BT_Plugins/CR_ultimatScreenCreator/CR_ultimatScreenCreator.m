/*
 *	Copyright Chris Ruddell, www.buzz-tools.com
 *  Version 1.3
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
#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

#import "CR_ultimatScreenCreator.h"
#import "BT_imageTools.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

@implementation CR_ultimatScreenCreator
@synthesize screenData, scrollView, saveAsFileName, menuItems, downloader, isLoading, didInit, activeField, scrollOffset, myTableView, tableItems, headerHeight, tableRowAsButtons, tableRowFontColor, tableFontSize, tableRowHeight, tableRowSelectStyle, tableListStyle,tableFontSizeLarge,tableDescriptionSizeLarge,tableDescriptionSize,listTitleHeightLargeDevice,listRowHeightLargeDevice,listTitleHeightSmallDevice,tableRowBackgroundColor, rotationView, theMovieMask, playButton, buttonPressed, arrayOfElements;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrayOfElements = [NSMutableArray new];
    
    //add scrollview
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:scrollView];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTapped)];
    [gestureRecognizer setDelegate:self];
    [scrollView addGestureRecognizer:gestureRecognizer];
    
    //rotation view
    rotationView = [UIView new];
    rotationView.frame = CGRectMake(0, 0, 1024, 768);
    rotationView.backgroundColor = [UIColor lightGrayColor];
    UIImageView *rotateImage = [[UIImageView alloc] initWithFrame:CGRectMake((1024-200)/2, (768-200)/2, 200, 200)];
    rotateImage.image = [UIImage imageNamed:@"cr_rotate_left.png"];
    [rotationView addSubview:rotateImage];
    rotationView.hidden = true;
    [self.view addSubview:rotationView];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!didInit) {
        self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        didInit = true;
    }
    
    
    //get current rotation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation==UIInterfaceOrientationLandscapeLeft || orientation==UIInterfaceOrientationLandscapeRight) rotationView.hidden = false;
    else rotationView.hidden = true;
    
    [self loadSavedDataToFields];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight)
        rotationView.hidden = false;
    else rotationView.hidden = true;
}

//load data
-(void)loadData{
    [BT_debugger showIt:self theMessage:@"loadData"];
    
    //start by filling the list from the configuration file, use these if we can't get anything from a URL
    robocats_appDelegate *appDelegate = (robocats_appDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *jsonName = @"elements";
    if (appDelegate.rootDevice.isIPad) jsonName = @"ipadelements";
    
    if([[self.screenData jsonVars] objectForKey:jsonName]){
        
        //init the items array
        self.menuItems = [[NSMutableArray alloc] init];
        
        NSString *elementsJson = [[self.screenData jsonVars] objectForKey:jsonName];
        elementsJson = [elementsJson stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        elementsJson = [elementsJson stringByReplacingOccurrencesOfString:@"##" withString:@"\""];
        elementsJson = [elementsJson stringByReplacingOccurrencesOfString:@"&#34;" withString:@"\\\""];
        elementsJson = [elementsJson stringByReplacingOccurrencesOfString:@"&&" withString:@"{"];
        elementsJson = [elementsJson stringByReplacingOccurrencesOfString:@"%%" withString:@"}"];
        
        @try {
            //create dictionary from the JSON string
            SBJsonParser *parser = [SBJsonParser new];
            id jsonData = [parser objectWithString:elementsJson];
            
            if(!jsonData){
                
                [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"ERROR parsing JSON: %@", parser.errorTrace]];
                
            }else{
                
                CGFloat contentHeight = 0;
                CGFloat contentWidth = 0;
                int elementCounter = 1000;
                for(NSDictionary *tmpMenuItem in jsonData){
                    BT_item *thisMenuItem = [[BT_item alloc] init];
                    thisMenuItem.itemId = [tmpMenuItem objectForKey:@"itemId"];
                    thisMenuItem.itemType = [tmpMenuItem objectForKey:@"itemType"];
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"adding %@ to screen", thisMenuItem.itemType]];
                    thisMenuItem.jsonVars = tmpMenuItem;
                    
                    
                    //properties
                    int elementHeight = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementHeight" defaultValue:@"0"] intValue];
                    int elementWidth = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementWidth" defaultValue:@"0"] intValue];
                    int elementTop = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTop" defaultValue:@"0"] intValue];
                    int elementLeft = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementLeft" defaultValue:@"0"] intValue];
                    NSString *elementText = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementText" defaultValue:@"0"];
                    NSString *elementBackgroundColor = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementBackgroundColor" defaultValue:@"clear"];
                    NSString *elementFontColor = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementFontColor" defaultValue:@"#000000"];
                    NSString *elementImage = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementImage" defaultValue:@""];
                    int elementFontSize = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementFontSize" defaultValue:@"12"] intValue];
                    CGFloat alphaVal = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementAlpha" defaultValue:@"1"] floatValue];
                    if (alphaVal>1) alphaVal = alphaVal/100;
                    
                    
                    CGRect theFrame = CGRectMake(elementLeft, elementTop, elementWidth, elementHeight);
                    
                    
                    //add element to screen with properties
                    //depends on itemType
                    if ([thisMenuItem.itemType isEqualToString:@"label"]) {
                        UILabel *tmpLabel = [[UILabel alloc] init];
                        tmpLabel.textColor = [BT_color getColorFromHexString:elementFontColor];
                        tmpLabel.backgroundColor = [BT_color getColorFromHexString:elementBackgroundColor];
                        tmpLabel.frame = theFrame;
                        tmpLabel.tag = elementCounter;
                        tmpLabel.text = elementText;
                        tmpLabel.font = [UIFont systemFontOfSize:elementFontSize];
                        tmpLabel.alpha = alphaVal;
                        [scrollView addSubview:tmpLabel];
                        [arrayOfElements addObject:tmpLabel];
                        
                    }
                    else if ([thisMenuItem.itemType isEqualToString:@"button"]) {
                        UIButton *tmpButton = [[UIButton alloc] init];
                        tmpButton.frame = theFrame;
                        tmpButton.tag = elementCounter;
                        tmpButton.alpha = alphaVal;
                        [tmpButton setTitle:elementText forState:UIControlStateNormal];
                        tmpButton.titleLabel.font = [UIFont systemFontOfSize:elementFontSize];
                        [scrollView addSubview:tmpButton];
                        elementFontColor = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementFontColor" defaultValue:@"#385487"];
                        [tmpButton setTitleColor:[BT_color getColorFromHexString:elementFontColor] forState:UIControlStateNormal];
                        tmpButton.backgroundColor = [BT_color getColorFromHexString:elementBackgroundColor];
                        [tmpButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                        //image?
                        if (elementImage.length>0) {
                            UIImage *theImage = [self getImage:elementImage];
                            if (theImage) [tmpButton setImage:theImage forState:UIControlStateNormal];
                        }
                        [arrayOfElements addObject:tmpButton];
                    }
                    else if ([thisMenuItem.itemType isEqualToString:@"image"]) {
                        UIImageView *tmpImageView = [[UIImageView alloc] init];
                        tmpImageView.frame = theFrame;
                        tmpImageView.tag = elementCounter;
                        tmpImageView.alpha = alphaVal;
                        tmpImageView.backgroundColor = [BT_color getColorFromHexString:elementBackgroundColor];
                        if (elementImage.length>0) tmpImageView.image = [self getImage:elementImage];
                        [self.scrollView addSubview:tmpImageView];
                        [arrayOfElements addObject:tmpImageView];
                    }
                    else if ([thisMenuItem.itemType isEqualToString:@"map"]) {
                        MKMapView *tmpMap = [[MKMapView alloc] init];
                        tmpMap.frame = theFrame;
                        tmpMap.tag = elementCounter;
                        tmpMap.alpha = alphaVal;
                        double elementMapZoomLevel = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementMapZoomLevel" defaultValue:@"10"] doubleValue];
                        CLLocationCoordinate2D tmpLocation;
                        tmpLocation.latitude = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementMapLatitude" defaultValue:@""] doubleValue];
                        tmpLocation.longitude = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementMapLongitude" defaultValue:@""] doubleValue];
                        
                        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(tmpLocation, 500, 500);
                        MKCoordinateRegion adjustedRegion = [tmpMap regionThatFits:viewRegion];
                        [tmpMap setRegion:adjustedRegion animated:YES];
                        
                        MKCoordinateSpan mapSpan = [self coordinateSpanWithMapView:tmpMap centerCoordinate:tmpLocation andZoomLevel:elementMapZoomLevel];
                        MKCoordinateRegion region = MKCoordinateRegionMake(tmpLocation, mapSpan);
                        
                        [tmpMap setRegion:region animated:YES];
                        
                        //allow zoom?
                        BOOL elementMapAllowZoom = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementMapAllowZoom" defaultValue:@"1"] boolValue];
                        tmpMap.zoomEnabled = elementMapAllowZoom;
                        BOOL elementMapAllowScroll = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementMapAllowScroll" defaultValue:@"1"] boolValue];
                        tmpMap.scrollEnabled = elementMapAllowScroll;
                        NSString *elementMapLoadScreenOnClick = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementMapLoadScreenOnClick" defaultValue:@""];
                        if (elementMapLoadScreenOnClick.length>0) {
                            cr_ultimateTapRecognizer *mapTapped = [[cr_ultimateTapRecognizer alloc] initWithTarget:self action:@selector(mapWasTapped:)];
                            mapTapped.tag = elementCounter;
                            [tmpMap addGestureRecognizer:mapTapped];
                        }
                        
                        
                        
                        [self.scrollView addSubview:tmpMap];
                        [arrayOfElements addObject:tmpMap];
                    }
                    else if ([thisMenuItem.itemType isEqualToString:@"web"]) {
                        UIWebView *tmpWeb = [[UIWebView alloc] init];
                        tmpWeb.frame = theFrame;
                        tmpWeb.tag = elementCounter;
                        tmpWeb.alpha = alphaVal;
                        NSString *elementWebUrl = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementWebUrl" defaultValue:@"http://www.buzztouch.com"];
                        BOOL attemptZoom = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementWebAttemptZoom" defaultValue:@"0"] boolValue];
                        NSURL *theURL = [NSURL URLWithString:elementWebUrl];
                        
                        if (attemptZoom) {
                            NSString *html = [NSString stringWithContentsOfURL:theURL encoding:[NSString defaultCStringEncoding] error:nil];
                            NSRange range = [html rangeOfString:@"<body"];
                            
                            if(range.location != NSNotFound) {
                                // Adjust style for mobile
                                float inset = 40;
                                NSString *style = [NSString stringWithFormat:@"<style>div {max-width: %fpx;}</style>", self.view.bounds.size.width - inset];
                                html = [NSString stringWithFormat:@"%@%@%@", [html substringToIndex:range.location], style, [html substringFromIndex:range.location]];
                            }
                            
                            [tmpWeb loadHTMLString:html baseURL:theURL];
                        }
                        else {
                            NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL];
                            [tmpWeb loadRequest:theRequest];
                            tmpWeb.delegate = self;
                            tmpWeb.scalesPageToFit = YES;
                        }
                        
                        [self.scrollView addSubview:tmpWeb];
                        [arrayOfElements addObject:tmpWeb];
                    }
                    else if ([thisMenuItem.itemType isEqualToString:@"textField"]) {
                        UITextField *tmpField = [[UITextField alloc] init];
                        tmpField.frame = theFrame;
                        tmpField.tag = elementCounter;
                        tmpField.alpha = alphaVal;
                        NSString *placeholder = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTextPlaceholder" defaultValue:@""];
                        tmpField.placeholder = placeholder;
                        tmpField.delegate = self;
                        tmpField.borderStyle = UITextBorderStyleRoundedRect;
                        tmpField.backgroundColor = [BT_color getColorFromHexString:elementBackgroundColor];
                        [self.scrollView addSubview:tmpField];
                        [arrayOfElements addObject:tmpField];
                    }
                    else if ([thisMenuItem.itemType isEqualToString:@"slider"]) {
                        cr_ultimateSlider *tmpSlider = [[cr_ultimateSlider alloc] init];
                        tmpSlider.frame = theFrame;
                        tmpSlider.alpha = alphaVal;
                        int min = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementSliderMinimum" defaultValue:@"0"] intValue];
                        int max = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementSliderMaximum" defaultValue:@"100"] intValue];
                        int def = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementSliderDefault" defaultValue:@"50"] intValue];
                        tmpSlider.minimumValue = min;
                        tmpSlider.maximumValue = max;
                        tmpSlider.tag = elementCounter;
                        tmpSlider.value = def;
                        [tmpSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
                        [self.scrollView addSubview:tmpSlider];
                        [arrayOfElements addObject:tmpSlider];
                    }
                    else if ([thisMenuItem.itemType isEqualToString:@"stepper"]) {
                        cr_ultimateStepper *tmpStepper = [[cr_ultimateStepper alloc] init];
                        tmpStepper.frame = theFrame;
                        tmpStepper.backgroundColor = [BT_color getColorFromHexString:elementBackgroundColor];
                        
                        int min = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementStepperMinimum" defaultValue:@"0"] intValue];
                        int max = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementStepperMaximum" defaultValue:@"100"] intValue];
                        int def = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementStepperCurrent" defaultValue:@"0"] intValue];
                        int step = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementStepperStep" defaultValue:@"1"] intValue];
                        tmpStepper.minimumValue = min;
                        tmpStepper.maximumValue = max;
                        tmpStepper.tag = elementCounter;
                        tmpStepper.alpha = alphaVal;
                        tmpStepper.value = def;
                        tmpStepper.stepValue = step;
                        [tmpStepper addTarget:self action:@selector(stepperDidChange:) forControlEvents:UIControlEventValueChanged];
                        [self.scrollView addSubview:tmpStepper];
                        [arrayOfElements addObject:tmpStepper];
                    }
                    else if ([thisMenuItem.itemType isEqualToString:@"switch"]) {
                        UISwitch *tmpSwitch = [[UISwitch alloc] init];
                        tmpSwitch.frame = theFrame;
                        BOOL isOn = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementSwitchState" defaultValue:@"0"] boolValue];
                        NSString *elementOnTintColor = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementOnTintColor" defaultValue:@""];
                        NSString *elementThumbTintColor = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementThumbTintColor" defaultValue:@""];
                        if (elementOnTintColor.length>0) tmpSwitch.onTintColor = [BT_color getColorFromHexString:elementOnTintColor];
                        if (elementThumbTintColor.length>0) tmpSwitch.thumbTintColor = [BT_color getColorFromHexString:elementThumbTintColor];
                        [tmpSwitch setOn:isOn];
                        tmpSwitch.tag = elementCounter;
                        tmpSwitch.alpha = alphaVal;
                        [self.scrollView addSubview:tmpSwitch];
                        [arrayOfElements addObject:tmpSwitch];
                    }
                    else if ([thisMenuItem.itemType isEqualToString:@"textView"]) {
                        UITextView *tmpText = [[UITextView alloc] init];
                        tmpText.frame = theFrame;
                        tmpText.textColor = [BT_color getColorFromHexString:elementFontColor];
                        tmpText.backgroundColor = [BT_color getColorFromHexString:elementBackgroundColor];
                        tmpText.tag = elementCounter;
                        tmpText.text = elementText;
                        tmpText.alpha = alphaVal;
                        tmpText.font = [UIFont systemFontOfSize:elementFontSize];
                        BOOL elementTextViewEditable = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTextViewEditable" defaultValue:@"1"] boolValue];
                        BOOL elementTextViewSelectable = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTextViewSelectable" defaultValue:@"1"] boolValue];
                        BOOL elementTextViewDetectLinks = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTextViewDetectLinks" defaultValue:@"1"] boolValue];
                        BOOL elementTextViewDetectAddresses = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTextViewDetectAddresses" defaultValue:@"1"] boolValue];
                        BOOL elementTextViewDetectPhoneNumbers = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTextViewDetectPhoneNumbers" defaultValue:@"1"] boolValue];
                        BOOL elementTextViewDetectEvents = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTextViewDetectEvents" defaultValue:@"1"] boolValue];
                        tmpText.editable = elementTextViewEditable;
                        tmpText.selectable = elementTextViewSelectable;
                        
                        if (elementTextViewDetectLinks) {
                            if (elementTextViewDetectAddresses && elementTextViewDetectEvents && elementTextViewDetectPhoneNumbers) tmpText.dataDetectorTypes = UIDataDetectorTypeAll;
                            else if (elementTextViewDetectAddresses && elementTextViewDetectEvents) tmpText.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypeAddress | UIDataDetectorTypeCalendarEvent;
                            else if (elementTextViewDetectAddresses && elementTextViewDetectPhoneNumbers) tmpText.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypeAddress | UIDataDetectorTypePhoneNumber;
                            else if (elementTextViewDetectAddresses) tmpText.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypeAddress;
                            else if (elementTextViewDetectEvents && elementTextViewDetectPhoneNumbers) tmpText.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypeCalendarEvent | UIDataDetectorTypePhoneNumber;
                            else if (elementTextViewDetectEvents) tmpText.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypeCalendarEvent;
                            else if (elementTextViewDetectPhoneNumbers) tmpText.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
                            else tmpText.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
                        }
                        else if (elementTextViewDetectAddresses) {
                            if (elementTextViewDetectEvents && elementTextViewDetectPhoneNumbers) tmpText.dataDetectorTypes = UIDataDetectorTypeAddress | UIDataDetectorTypeCalendarEvent | UIDataDetectorTypePhoneNumber;
                            else if (elementTextViewDetectEvents) tmpText.dataDetectorTypes = UIDataDetectorTypeAddress | UIDataDetectorTypeCalendarEvent;
                            else if (elementTextViewDetectPhoneNumbers) tmpText.dataDetectorTypes = UIDataDetectorTypeAddress | UIDataDetectorTypePhoneNumber;
                            else tmpText.dataDetectorTypes = UIDataDetectorTypeAddress;
                        }
                        else if (elementTextViewDetectPhoneNumbers) {
                            if (elementTextViewDetectEvents) tmpText.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeCalendarEvent;
                            else tmpText.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
                        }
                        else if (elementTextViewDetectEvents) tmpText.dataDetectorTypes = UIDataDetectorTypeCalendarEvent;
                        else tmpText.dataDetectorTypes = UIDataDetectorTypeNone;
                        
                        [self.scrollView addSubview:tmpText];
                        [arrayOfElements addObject:tmpText];
                        
                    }
                    else if ([thisMenuItem.itemType isEqualToString:@"segment"]) {
                        UISegmentedControl *tmpSegment = [[UISegmentedControl alloc] init];
                        tmpSegment.frame = theFrame;
                        tmpSegment.tag = elementCounter;
                        tmpSegment.alpha = alphaVal;
                        
                        NSString *elementSegment1Title = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementSegment1Title" defaultValue:@""];
                        NSString *elementSegment2Title = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementSegment2Title" defaultValue:@""];
                        NSString *elementSegment3Title = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementSegment3Title" defaultValue:@""];
                        NSString *elementSegment4Title = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementSegment4Title" defaultValue:@""];
                        NSString *elementSegment5Title = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementSegment5Title" defaultValue:@""];
                        int numSegments = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementSegmentNumberSegments" defaultValue:@"1"] intValue];
                        switch (numSegments) {
                            case 5:
                                [tmpSegment insertSegmentWithTitle:elementSegment5Title atIndex:4 animated:NO];
                            case 4:
                                [tmpSegment insertSegmentWithTitle:elementSegment4Title atIndex:3 animated:NO];
                            case 3:
                                [tmpSegment insertSegmentWithTitle:elementSegment3Title atIndex:2 animated:NO];
                            case 2:
                                [tmpSegment insertSegmentWithTitle:elementSegment2Title atIndex:1 animated:NO];
                            case 1:
                                [tmpSegment insertSegmentWithTitle:elementSegment1Title atIndex:0 animated:NO];
                        }
                        NSString *elementSegmentStyle = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementSegmentStyle" defaultValue:@"plain"];
                        if ([elementSegmentStyle isEqualToString:@"plain"]) tmpSegment.segmentedControlStyle = UISegmentedControlStylePlain;
                        else if ([elementSegmentStyle isEqualToString:@"bar"]) tmpSegment.segmentedControlStyle = UISegmentedControlStyleBar;
                        else if ([elementSegmentStyle isEqualToString:@"bezeled"]) tmpSegment.segmentedControlStyle = UISegmentedControlStyleBezeled;
                        else if ([elementSegmentStyle isEqualToString:@"bordered"]) tmpSegment.segmentedControlStyle = UISegmentedControlStyleBordered;
                        
                        tmpSegment.backgroundColor = [BT_color getColorFromHexString:elementBackgroundColor];
                        [self.scrollView addSubview:tmpSegment];
                        [arrayOfElements addObject:tmpSegment];
                        
                        
                    }
                    else if ([thisMenuItem.itemType isEqualToString:@"table"]) {
                        NSString *elementTableStyle = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableListStyle" defaultValue:@"square"];
                        if([elementTableStyle isEqualToString:@"round"]) self.myTableView = [[UITableView alloc] initWithFrame:theFrame style:UITableViewStyleGrouped];
                        else self.myTableView = [[UITableView alloc] initWithFrame:theFrame style:UITableViewStylePlain];
                        
                        myTableView.delegate = self;
                        myTableView.dataSource = self;
                        myTableView.tag = elementCounter;
                        myTableView.alpha = alphaVal;
                        myTableView.backgroundColor = [BT_color getColorFromHexString:elementBackgroundColor];
                        
                        
                        
                        NSString *elementTableSeparatorColor = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableRowSeparatorColor" defaultValue:@""];
                        if (elementTableSeparatorColor.length>0)
                            myTableView.separatorColor = [BT_color getColorFromHexString:elementTableSeparatorColor];
                        BOOL elementTableAllowMultiple = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableMultipleSelection" defaultValue:@"0"] boolValue];
                        if (elementTableAllowMultiple) myTableView.allowsMultipleSelection = true;
                        BOOL elementTablePreventScrolling = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTablePreventScrolling" defaultValue:@"0"] boolValue];
                        if (elementTablePreventScrolling) [self.myTableView setScrollEnabled:FALSE];
                        
                        tableRowBackgroundColor = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableRowBackgroundColor" defaultValue:@"clear"];
                        tableRowAsButtons = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableRowAsButtons" defaultValue:@"1"] boolValue];
                        tableRowFontColor = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableRowFontColor" defaultValue:@"#000000"];
                        tableFontSize = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableFontSize" defaultValue:@"20"] intValue];
                        tableRowHeight = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableRowHeight" defaultValue:@"50"] floatValue];
                        tableRowSelectStyle = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableRowSelectStyle" defaultValue:@"blue"];
                        headerHeight = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableHeaderHeight" defaultValue:@"20"] floatValue];
                        tableListStyle = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableListStyle" defaultValue:@"square"];
                        tableFontSizeLarge = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableFontSizeLarge" defaultValue:@"20"] intValue];
                        tableDescriptionSizeLarge = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableDescriptionSizeLarge" defaultValue:@"15"] intValue];
                        tableDescriptionSize = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableDescriptionSize" defaultValue:@"15"] intValue];
                        listTitleHeightSmallDevice = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableDescriptionSize" defaultValue:@"30"];
                        listTitleHeightLargeDevice = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableDescriptionSizeLarge" defaultValue:@"30"];
                        listRowHeightLargeDevice = [[self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementTableRowHeightLarge" defaultValue:@"50"] floatValue];
                        
                        myTableView.allowsSelection = tableRowAsButtons;
                        
                        [self.scrollView addSubview:myTableView];
                        [arrayOfElements addObject:myTableView];
                    }
                    /*  else if ([thisMenuItem.itemType isEqualToString:@"video"]) {
                     NSString *elementVideoUrl = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementVideoUrl" defaultValue:@""];
                     [BT_debugger showIt:self message:[NSString stringWithFormat:@"video url:%@", elementVideoUrl]];
                     NSURL *theURL = [NSURL URLWithString:elementVideoUrl];
                     theVideoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:theURL];
                     theVideoPlayer.view.frame = theFrame;
                     theVideoPlayer.scalingMode = MPMovieScalingModeAspectFit;
                     theVideoPlayer.controlStyle = MPMovieControlStyleNone;
                     elementBackgroundColor = [self getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementBackgroundColor" defaultValue:@"#000000"];
                     theVideoPlayer.view.backgroundColor = [BT_color getColorFromHexString:elementBackgroundColor];
                     [scrollView addSubview:theVideoPlayer.view];
                     
                     theMovieMask = [[UIView alloc] init];
                     theMovieMask.frame = theFrame;
                     playButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cr_play.png"]];
                     playButton.frame = CGRectMake((theFrame.size.width-50)/2, (theFrame.size.height-50)/2, 50, 50);
                     [theMovieMask addSubview:playButton];
                     [scrollView addSubview:theMovieMask];
                     
                     UITapGestureRecognizer *videoTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTapped)];
                     videoTapped.delegate = self;
                     [theMovieMask addGestureRecognizer:videoTapped];
                     [arrayOfElements addObject:theVideoPlayer];
                     
                     }
                     */
                    
                    [self.menuItems addObject:thisMenuItem];
                    elementCounter++;
                    if ((theFrame.size.height + theFrame.origin.y)>contentHeight) contentHeight = theFrame.size.height + theFrame.origin.y;
                    if ((theFrame.size.width + theFrame.origin.x)>contentWidth) contentWidth = theFrame.size.width + theFrame.origin.x;
                    
                }
                self.scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
                
                
                
            }
            
            
        }
        @catch (NSException *exception) {
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"exception:%@", exception]];
        }
        @finally {
            //load screen data
            [self loadSavedDataToFields];
        }
        
        
        
        
        
		      
    }
    
    if (self.myTableView) [self loadTableData];
    
    
}
#pragma mark Animated Background
//Override Background top utilise animated background
-(void)configureBackground{
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    NSString * smallImageString = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"backgroundImageNameSmallDevice" defaultValue:@""];
    NSString * largeImageString = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"backgroundImageNameLargeDevice" defaultValue:@""];
    
    NSString *imageSize = @"";
    if (appDelegate.rootDevice.isIPad) {
        imageSize = largeImageString;
    }else{
        imageSize = smallImageString;
    }
    
    BOOL isGif = [[imageSize pathExtension]isEqualToString:@"gif"];
    NSString* imageName  = [[imageSize lastPathComponent] stringByDeletingPathExtension];
    
    if (isGif) {
        [self setAnimatedBackgroundWith:imageName];
    }else{
        [super configureBackground];
    }
}

-(void)setAnimatedBackgroundWith:(NSString*)fileName{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"gif"];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:filePath options:0 error:&error];
    FLAnimatedImage *image = [[FLAnimatedImage alloc]initWithAnimatedGIFData:data];
    FLAnimatedImageView  *gifBackground  = [[FLAnimatedImageView alloc]initWithFrame:self.view.bounds];
    gifBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    gifBackground.animatedImage = image;
    [self.view addSubview:gifBackground];
    [self.view insertSubview:gifBackground atIndex:0];
}
/*
 -(void)videoTapped {
 [BT_debugger showIt:self message:@"videoTapped"];
 //get current state
 MPMoviePlaybackState currentState = theVideoPlayer.playbackState;
 if (currentState==MPMoviePlaybackStatePlaying) {
 [theVideoPlayer pause];
 playButton.hidden = false;
 }
 else if (currentState==MPMoviePlaybackStatePaused) {
 [theVideoPlayer play];
 playButton.hidden = true;
 }
 else {
 [theVideoPlayer stop];
 [theVideoPlayer play];
 playButton.hidden = true;
 }
 }
 */
-(NSString*)getJsonPropertyValue:(NSDictionary*)jsonVars nameOfProperty:(NSString*)propertyName defaultValue:(NSString*)defaultValue {
    NSString *ret = @"";
    robocats_appDelegate *appDelegate = (robocats_appDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.rootDevice.isIPad) ret = [BT_strings getJsonPropertyValue:jsonVars nameOfProperty:[NSString stringWithFormat:@"%@Ipad",propertyName] defaultValue:defaultValue];
    else ret = [BT_strings getJsonPropertyValue:jsonVars nameOfProperty:propertyName defaultValue:defaultValue];
    return ret;
}
//[BT_strings getJsonPropertyValue:thisMenuItem.jsonVars nameOfProperty:@"elementHeight" defaultValue:@"0"]

-(void)mapWasTapped:(cr_ultimateTapRecognizer*)sender{
    [BT_debugger showIt:self message:@"mapWasTapped"];
    BT_item *theElement = [self.menuItems objectAtIndex:sender.tag-1000];
    NSString *elementMapLoadScreenOnClick = [self getJsonPropertyValue:theElement.jsonVars nameOfProperty:@"elementMapLoadScreenOnClick" defaultValue:@""];
    if (elementMapLoadScreenOnClick.length>0) {
        robocats_appDelegate *appDelegate = (robocats_appDelegate*)[[UIApplication sharedApplication] delegate];
        BT_item *screenToLoad = [appDelegate.rootApp getScreenDataByNickname:elementMapLoadScreenOnClick];
        NSString *elementTransitionType = [self getJsonPropertyValue:theElement.jsonVars nameOfProperty:@"elementMapTransitionType" defaultValue:@""];
        NSMutableDictionary *newJson = [theElement.jsonVars mutableCopy];
        [newJson setObject:elementTransitionType forKey:@"transitionType"];
        theElement.jsonVars = newJson;
        [self handleTapToLoadScreen:screenToLoad theMenuItemData:theElement];
    }
}

-(void)sliderDidChange:(cr_ultimateSlider*)sender {
    BT_item *theElement = [self.menuItems objectAtIndex:sender.tag-1000];
    NSString *elementSliderAction = [self getJsonPropertyValue:theElement.jsonVars nameOfProperty:@"elementSliderAction" defaultValue:@""];
    if ([elementSliderAction isEqualToString:@"changeLabel"]) {
        int labelNumber = -1;
        if (sender.labelNumber>0) labelNumber = sender.labelNumber;
        else {
            NSString *labelId = [self getJsonPropertyValue:theElement.jsonVars nameOfProperty:@"elementSliderLabel" defaultValue:@""];
            for (int i=0; i<menuItems.count; i++) {
                BT_item *tmpElement = [menuItems objectAtIndex:i];
                if ([labelId isEqualToString:tmpElement.itemId]) {
                    labelNumber = i + 1000;
                    sender.labelNumber = i + 1000;
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"found match for label to change at:%i with itemId:%@", labelNumber, labelId]];
                    break;
                }
                
            }
        }
        UILabel *labelToChange = (UILabel*)[self.scrollView viewWithTag:labelNumber];
        labelToChange.text = [NSString stringWithFormat:@"%0.f", sender.value];
        
        
        
    }
    else if ([elementSliderAction isEqualToString:@"saveToPref"]){
        [BT_debugger showIt:self message:@"saving to pref"];
        NSString *sliderPrefName = [self getJsonPropertyValue:theElement.jsonVars nameOfProperty:@"elementSliderPrefName" defaultValue:@""];
        [BT_strings setPrefString:sliderPrefName valueOfPref:[NSString stringWithFormat:@"%0.f", sender.value]];
    }
    else {
        //no action set if we are here
    }
}

-(void)stepperDidChange:(cr_ultimateStepper*)sender {
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"stepperDidChange:%i",sender.tag]];
    BT_item *theElement = [self.menuItems objectAtIndex:sender.tag-1000];
    NSString *elementStepperAction = [self getJsonPropertyValue:theElement.jsonVars nameOfProperty:@"elementStepperAction" defaultValue:@""];
    if ([elementStepperAction isEqualToString:@"changeLabel"]) {
        int labelNumber = -1;
        if (sender.labelNumber>0) labelNumber = sender.labelNumber;
        else {
            NSString *labelId = [self getJsonPropertyValue:theElement.jsonVars nameOfProperty:@"elementStepperLabel" defaultValue:@""];
            for (int i=0; i<menuItems.count; i++) {
                BT_item *tmpElement = [menuItems objectAtIndex:i];
                if ([labelId isEqualToString:tmpElement.itemId]) {
                    labelNumber = i;
                    sender.labelNumber = i;
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"found match for label to change at:%i with itemId:%@", labelNumber, labelId]];
                    break;
                }
            }
        }
        UILabel *labelToChange = (UILabel*)[self.scrollView viewWithTag:(labelNumber+1000)];
        labelToChange.text = [NSString stringWithFormat:@"%0.f", sender.value];
        
        
        
    }
    else if ([elementStepperAction isEqualToString:@"saveToPref"]){
        [BT_debugger showIt:self message:@"saving to pref"];
        NSString *sliderPrefName = [self getJsonPropertyValue:theElement.jsonVars nameOfProperty:@"elementStepperPrefName" defaultValue:@""];
        [BT_strings setPrefString:sliderPrefName valueOfPref:[NSString stringWithFormat:@"%0.f", sender.value]];
    }
    else {
        //no action set if we are here
    }
}

-(void)buttonClicked:(UIButton*)sender {
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"buttonClicked:%i",sender.tag]];
    buttonPressed = sender;
    
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    BT_item *thisElement = [self.menuItems objectAtIndex:sender.tag-1000];
    NSString *elementButtonAction = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonAction" defaultValue:@""];
    if ([elementButtonAction isEqualToString:@"loadScreen"]) {
        NSString *elementButtonScreenNickname = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonScreenNickname" defaultValue:@""];
        NSString *elementButtonScreenId = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonScreenId" defaultValue:@""];
        BT_item *screenToLoad = NULL;
        if (elementButtonScreenId.length>0) screenToLoad = [appDelegate.rootApp getScreenDataByItemId:elementButtonScreenId];
        else if (elementButtonScreenNickname.length>0) screenToLoad = [appDelegate.rootApp getScreenDataByItemId:elementButtonScreenNickname];
        if (screenToLoad!=NULL) {
            NSString *elementTransitionType = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonTransitionType" defaultValue:@""];
            NSMutableDictionary *newJson = [thisElement.jsonVars mutableCopy];
            [newJson setObject:elementTransitionType forKey:@"transitionType"];
            thisElement.jsonVars = newJson;
            [self handleTapToLoadScreen:screenToLoad theMenuItemData:thisElement];
        }
    }
    else if ([elementButtonAction isEqualToString:@"saveDevice"]) {
        [self saveDataToDevice];
        NSString *elementButtonAlert = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonAlert" defaultValue:@""];
        if (elementButtonAlert.length>0) [self showAlert:@"" theMessage:elementButtonAlert alertTag:0];
    }
    else if ([elementButtonAction isEqualToString:@"sendURL"]) {
        NSString *theURL = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonUrl" defaultValue:@""];
        [self sendDataAndImagesToURL:theURL];
        NSString *elementButtonAlert = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonAlert" defaultValue:@""];
        if (elementButtonAlert.length>0) [self showAlert:@"" theMessage:elementButtonAlert alertTag:0];
    }
    else if ([elementButtonAction isEqualToString:@"sendAndSave"]) {
        [self saveDataToDevice];
        NSString *theURL = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonUrl" defaultValue:@""];
        [self sendDataAndImagesToURL:theURL];
        NSString *elementButtonAlert = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonAlert" defaultValue:@""];
        if (elementButtonAlert.length>0) [self showAlert:@"" theMessage:elementButtonAlert alertTag:0];
    }
    else if ([elementButtonAction isEqualToString:@"postFB"]) {
        [BT_debugger showIt:self message:@"post to Facebook"];
        NSString *elementButtonFBLinkName = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonFBLinkName" defaultValue:@""];
        NSString *elementButtonFBLinkCaption = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonFBLinkCaption" defaultValue:@""];
        NSString *elementButtonFBLinkDescription = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonFBLinkDescription" defaultValue:@""];
        NSString *elementButtonFBLinkUrl = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonFBLinkUrl" defaultValue:@""];
        NSString *elementButtonFBPictureUrl = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonFBPictureUrl" defaultValue:@""];
        
        //class declaration for social functions (Social Login plugin required for these to work.  We use NSClassFromString so the plugin will work if the Social Login plugin is not installed and user just wants buttons to load a screen)
        NSString* myClassString = @"CR_social_login_functions";
        // if the class doesn't exist, myClass will be Nil
        id myClass = NSClassFromString(myClassString);
        id myObj = [[myClass alloc] init];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       elementButtonFBLinkName, @"name",
                                       elementButtonFBLinkCaption, @"caption",
                                       elementButtonFBLinkDescription, @"description",
                                       elementButtonFBLinkUrl, @"link",
                                       elementButtonFBPictureUrl, @"picture",
                                       self, @"currentPlugin",
                                       nil];
        //ignore these yellow warnings - they are necessary
        if ([myObj respondsToSelector:@selector(postLinkToWallWithParams:)])
            [myObj performSelector:@selector(postLinkToWallWithParams:) withObject:params afterDelay:0];
    }
    else if ([elementButtonAction isEqualToString:@"postTW"]) {
        [BT_debugger showIt:self message:@"post to Twitter"];
        NSString *elementButtonTweet = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonTweet" defaultValue:@""];
        //prompt user first
        UIAlertView *tweetConfirm = [[UIAlertView alloc] initWithTitle:@"Post tweet?" message:[NSString stringWithFormat:@"%@", elementButtonTweet] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Share!", nil];
        tweetConfirm.tag = 121;
        [tweetConfirm show];
    }
    else if ([elementButtonAction isEqualToString:@"takePhoto"]) {
        [BT_debugger showIt:self message:@"takePhoto selected"];
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
            [self presentViewController:imagePicker
                               animated:YES completion:nil];
            _newMedia = YES;
        }
        else {
            [self showAlert:@"Sorry" theMessage:@"This is only available on devices with a camera" alertTag:0];
        }
    }
    else if ([elementButtonAction isEqualToString:@"choosePhoto"]) {
        UIImagePickerController *pickerLibrary = [[UIImagePickerController alloc] init];
        pickerLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerLibrary.delegate = self;
        [self presentModalViewController:pickerLibrary animated:YES];
    }
    else if ([elementButtonAction isEqualToString:@"emailData"]) {
        [BT_debugger showIt:self message:@"emailing form data with compose sheet"];
        NSMutableArray *imagesArray = [NSMutableArray new];
        NSMutableDictionary *imagesDictionary = [NSMutableDictionary new];
        NSString *emailBody = @"<body><table style='border-width:1px;border-color:#000000;' border='1'><tr><th>Property</th><th>Value</th></tr>";
        for (int i=0; i<menuItems.count;i++) {
            BT_item *thisElement = [menuItems objectAtIndex:i];
            NSString *elementName = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementName" defaultValue:@""];
            NSString *elementType = [BT_strings getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"itemType" defaultValue:@""];
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"grabbing element with type:%@", elementType]];
            if ([elementType isEqualToString:@"image"]) {
                [BT_debugger showIt:self message:[NSString stringWithFormat:@"image found at tag:%i",(i+1000)]];
                UIImageView *thisImageView = (UIImageView*)[self.scrollView viewWithTag:(i+1000)];
                if (elementName.length>0) [imagesDictionary setObject:thisImageView.image forKey:[NSString stringWithFormat:@"%@.png",elementName]];
                [imagesArray addObject:thisImageView.image];
            }
            else {
                NSString *elementValue = [self getFormFieldValue:(i+1000) forType:thisElement.itemType];
                if (elementName.length>0)
                    emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<tr><td>%@</td><td>%@</td></tr>",elementName,elementValue]];
            }
            
        }
        //get subject and to address
        NSString *toAddress = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonToAddress" defaultValue:@""];
        NSString *subject = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonSubjectLine" defaultValue:@""];
        
        //send off email
        [self sendEmailToAddress:toAddress withSubject:subject withBody:emailBody withArrayOfImages:imagesDictionary];
    }
    
}

//sendEmailWithAttachmentFromScreenData...
-(void)sendEmailToAddress:(NSString*)toAddress withSubject:(NSString*)subject withBody:(NSString*)body withArrayOfImages:(NSDictionary*)dictionaryOfImages {
    [BT_debugger showIt:self message:@"sendEmailToAddress..."];
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
            [picker setSubject:subject];
            
            //set possible to address
            NSArray *toRecipients = [NSArray arrayWithObject:toAddress];
            [picker setToRecipients:toRecipients];
            
            [picker setMessageBody:body isHTML:YES];
            
            NSArray *imageNames = [dictionaryOfImages allKeys];
            for (int i=0; i<imageNames.count; i++) {
                NSString *imageName = [imageNames objectAtIndex:i];
                UIImage *theImage = [dictionaryOfImages objectForKey:imageName];
                //                UIImage *theImage = (UIImage*)[arrayOfImages objectAtIndex:i];
                NSData *imgData = UIImageJPEGRepresentation(theImage, 1);
                [picker addAttachmentData:imgData mimeType:@"application/octet-stream" fileName:imageName];
            }
            
            //navigation bar color depends on iOS7 or lower...
            if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
                [[picker navigationBar] setTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:self.screenData]];
            }else{
                [[picker navigationBar] setBarTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:self.screenData]];
            }
            
            //show the model view...
            [theViewController presentViewController:picker animated:YES completion:nil];
            
            
        }//can send mail
    }
}

-(int)getElementNumberForItemId:(NSString*)itemId{
    int elementNumber = -1;
    for (int i=0; i<menuItems.count; i++) {
        BT_item *tmpElement = [menuItems objectAtIndex:i];
        if ([itemId isEqualToString:tmpElement.itemId]) {
            elementNumber = i;
            break;
        }
    }
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"getElementNumberForItemId:%@ = %i", itemId, elementNumber]];
    return elementNumber;
}

-(int)getElementNumberForElementName:(NSString*)elementName{
    int elementNumber = -1;
    for (int i=0; i<menuItems.count; i++) {
        BT_item *tmpElement = [menuItems objectAtIndex:i];
        NSString *tmpElementName = [self getJsonPropertyValue:tmpElement.jsonVars nameOfProperty:@"elementName" defaultValue:@""];
        if ([elementName isEqualToString:tmpElementName]) {
            elementNumber = i;
            break;
        }
    }
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"getElementNumberForElementName:%@ = %i", elementName, elementNumber]];
    return elementNumber;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag==121 && buttonIndex==1) {
        NSString* myClassString = @"CR_social_login_functions";
        // if the class doesn't exist, myClass will be Nil
        id myClass = NSClassFromString(myClassString);
        id myObj = [[myClass alloc] init];
        
        NSString *tweet = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"tweetMessage" defaultValue:@"Sent from my app!"];
        
        //ignore these yellow warnings - they are necessary
        if ([myObj respondsToSelector:@selector(postTweet:)])
            [myObj performSelector:@selector(postTweet:) withObject:tweet afterDelay:0];
    }
}

-(NSString*) postEncodedString:(NSString *)encodedString toURL:(NSString *)theURL{
    
    NSURL *phpScriptURL = [NSURL URLWithString:theURL];
    
    NSData *postData = [encodedString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:phpScriptURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    
    return data;
}

- (void) uploadImage: (UIImage *)theImage withFileName:(NSString *)fileName withStringDictionary:(NSDictionary *)theDictionary toURL:(NSString *)theURL  {
    
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"uploading image and caption to:%@", theURL]];
    
    
    
    NSMutableData *body = [NSMutableData data];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSData *imgData = UIImageJPEGRepresentation(theImage, 1);
    //NSData *imgData = UIImagePNGRepresentation(imageBox.image);
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"image size:%i", imgData.length]];
    NSURL *url = [NSURL URLWithString:theURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // file
    [BT_debugger showIt:self theMessage:@"uploading file:"];
    [BT_debugger showIt:self theMessage:fileName];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"File\"; filename=\"%@\" \r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imgData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    //string data
    NSArray *theKeys = [theDictionary allKeys];
    for (int i=0; i<theDictionary.count; i++) {
        NSString *keyName = [theKeys objectAtIndex:i];
        NSString *keyValue = [theDictionary objectForKey:keyName];
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",keyName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[keyValue dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    
    [BT_debugger showIt:self theMessage:data];
    if ([data length]>0) {
        if ([data isEqualToString:@"success"])
            [self showAlert:@"Thank you" theMessage:@"Image successfully uploaded" alertTag:0];
        else [self showAlert:@"Error" theMessage:@"Image not uploaded" alertTag:0];
    }
    else {
        [self showAlert:@"Error" theMessage:@"Something went wrong - please try again later" alertTag:0];
    }
    
    
}

-(void)sendDataAndImagesToURL:(NSString*)theURL {
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"sendDataAndImagesToURL:%@",theURL]];
    [self showProgress];
    NSMutableData *body = [NSMutableData data];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSURL *url = [NSURL URLWithString:theURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    for (int i=0; i<menuItems.count;i++) {
        BT_item *thisElement = [menuItems objectAtIndex:i];
        NSString *elementName = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementName" defaultValue:@""];
        if (elementName.length>0) {
            NSString *elementType = [BT_strings getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"itemType" defaultValue:@""];
            
            if ([elementType isEqualToString:@"image"]) {
                UIImageView *imageView = (UIImageView*)[self.arrayOfElements objectAtIndex:i];
                NSData *imgData = UIImageJPEGRepresentation(imageView.image, 1);
                [BT_debugger showIt:self message:[NSString stringWithFormat:@"image found:%i bytes",imgData.length]];
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"File[]\"; filename=\"%@\" \r\n", elementName] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[NSData dataWithData:imgData]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
        }
    }
    
    for (int i=0; i<menuItems.count; i++) {
        BT_item *thisElement = [menuItems objectAtIndex:i];
        NSString *elementName = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementName" defaultValue:@""];
        if (elementName.length>0) {
            NSString *elementType = [BT_strings getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"itemType" defaultValue:@""];
            
            if ([elementType isEqualToString:@"image"]) {
                
            }
            else {
                NSString *elementValue = [self getFormFieldValue:(i+1000) forType:thisElement.itemType];
                
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",elementName] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[elementValue dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
        }
        
    }
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    
    [self hideProgress];
    [BT_debugger showIt:self message:@"data:"];
    [BT_debugger showIt:self theMessage:data];
    
}

-(void)sendDataToURL:(NSString*)theURL {
    [BT_debugger showIt:self message:@"sendDataToURL"];
    NSString *encodedData = @"";
    int variableCount = 0;
    for (int i=0; i<menuItems.count; i++) {
        BT_item *thisElement = [menuItems objectAtIndex:i];
        NSString *elementName = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementName" defaultValue:@""];
        if (elementName.length>0) {
            NSString *elementValue = [self getFormFieldValue:i forType:thisElement.itemType];
            NSString *concateString = @"&";
            if (variableCount==0) {
                concateString = @"";
            }
            encodedData = [encodedData stringByAppendingString:[NSString stringWithFormat:@"%@%@=%@",concateString,elementName, elementValue]];
            variableCount++;
        }
    }
    [self postEncodedString:encodedData toURL:theURL];
}

-(void)saveDataToDevice {
    [BT_debugger showIt:self message:@"saveDataToDevice"];
    //loop through all form elements, saving data to device with preference name equal to element "name"
    //elements eligible to be saved include:
    //textField, textView, segmentedControl, slider, switch, stepper, textView, label
    //note: label is eligible because other elements might change its value
    
    for (int i=0; i<menuItems.count; i++) {
        BT_item *thisElement = [menuItems objectAtIndex:i];
        NSString *elementName = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementName" defaultValue:@""];
        if (elementName.length>0) {
            if ([thisElement.itemType isEqualToString:@"image"]) {
                NSString *imageName = [NSString stringWithFormat:@"%@.png",elementName];
                UIImageView *theImageView = (UIImageView*)[self.scrollView viewWithTag:(i+1000)];
                [BT_fileManager saveImageToFile:theImageView.image fileName:imageName];
                [BT_strings setPrefString:elementName valueOfPref:imageName];
            }
            else {
                NSString *elementValue = [self getFormFieldValue:(i+1000) forType:thisElement.itemType];
                [BT_strings setPrefString:elementName valueOfPref:elementValue];
            }
            
        }
    }
    [self showAlert:@"Saved" theMessage:@"Data saved to device" alertTag:0];
}

-(NSString*)getFormFieldValue:(int)i forType:(NSString*)itemType {
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"getFormFieldValue:%i forType:%@",i,itemType]];
    NSString *ret = @"";
    if ([itemType isEqualToString:@"label"]) {
        UILabel *theLabel = (UILabel*)[self.scrollView viewWithTag:i];
        ret = theLabel.text;
    }
    else if ([itemType isEqualToString:@"textField"]) {
        UITextField *theField = (UITextField*)[self.scrollView viewWithTag:i];
        ret = theField.text;
    }
    else if ([itemType isEqualToString:@"textView"]) {
        UITextView *theField = (UITextView*)[self.scrollView viewWithTag:i];
        ret = theField.text;
    }
    else if ([itemType isEqualToString:@"segment"]) {
        UISegmentedControl *theSegment = (UISegmentedControl*)[self.scrollView viewWithTag:i];
        ret = [NSString stringWithFormat:@"%i", theSegment.selectedSegmentIndex];
    }
    else if ([itemType isEqualToString:@"slider"]) {
        UISlider *theSlider = (UISlider*)[self.scrollView viewWithTag:i];
        ret = [NSString stringWithFormat:@"%f", theSlider.value];
    }
    else if ([itemType isEqualToString:@"switch"]) {
        UISwitch *theSwitch = (UISwitch*)[self.scrollView viewWithTag:i];
        ret = [NSString stringWithFormat:@"%hhd", theSwitch.isOn];
    }
    else if ([itemType isEqualToString:@"stepper"]) {
        UIStepper *theStepper = (UIStepper*)[self.scrollView viewWithTag:i];
        ret = [NSString stringWithFormat:@"%f", theStepper.value];
    }
    return ret;
}

//webview delegate method
- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
    [BT_debugger showIt:self message:@"webViewDidFinishLoad"];
    CGSize contentSize = theWebView.scrollView.contentSize;
    CGSize viewSize = self.view.bounds.size;
    
    float rw = viewSize.width / contentSize.width;
    
    theWebView.scrollView.minimumZoomScale = rw;
    theWebView.scrollView.maximumZoomScale = rw;
    theWebView.scrollView.zoomScale = rw;
}

-(void)loadSavedDataToFields {
    [BT_debugger showIt:self message:@"loadSavedDataToFields"];
    //json_screenLoadDataIpad
    robocats_appDelegate*appDelegate = (robocats_appDelegate*)[[UIApplication sharedApplication] delegate];
    BOOL shouldLoadData = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"screenLoadData" defaultValue:@"0"] boolValue];
    if (appDelegate.rootDevice.isIPad) shouldLoadData = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"screenLoadDataIpad" defaultValue:@"0"] boolValue];
    if (shouldLoadData) {
        [BT_debugger showIt:self message:@"loading data..."];
        for (int i=0; i<menuItems.count; i++) {
            BT_item *thisElement = [menuItems objectAtIndex:i];
            NSString *elementName = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementName" defaultValue:@""];
            NSString *elementType = [BT_strings getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"itemType" defaultValue:@""];
            if (elementName.length>0) [self updateValueForElement:(i+1000) ofType:elementType withValue:[BT_strings getPrefString:elementName]];
        }
    }
    
}

-(void)updateValueForElement:(int)elementTag ofType:(NSString*)itemType withValue:(NSString*)value {
    if ([itemType isEqualToString:@"label"]){
        UILabel *theLabel = (UILabel*)[self.scrollView viewWithTag:elementTag];
        theLabel.text = value;
    }
    else if ([itemType isEqualToString:@"textField"]) {
        UITextField *theField = (UITextField*)[self.scrollView viewWithTag:elementTag];
        theField.text = value;
    }
    else if ([itemType isEqualToString:@"textView"]) {
        UITextView *theField = (UITextView*)[self.scrollView viewWithTag:elementTag];
        theField.text = value;
    }
    else if ([itemType isEqualToString:@"segment"]) {
        UISegmentedControl *theSegment = (UISegmentedControl*)[self.scrollView viewWithTag:elementTag];
        theSegment.selectedSegmentIndex = [value intValue];
    }
    else if ([itemType isEqualToString:@"stepper"]) {
        UIStepper *theStepper = (UIStepper*)[self.scrollView viewWithTag:elementTag];
        theStepper.value = [value floatValue];
    }
    else if ([itemType isEqualToString:@"slider"]) {
        UISlider *theSlider = (UISlider*)[self.scrollView viewWithTag:elementTag];
        theSlider.value = [value floatValue];
    }
    else if ([itemType isEqualToString:@"switch"]) {
        UISwitch *theSwitch = (UISwitch*)[self.scrollView viewWithTag:elementTag];
        [theSwitch setOn:[value boolValue] animated:NO];
    }
    else if ([itemType isEqualToString:@"image"]) {
        UIImageView *theImage = (UIImageView*)[self.scrollView viewWithTag:elementTag];
        UIImage *image = [BT_fileManager getImageFromFile:value];
        if (image!=NULL) theImage.image= image;
        else [BT_debugger showIt:self message:[NSString stringWithFormat:@"no image found with name:%@",value]];
    }
    
}


/////////////////////////////////////////////////////////////
//Image Picker Delegate Methods
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"imagePickerController didFinishPickingMediaWithInfo:%@",info]];
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        //figure out which image to change
        BT_item *thisElement = [self.menuItems objectAtIndex:buttonPressed.tag-1000];
        NSString *elementButtonImageToChange = [self getJsonPropertyValue:thisElement.jsonVars nameOfProperty:@"elementButtonImageToChange" defaultValue:@""];
        int imageViewNumber = [self getElementNumberForItemId:elementButtonImageToChange];
        UIImageView *imageView = (UIImageView*)[self.arrayOfElements objectAtIndex:imageViewNumber];
        
        imageView.image = image;
        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}



/////////////////////////////////////////////////////////////
//TableView Methods
-(void)loadTableData {
    [BT_debugger showIt:self theMessage:@"loadTableData"];
    self.isLoading = TRUE;
    
    //prevent interaction during operation
    [myTableView setScrollEnabled:FALSE];
    [myTableView setAllowsSelection:FALSE];
    
    /*
     Screen Data scenarios
     --------------------------------
     a)	No dataURL is provided in the screen data - use the info configured in the app's configuration file
     b)	A dataURL is provided, download now if we don't have a cache, else, download on refresh.
     */
    
    self.saveAsFileName = [NSString stringWithFormat:@"screenData_%@.txt", [self.screenData itemId]];
    
    //do we have a URL?
    BOOL haveURL = FALSE;
    if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@""] length] > 10){
        haveURL = TRUE;
    }
    
    //start by filling the list from the configuration file, use these if we can't get anything from a URL
    if([[self.screenData jsonVars] objectForKey:@"childItems"]){
        [BT_debugger showIt:self message:@"childItems Array found"];
        //init the items array
        self.tableItems = [[NSMutableArray alloc] init];
        
        NSArray *tmpMenuItems = [[self.screenData jsonVars] objectForKey:@"childItems"];
        for(NSDictionary *tmpMenuItem in tmpMenuItems){
            BT_item *thisMenuItem = [[BT_item alloc] init];
            thisMenuItem.itemId = [tmpMenuItem objectForKey:@"itemId"];
            thisMenuItem.itemType = [tmpMenuItem objectForKey:@"itemType"];
            thisMenuItem.jsonVars = tmpMenuItem;
            [self.tableItems addObject:thisMenuItem];
        }
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"found %i childItems", self.menuItems.count]];
        
    }
    
    //if we have a URL, fetch..
    if(haveURL){
        
        //look for a previously cached version of this screens data...
        if([BT_fileManager doesLocalFileExist:[self saveAsFileName]]){
            [BT_debugger showIt:self theMessage:@"parsing cached version of screen data"];
            NSString *staleData = [BT_fileManager readTextFileFromCacheWithEncoding:[self saveAsFileName] encodingFlag:-1];
            [self parseScreenData:staleData];
        }else{
            [BT_debugger showIt:self theMessage:@"no cached version of this screens data available."];
            [self downloadData];
        }
        
        
    }else{
        
        //show the child items in the config data
        [BT_debugger showIt:self theMessage:@"using menu items from the screens configuration data."];
        [self layoutScreen];
        
    }
}

//download data
-(void)downloadData{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"downloading screen data from: %@", [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@""]]];
    
    //flag this as the current screen
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.rootApp.currentScreenData = self.screenData;
    
    //prevent interaction during operation
    [myTableView setScrollEnabled:FALSE];
    [myTableView setAllowsSelection:FALSE];
    
    //show progress
    [self showProgress];
    
    NSString *tmpURL = @"";
    if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@""] length] > 3){
        
        //merge url variables
        tmpURL = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@""];
        
        ///merge possible variables in URL
        NSString *useURL = [BT_strings mergeBTVariablesInString:tmpURL];
        NSString *escapedUrl = [useURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //fire downloader to fetch and results
        downloader = [[BT_downloader alloc] init];
        [downloader setSaveAsFileName:[self saveAsFileName]];
        [downloader setSaveAsFileType:@"text"];
        [downloader setUrlString:escapedUrl];
        [downloader setDelegate:self];
        [downloader downloadFile];
    }
}

//parse screen data
-(void)parseScreenData:(NSString *)theData{
    [BT_debugger showIt:self theMessage:@"parseScreenData"];
    
    //prevent interaction during operation
    [myTableView setScrollEnabled:FALSE];
    [myTableView setAllowsSelection:FALSE];
    
    @try {
        
        //arrays for screenData
        self.tableItems = [[NSMutableArray alloc] init];
        
        //create dictionary from the JSON string
        SBJsonParser *parser = [SBJsonParser new];
        id jsonData = [parser objectWithString:theData];
        
        
        if(!jsonData){
            
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"ERROR parsing JSON: %@", parser.errorTrace]];
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
                    [self.tableItems addObject:thisMenuItem];
                }
            }
            
            //layout screen
            [self layoutScreen];
            
        }
        
    }@catch (NSException * e) {
        
        //delete bogus data, show alert
        [BT_fileManager deleteFile:[self saveAsFileName]];
        [self showAlert:NSLocalizedString(@"errorTitle",@"~ Error ~") theMessage:NSLocalizedString(@"appParseError", @"There was a problem parsing some configuration data. Please make sure that it is well-formed") alertTag:0];
        [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"error parsing screen data: %@", e]];
        
    }
    
}

//build screen
-(void)layoutScreen{
    [BT_debugger showIt:self theMessage:@"layoutScreen"];
    
    //if we did not have any menu items...
    if(self.tableItems.count < 1){
        
        for(int i = 0; i < 5; i++){
            
            //create a menu item from the data
            BT_item *thisMenuItemData = [[BT_item alloc] init];
            [thisMenuItemData setJsonVars:nil];
            [thisMenuItemData setItemId:@""];
            [thisMenuItemData setItemType:@"BT_menuItem"];
            [self.tableItems addObject:thisMenuItemData];
            
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

//get image
-(UIImage*)getImage:(NSString *)imageLocation {
    UIImage *tmpImage = [[UIImage alloc]init];
    
    //check if this is from a URL or not
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

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

//////////////////////////////////////////////////////////////
//UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableItems count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return headerHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableRowHeight;
}

//table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell_%i", indexPath.row];
    cr_ultimateTableViewCell *cell = (cr_ultimateTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        
        //init our custom cell
        cell = [[cr_ultimateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    //this menu item
    BT_item *thisMenuItemData = [self.tableItems objectAtIndex:indexPath.row];
    [cell setTheMenuItemData:thisMenuItemData];
    [cell setTheParentMenuScreenData:[self screenData]];
    
    //tableRowSelectStyle, tableFontSize, tableRowFontColor, tableListStyle,tableDescriptionSize,tableDescriptionSizeLarge,tableFontSizeLarge,listRowHeightSmallDevice,listTitleHeightSmallDevice,listRowHeightLargeDevice,listTitleHeightLargeDevice;
    cell.tableRowSelectStyle = tableRowSelectStyle;
    cell.tableFontSize = tableFontSize;
    cell.tableRowFontColor = tableRowFontColor;
    cell.tableListStyle = tableListStyle;
    cell.tableDescriptionSize = tableDescriptionSize;
    cell.listRowHeightSmallDevice = tableRowHeight;
    cell.listTitleHeightSmallDevice = listTitleHeightSmallDevice;
    cell.listRowHeightLargeDevice = listRowHeightLargeDevice;
    cell.listTitleHeightLargeDevice = listTitleHeightLargeDevice;
    cell.tableDescriptionSizeLarge = tableDescriptionSizeLarge;
    cell.tableFontSizeLarge = tableFontSizeLarge;
    
    [cell configureCell];
    
    
    //custom background view. Must be done here so we can retain the "round" corners if this is a round table
    //this method refers to this screen's "listRowBackgroundColor" and it's position in the tap. Top and
    //bottom rows may need to be rounded if this is screen uses "listStyle":"round"
    [cell setBackgroundView:[BT_viewUtilities getCellBackgroundForListRow:[self screenData] theIndexPath:indexPath numRows:[self.tableItems count]]];
    
    cell.backgroundColor = [BT_color getColorFromHexString:tableRowBackgroundColor];
    
    //return
    return cell;
    
}

//on row select
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableRowAsButtons) return;
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didSelectRowAtIndexPath: Selected Row: %i", indexPath.row]];
    
    //pass this menu item to the tapForMenuItem method
    BT_item *thisMenuItem = [self.tableItems objectAtIndex:indexPath.row];
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
            [self handleTapToLoadScreen:screenObjectToLoad theMenuItemData:thisMenuItem];
        }else{
            //show message
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@",NSLocalizedString(@"menuTapError",@"The application doesn't know how to handle this click?")]];
        }
        
    }else{
        
        //show message
        [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@",NSLocalizedString(@"menuTapError",@"The application doesn't know how to handle this action?")]];
        
    }
    
}

//on accessory view tap (details arrow tap)
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if (!tableRowAsButtons) return;
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"accessoryButtonTappedForRowWithIndexPath: Selected Row: %i", indexPath.row]];
    
    //pass this menu item to the tapForMenuItem method
    BT_item *thisMenuItem = [self.tableItems objectAtIndex:indexPath.row];
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
            [self handleTapToLoadScreen:screenObjectToLoad theMenuItemData:thisMenuItem];
        }else{
            //show error alert
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@",NSLocalizedString(@"menuTapError",@"The application doesn't know how to handle this action?")]];
        }
        
    }else{
        //show error alert
        [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@",NSLocalizedString(@"menuTapError",@"The application doesn't know how to handle this action?")]];
    }
    
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
        //NSLog(@"Message: %@", message);
        
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
            if(self.tableItems.count > 0){
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


////////////////////////////////////////////////////////////////////
//METHODS FOR HANDLING TEXTVIEWS HIDDEN BY KEYBOARD
////////////////////////////////////////////////////////////////////

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    activeField = textField;
    return YES;
}

//this method is to be used to prevent taps on certain elements from being
//registered as a background tap.
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isMemberOfClass:[UIView class]]) {
        return YES;
    }
    else if ([touch.view isMemberOfClass:[UIScrollView class]]) {
        return YES;
    }
    else return NO;
}

- (void) backgroundTapped {
    [BT_debugger showIt:self theMessage:@"background tapped"];
    [activeField resignFirstResponder];
}

-(void)keyboardWillShow:(NSNotification *)nsNotification{
    
    //first, get height of keyboard
    NSDictionary *userInfo = [nsNotification userInfo];
    CGRect kbRect = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    //get height of screen
    CGFloat deviceHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGPoint textViewTop = [activeField convertPoint:activeField.bounds.origin toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    CGFloat textViewHeight = activeField.frame.size.height;
    
    CGFloat distanceFromTextViewToBottomOfScreen = deviceHeight-textViewTop.y-textViewHeight;
    
    
    //next, see if our textfield is hidden by keyboard
    if (distanceFromTextViewToBottomOfScreen < kbRect.size.height) {
        
        scrollOffset = -kbRect.size.height + distanceFromTextViewToBottomOfScreen;
        [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"new scrollOffset:%f", scrollOffset]];
        const float movementDuration = 0.3f; // tweak as needed
        
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        scrollView.frame = CGRectOffset(scrollView.frame, 0, scrollOffset);
        [UIView commitAnimations];
        
    }
}

-(void)keyboardWillHide{
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    scrollView.frame = CGRectOffset(scrollView.frame, 0, -scrollOffset);
    [UIView commitAnimations];
}

////////////////////////////////////////////////////////////////////
//END METHODS FOR HANDLING TEXTVIEWS HIDDEN BY KEYBOARD
////////////////////////////////////////////////////////////////////

@end
