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



#import "BT_item.h"
#import "BT_imageTools.h"

@implementation BT_item
@synthesize	itemId, itemType, sortableColumnValue, jsonVars, itemNickname;
@synthesize image, imageName, imageURL, isHomeScreen;

//init
-(id)init{
    if((self = [super init])){
		//init vars..
		self.itemId = @"";
		self.itemNickname = @"";
		self.itemType = @"";
		self.jsonVars = nil;
		self.image = nil;
		self.imageName = @"";
		self.imageURL = @"";
		self.sortableColumnValue = @"";
		self.isHomeScreen = FALSE;
	}
	return self;
}



//donwload images
- (void)downloadImage{
		
	if(self.image != nil){
		image = nil;
	}
	
	/*
		Where does the image come from?
		a)	The file exists in the Xcode project, use it.
		b) 	The file does not exist in the Xcode project but does exist in the cache, use it
		c)	The file does not exist in the Xcode project, or in the cache, and a URL was provided, download it and cache it.
	
	*/
	
	if ([[self imageName] length] < 3) {
		
		self.image = nil;
		return;
		
	}else{
	
	
		//does icon exist in bundle, or locally in the cache?
		if([BT_fileManager doesFileExistInBundle:imageName]){
			
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"using image from Xcode bundle: %@", [self imageName]]];
			
			//use image from bundle
			UIImage *bundleImage = [UIImage imageNamed:imageName];
			self.image = bundleImage;

		}else{
		
			if([BT_fileManager doesLocalFileExist:imageName]){
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"using image from cache: %@", [self imageName]]];
			
				//use image from cache
				UIImage *cacheImage = [BT_fileManager getImageFromFile:imageName];
				self.image = cacheImage;
				
			}else{
			
				//download the image
				if([self.imageURL length] > 3){
				
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloading image from: %@", [self imageURL]]];

					///merge possible variables in URL
					NSString *useURL = [self imageURL];
					NSString *escapedUrl = [useURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				
					//download the image
					UIImage *tmpImage = [BT_imageTools getImageFromURL:escapedUrl];

					if(tmpImage){
						
						//if this BT_item does not have "cacheWebImages" = 0, this defaults to 1 (true, cache web images)
						if([[BT_strings getJsonPropertyValue:self.jsonVars nameOfProperty:@"cacheWebImages" defaultValue:@"1"] isEqualToString:@"1"]){
							//save image to cache
							[BT_fileManager saveImageToFile:tmpImage fileName:self.imageName];
						}
						
						//set then cleanup
						self.image = tmpImage;

					}else{
						
						//no icon downloaded, use default icon
						UIImage *tmpImage = [UIImage imageNamed:@"noImage.png"];
						self.image = tmpImage;
						
					}//response not successful
				}else{
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"no image url provided, not downloading: %@", @""]];
				}
			}
		}
	}//imageName
}





@end
