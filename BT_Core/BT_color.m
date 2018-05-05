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


#import "BT_color.h"


@implementation BT_color

+(UIColor *)getColorFromHexString:(NSString *)hexString{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"getColorFromHexString: %@", hexString]];
	
	//if null, or "" is passed in, bail out
	if(hexString == nil || [hexString isEqualToString:@"(null)"] || [hexString isEqualToString:@""]){
		//return a clear color
		return [UIColor clearColor];
	}
	
	// "clear" or "blank" color may be used instead of a hex value.
	if([hexString rangeOfString:@"clear" options:NSCaseInsensitiveSearch].location != NSNotFound || [hexString rangeOfString:@"blank" options:NSCaseInsensitiveSearch].location != NSNotFound){
		return [UIColor clearColor];
	}
	
	// "stries" may be used for native iOS looking background
	if([hexString rangeOfString:@"stripes" options:NSCaseInsensitiveSearch].location != NSNotFound){
		return [UIColor groupTableViewBackgroundColor];
	}	
		
	//if we are here, look for a # character to signal a hex value was passed in
	if([hexString rangeOfString:@"#" options:NSCaseInsensitiveSearch].location != NSNotFound){
		
		NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
		if([cleanString length] == 3) {
		  cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@", 
						 [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
						 [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
						 [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
		}
		if([cleanString length] == 6) {
			cleanString = [cleanString stringByAppendingString:@"ff"];
		}

		unsigned int baseValue;
		[[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];

		float red = ((baseValue >> 24) & 0xFF)/255.0f;
		float green = ((baseValue >> 16) & 0xFF)/255.0f;
		float blue = ((baseValue >> 8) & 0xFF)/255.0f;
		float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
		return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
			
	}
	
	//we should not be here, return a clear color
	return [UIColor clearColor];

}




@end
