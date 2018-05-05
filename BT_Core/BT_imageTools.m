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


#include <math.h>
#import "BT_imageTools.h"


@implementation BT_imageTools

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight){
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0){
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+(UIImage *)makeRoundCornerImage : (UIImage*) img : (int) cornerWidth : (int) cornerHeight{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"makeRoundCornerImage: cornerWidth: %i cornerHeight: %i ", cornerWidth, cornerHeight]];
	
	if(img != nil){
        @autoreleasepool{
            int w = img.size.width;
            int h = img.size.height;
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, w * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
            
            CGContextBeginPath(context);
            CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
            addRoundedRectToPath(context, rect, cornerWidth, cornerHeight);
            CGContextClosePath(context);
            CGContextClip(context);
            
            CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
            
            CGImageRef imageMasked = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            CGColorSpaceRelease(colorSpace);
            
            //newImage = [[UIImage imageWithCGImage:imageMasked] retain];
            img = [UIImage imageWithCGImage:imageMasked];

            CGImageRelease(imageMasked);
		
		}//autoreleasepool
        
	}
	
    return img;
}



/*
	This method takes an icon name, slices it up then returns the "white" version name.
	Example: house.png would become house_white.png 
	This approach allows us to set a "useWhiteIcons" flag on screens that have dark backgrounds.
*/
+(NSString *)getWhiteIconName:(NSString *)theIconName{
	if([theIconName rangeOfString:@".png" options:NSCaseInsensitiveSearch].location != NSNotFound){
		theIconName = [theIconName stringByReplacingOccurrencesOfString:@".png" withString:@""];
		theIconName = [theIconName stringByAppendingString:@"_white.png"]; 
	}
	return theIconName;
	
}

//scales image to size
+(UIImage *)scaleToSize:(UIImage *)originalImage size:(CGSize)size{
    
	//scalling image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));

    if(originalImage.imageOrientation == UIImageOrientationRight){
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), originalImage.CGImage);
    }else{
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), originalImage.CGImage);
	}
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);

    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    UIImage *image = [UIImage imageWithCGImage: scaledImage];

    CGImageRelease(scaledImage);

    return image;
}


+(UIImage *)scaleProportionalToSize:(UIImage *)originalImage size:(CGSize)size{
    if(originalImage.size.width>originalImage.size.height){
        //landscape
		size = CGSizeMake((originalImage.size.width/originalImage.size.height)*size.height,size.height);
    }else{
		//portrait
        size = CGSizeMake(size.width,(originalImage.size.height/originalImage.size.width)*size.width);
    }
    return [self scaleToSize:originalImage size:size];
}

+(UIImage *)getImageFromURL:(NSString *)imageURL{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
}



@end










