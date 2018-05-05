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


#import "BT_strings.h"

@implementation BT_strings

//gets preference
+(NSString *)getPrefString:(NSString *)nameOfPref{
	//returns emtpy string or string value of saved preference
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *ret = @"";
	if([prefs stringForKey:nameOfPref] != nil){
		ret = [prefs stringForKey:nameOfPref];
	}
	return ret;
}
//sets preference
+(void)setPrefString:(NSString *)nameOfPref valueOfPref:(NSString *)valueOfPref{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:valueOfPref forKey:nameOfPref];
    [prefs synchronize];
}

//replace string in string method
+(NSString *)replaceString:(NSString *)original findString:(NSString *)findString replaceWith:(NSString *)replaceWith{
	NSString *ret = original;
	ret = [ret stringByReplacingOccurrencesOfString:findString withString:replaceWith];
	return ret;
}

//merge application variables in any string - usually a URL
+(NSString *)mergeBTVariablesInString:(NSString *)theString{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"mergeBTVariablesInString (before): %@", theString]];
	NSString *ret = theString;
	
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
	//clear users location information if they don't wish to be tracked
	if([[BT_strings getPrefString:@"userAllowLocation"] isEqualToString:@"prevent"]){
		[appDelegate.rootDevice setDeviceLatitude:@"0"];
		[appDelegate.rootDevice setDeviceLongitude:@"0"];
	}
	
    //spaces in URL's...
    ret = [ret stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    
    //if we have an app...
    if([appDelegate rootApp] != nil){
        
        //application
        if([appDelegate.rootApp.jsonVars objectForKey:@"buzztouchAppId"]) ret = [ret stringByReplacingOccurrencesOfString:@"[buzztouchAppId]" withString:[appDelegate.rootApp.jsonVars objectForKey:@"buzztouchAppId"]];
        if([appDelegate.rootApp.jsonVars objectForKey:@"buzztouchAPIKey"]) ret = [ret stringByReplacingOccurrencesOfString:@"[buzztouchAPIKey]" withString:[appDelegate.rootApp.jsonVars objectForKey:@"buzztouchAPIKey"]];
        
        //screen
        if([appDelegate.rootApp currentScreenData] != nil){
            if([appDelegate.rootApp.currentScreenData.jsonVars objectForKey:@"itemId"] != nil){
                ret = [ret stringByReplacingOccurrencesOfString:@"[screenId]" withString:[appDelegate.rootApp.currentScreenData.jsonVars objectForKey:@"itemId"]];
            }
        }
        
        //user
        ret = [ret stringByReplacingOccurrencesOfString:@"[userId]" withString:[appDelegate.rootUser userId]];
        ret = [ret stringByReplacingOccurrencesOfString:@"[userEmail]" withString:[appDelegate.rootUser userEmail]];
        ret = [ret stringByReplacingOccurrencesOfString:@"[userLogInId]" withString:[appDelegate.rootUser userLogInId]];
        ret = [ret stringByReplacingOccurrencesOfString:@"[userLogInPassword]" withString:[appDelegate.rootUser userLogInPassword]];
        
        //device
        ret = [ret stringByReplacingOccurrencesOfString:@"[deviceId]" withString:[appDelegate.rootDevice deviceId]];
        ret = [ret stringByReplacingOccurrencesOfString:@"[deviceLatitude]" withString:[appDelegate.rootDevice deviceLatitude]];
        ret = [ret stringByReplacingOccurrencesOfString:@"[deviceLongitude]" withString:[appDelegate.rootDevice deviceLongitude]];
        ret = [ret stringByReplacingOccurrencesOfString:@"[deviceModel]" withString:[appDelegate.rootDevice deviceModel]];
        
    }//root app..
    
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"mergeBTVariablesInString (after merge): %@", ret]];
	
    
    
	
	//send it back
	return ret;
	
}


/*
 Returns the value of a JSON property or the defaultReturnObjectg if the key/value does not exist.
 */
+(NSString *)getJsonPropertyValue:(NSDictionary *)theValues nameOfProperty:(NSString *) nameOfProperty defaultValue:(NSString *) defaultValue{
	
    //-(void) getAddress:(NSString *)objectType coordinate:(CLLocationCoordinate2D) objectCoordinate;
    
    if([theValues objectForKey:nameOfProperty]){
		return (NSString *)[theValues objectForKey:nameOfProperty];
	}else{
		return (NSString *)defaultValue;
	}
    
}

/*
 This method returns a value pulled from the app's global theme or from the passed in screen if
 the that screen set a matching "over-ride" value
 */
+(NSString *)getStyleValueForScreen:(BT_item *)theParentScreenData nameOfProperty:(NSString *)nameOfProperty defaultValue:(NSString *)defaultValue{
	//[BT_debugger showIt:self:[NSString stringWithFormat:@"getStyleValueForScreen", @""]];
	
	//send this back
	NSString *retValue = defaultValue;
	
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
	//find the value form the app's global theme first then over-ride as needed
	if(appDelegate.rootApp.rootTheme != nil){
		if([[appDelegate.rootApp.rootTheme jsonVars] objectForKey:nameOfProperty]){
			if([[[appDelegate.rootApp.rootTheme jsonVars] objectForKey:nameOfProperty] length] > 0){
				retValue = [[appDelegate.rootApp.rootTheme jsonVars] objectForKey:nameOfProperty];
			}
		}
		//screen over-ride
		if([[theParentScreenData jsonVars] objectForKey:nameOfProperty]){
			if([[[theParentScreenData jsonVars] objectForKey:nameOfProperty] length] > 0){
				retValue = [[theParentScreenData jsonVars] objectForKey:nameOfProperty];
			}
		}
	}//not using a theme
	
	//return
	return retValue;
}

