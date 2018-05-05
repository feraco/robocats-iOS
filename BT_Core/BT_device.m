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

#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import "robocats_appDelegate.h"
#import "BT_reachability.h"
#import "BT_device.h"

@implementation BT_device
@synthesize deviceId, deviceModel, deviceVersion, deviceWidth, deviceHeight;
@synthesize deviceLatitude, deviceLongitude, deviceConnectionType;	
@synthesize isIPad, isOnline, canReportLocation, canTakePictures, canTakeVideos;
@synthesize canMakePhoneCalls, canSendEmails, canSendSMS;

-(id)init{
    if((self = [super init])){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"INIT"]];
		
		//current device instance
		UIDevice* device = [UIDevice currentDevice];
        
        //create a unique-id if we have not saved one yet.
        NSString *tmpUUID = [BT_strings getPrefString:@"BT_UUID"];
        if([tmpUUID length] > 5){
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"Unique UUID exists: %@", tmpUUID]];
            [self setDeviceId:tmpUUID];
        }else{
            CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
            NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"Unique UUID does not exist, creating: %@", uuidStr]];
            [BT_strings setPrefString:@"BT_UUID" valueOfPref:uuidStr];
            [self setDeviceId:uuidStr];
        }
        
		[self setDeviceModel:[device model]];
		[self setDeviceWidth:[UIScreen mainScreen].bounds.size.width];
		[self setDeviceHeight:[UIScreen mainScreen].bounds.size.height];
		[self setDeviceLatitude:@"0"];
		[self setDeviceLongitude:@"0"];
		[self setDeviceConnectionType:@""];
		[self setIsOnline:FALSE];
		[self setCanTakePictures:FALSE];
		[self setCanTakeVideos:FALSE];
		[self setCanMakePhoneCalls:FALSE];
		[self setCanSendEmails:FALSE];
		[self setCanSendSMS:FALSE];
		[self setCanReportLocation:FALSE];
		
		//if this is an iPad, flag it...
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device is an iPad."]];
			[self setIsIPad:TRUE];
		}else{
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device is NOT an iPad."]];
			[self setIsIPad:FALSE];
		}
		
		//can this device make phone calls?
		NSRange modelRange = [[device model] rangeOfString:@"iPhone"];
		if(modelRange.location == NSNotFound){
			[self setCanMakePhoneCalls:FALSE];
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device cannot make phone calls"]];
		}else{
			[self setCanMakePhoneCalls:TRUE];
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device can make phone calls"]];
		}
		
		//can send emails? Just because device is capable doesn't mean mail's been configured.
		Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
		if(mailClass != nil){
			if([mailClass canSendMail]){
				[self setCanSendEmails:TRUE];
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device can send emails"]];
			}
		}
		if(![self canSendEmails]){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device cannot send emails"]];
		}

		//can send SMS? Just because device is capable doesn't mean it can send.
		Class SMSClass = (NSClassFromString(@"MFMessageComposeViewController"));
		if(SMSClass != nil){
			if([SMSClass canSendText]){
				[self setCanSendSMS:TRUE];
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device can send SMS (text) messages"]];
			}
		}
		if(![self canSendSMS]){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device cannot send SMS (text) messages"]];
		}

				
		/*
			can this device report it's location? If user has turned off services for this app only, this
			method will return true. In this case, we need to use the locationManager.didFailWithError
			method in the delgate class where we are monitoring the location.
		*/
        SEL selector = NSSelectorFromString(@"locationServicesEnabled");
		if([CLLocationManager respondsToSelector:selector]) {
      		[self setCanReportLocation:[CLLocationManager locationServicesEnabled]];
		}
		if(self.canReportLocation){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device can report it's location"]];
		}else{
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device cannot report it's location"]];
		}
		
		//camera and or video support?
		if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
			NSArray *media = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
			if([media containsObject:(id)kUTTypeImage]){
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device can take still pictures"]];
				[self setCanTakePictures:TRUE];
			}else{
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device cannot take still pictures"]];
			}
			
			if([media containsObject:(id)kUTTypeMovie]){
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device can take videos"]];
				[self setCanTakeVideos:TRUE];
			}else{
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device cannot take videos"]];
			}
		}else{
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"This device cannot take pictures or videos"]];
		}
        
        //show all the custom font's available in the project...
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"Listing custom fonts (UIAppFonts) listed in app's .plist...%@", @""]];
        NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
        NSArray* fontFiles = [infoDict objectForKey:@"UIAppFonts"];
        for (NSString *fontFile in fontFiles) {
            NSURL *url = [[NSBundle mainBundle] URLForResource:fontFile withExtension:NULL];
            NSData *fontData = [NSData dataWithContentsOfURL:url];
            CGDataProviderRef fontDataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)fontData);
            CGFontRef loadedFont = CGFontCreateWithDataProvider(fontDataProvider);
            NSString *fullName = CFBridgingRelease(CGFontCopyFullName(loadedFont));
            CGFontRelease(loadedFont);
            CGDataProviderRelease(fontDataProvider);
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"----Font: %@", fullName]];
        }
        
        
	}
	return self;
}

//register for push notifications...
+(void)registerForPushNotifications:(NSString *)registerURL{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"registerForPushNotifications: %@", registerURL]];
    
    //process the URL request...
    NSError* error;
    NSURL *useURL = [NSURL URLWithString:registerURL];
    NSString *response = [NSString stringWithContentsOfURL:useURL encoding:NSASCIIStringEncoding error:&error];
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"registerForPushNotifications: Response: %@", response]];
    
}

//unRegister for push notifications...
+(void)unRegisterForPushNotifications:(NSString *)registerURL{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"unRegisterForPushNotifications: %@", registerURL]];
    
    //process the URL request...
    NSError* error;
    NSURL *useURL = [NSURL URLWithString:registerURL];
    NSString *response = [NSString stringWithContentsOfURL:useURL encoding:NSASCIIStringEncoding error:&error];
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"unRegisterForPushNotifications: Response: %@", response]];
    
}






@end







