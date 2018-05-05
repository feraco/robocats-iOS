/*
 *	Copyright 2014, Andy Kitts
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


#import "AK_consumableIAP.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "BT_imageTools.h"

@implementation AK_consumableIAP

//viewDidLoad
-(void)viewDidLoad{
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];
    [self layoutScreen];
}

-(void)layoutScreen{
    
    // Image setup
    imageBox.image = [self getImage:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"imageName" defaultValue:@""]];
    
    //Text box Setup
    [textBox setText:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"textBox" defaultValue:@""]];
    [textBox setBackgroundColor:[BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"textBoxBackgroundColor" defaultValue:@"clear"]]];
    [textBox setTextColor:[BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"textBoxTextColor" defaultValue:@"#000000"]]];
    
    float fontSize = 10;
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.rootDevice.isIPad) {
        fontSize = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"textBoxTextSizeLarge" defaultValue:@"30"]floatValue];
    }else{
        fontSize = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"textBoxTextSize" defaultValue:@"15"]floatValue];
    }

    [textBox setFont:[UIFont systemFontOfSize:fontSize]];
    
    //Purchase Button Setup
    [purchaseButton setTitle:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"purchaseButtonText" defaultValue:@"BUY NOW"] forState:UIControlStateNormal];
    purchaseButton.enabled = NO;
    [purchaseButton setBackgroundColor:[BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"purchaseButtonBackgroundColor" defaultValue:@"#FF00FF"]]];
    [purchaseButton setTitleColor:[BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"purchaseButtonTextColor" defaultValue:@"#000000"]]forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestProducts];
}

-(void)requestProducts{
    IAPID = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"iapID" defaultValue:@""];
    NSSet *products = [NSSet setWithArray:@[IAPID]];
    [[RMStore defaultStore]requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        NSLog(@"VALID %@", products);
        NSLog(@"INVALID %@", invalidProductIdentifiers);
        
        if (products.count > 0) {
            purchaseButton.enabled = YES;
        }
        
    } failure:^(NSError *error) {
        NSLog(@"NOTHING HERE");
    }];
}

-(IBAction)pressed:(id)sender{
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    purchaseButton.enabled = NO;
    [[RMStore defaultStore] addPayment:IAPID success:^(SKPaymentTransaction *transaction) {
        NSLog(@"Purchased!");
        NSString *consumableScreenNickname = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"unLockScreenNickname" defaultValue:@""];
        BT_item * consumableScreen = [appDelegate.rootApp getScreenDataByNickname:consumableScreenNickname];
        //build a temp menu-item to pass to screen load method. We need this because the transition type is in the menu-item
        BT_item *tmpMenuItem = [[BT_item alloc] init];
        
        //build an NSDictionary of values for the jsonVars property
        // SETS the transitionType
        NSDictionary *tmpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"unused",
                                       @"itemId",
                                       @"fade",
                                       @"transitionType",
                                       nil];
        [tmpMenuItem setJsonVars:tmpDictionary];
        [tmpMenuItem setItemId:@"0"];
        [self handleTapToLoadScreen:consumableScreen theMenuItemData:tmpMenuItem];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        NSLog(@"Something went wrong");
        purchaseButton.enabled = YES;
    }];
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

-(UIImage*)getImage:(NSString *)imageLocation {
    UIImage *tmpImage = [[UIImage alloc]init];
    
    //check if this is from a URL or not
    NSString *firstFour = [imageLocation substringToIndex:4];
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
        if ([BT_fileManager doesFileExistInBundle:imageLocation])
            tmpImage = [UIImage imageNamed:imageLocation];
    }
    
    return tmpImage;
}

@end