//format seconds to look a timer...
+(NSString *)formatTimeFromSeconds:(NSString *)seconds{
    
    // Return variable.
    NSString *result = @"";
    
    // Int variables for calculation.
    int secs = [seconds intValue];
    int tempHour    = 0;
    int tempMinute  = 0;
    int tempSecond  = 0;
    
    NSString *hour      = @"";
    NSString *minute    = @"";
    NSString *second    = @"";
    
    // Convert the seconds to hours, minutes and seconds.
    tempHour    = secs / 3600;
    tempMinute  = secs / 60 - tempHour * 60;
    tempSecond  = secs - (tempHour * 3600 + tempMinute * 60);
    
    hour    = [[NSNumber numberWithInt:tempHour] stringValue];
    minute  = [[NSNumber numberWithInt:tempMinute] stringValue];
    second  = [[NSNumber numberWithInt:tempSecond] stringValue];
    
    // Make time look like 00:00:00 and not 0:0:0
    if(tempHour < 10){
        hour = [@"0" stringByAppendingString:hour];
    }
    
    if(tempMinute < 10){
        minute = [@"0" stringByAppendingString:minute];
    }
    
    if(tempSecond < 10){
        second = [@"0" stringByAppendingString:second];
    }
    
    if(tempHour == 0){
        result = [NSString stringWithFormat:@"%@:%@", minute, second];
    }else{
        result = [NSString stringWithFormat:@"%@:%@:%@",hour, minute, second];
    }
    
    return result;
    
}

//formats a date from a string
+(NSString *)dateGMTDateFromString:(NSString *)theGMTDateString{
    
	/*
     It is assumed that dates are passed with GMT
     */
	
	//make date object from the passed in string..
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	[df setLocale:locale];
	[df setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
	NSDate *formattedDate = [df dateFromString:theGMTDateString];
	df = nil;
	
	//format the date object
	NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
	[displayFormatter setLocale:locale];
	[displayFormatter setDateFormat:@"EEEE dd MMMM yyyy HH:mm"];
	NSString *newDateString = [displayFormatter stringFromDate:formattedDate];
	displayFormatter = nil;
	
	return newDateString;
	
}

//clean's up character data...
+(NSString *)cleanUpCharacterData:(NSString *)theString{
    
	//replace crazy stuff that should not be in UTF-8 data...
	NSString *newString = theString;
    newString = [newString stringByReplacingOccurrencesOfString:@"&amp;"  withString:@"&"];
    newString = [newString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    newString = [newString stringByReplacingOccurrencesOfString:@"&#039;"  withString:@"'"];
    newString = [newString stringByReplacingOccurrencesOfString:@"&apos;"  withString:@"'"];
    newString = [newString stringByReplacingOccurrencesOfString:@"&gt;"  withString:@">"];
    newString = [newString stringByReplacingOccurrencesOfString:@"&lt;"  withString:@"<"];
    
	//return..
    return newString;
}


//strip HTML from string
+(NSString *)stripHTMLFromString:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == FALSE) {
        
        // find start of tag
		[theScanner scanUpToString:@"<" intoString:nil];
        
        // find end of tag
		[theScanner scanUpToString:@">" intoString:&text];
		
		// replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
		html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text]
                                               withString:@" "];
        
    }//while
    
    return html;
    
}

/*
 gets file name from a URL
 
 1) Look for a saveAsFileName in the URL string. URL must have at least one & (ampersand). Like...
 mydomain.com/file_stream.php?id=234234&saveAsFileName=myCoolImage.png
 
 ELSE
 
 2) Use objective C lastPathComponent method like
 mydomain.com/images/myCoolImage.png
 
 */
+(NSString *)getFileNameFromURL:(NSString *)theURLString{
	NSString *ret = @"";
	BOOL foundFileName = FALSE;
	if([theURLString length] > 0){
		if([theURLString rangeOfString:@"&" options:NSCaseInsensitiveSearch].location != NSNotFound){
			NSArray *queryStringParts = [theURLString componentsSeparatedByString:@"&"];
			if([queryStringParts count] > 0){
				for(NSString* key in queryStringParts){
					if([key rangeOfString:@"saveAsFileName" options:NSCaseInsensitiveSearch].location != NSNotFound){
						NSArray *fileNameParts = [key componentsSeparatedByString:@"="];
						if([fileNameParts count] == 2){
							foundFileName = true;
							ret = [fileNameParts objectAtIndex:1];
						}
					}
				}
			}
            
		}
	}	
	if(!foundFileName && [theURLString length] > 0){
		ret = [theURLString lastPathComponent];	
	}
	
	return ret;
}




@end









