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


#import "BT_fileManager.h"


@implementation BT_fileManager


/*ENCODING REFERENCE (flags)
*
*	NSASCIIStringEncoding = 1
*	NSNEXTSTEPStringEncoding = 2
*	NSJapaneseEUCStringEncoding = 3
*	NSUTF8StringEncoding = 4
*	NSISOLatin1StringEncoding = 5
*	NSSymbolStringEncoding = 6
*	NSNonLossyASCIIStringEncoding = 7
*	NSShiftJISStringEncoding = 8
*	NSISOLatin2StringEncoding = 9
*	NSUnicodeStringEncoding = 10
*	NSWindowsCP1251StringEncoding = 11
*	NSWindowsCP1252StringEncoding = 12
*	NSWindowsCP1253StringEncoding = 13
*	NSWindowsCP1254StringEncoding = 14
*	NSWindowsCP1250StringEncoding = 15
*	NSISO2022JPStringEncoding = 21
*	NSMacOSRomanStringEncoding = 30
*	NSUTF16StringEncoding = NSUnicodeStringEncoding
*	NSUTF16BigEndianStringEncoding = 0x90000100
*	NSUTF16LittleEndianStringEncoding = 0x94000100
*	NSUTF32StringEncoding = 0x8c000100
*	NSUTF32BigEndianStringEncoding = 0x98000100
*	NSUTF32LittleEndianStringEncoding = 0x9c000100	
*
*/
	




//get path to a named file...
+(NSString*)getFilePath:(NSString *)fileName{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingString:@"/"];
	filePath = [filePath stringByAppendingString:fileName];	
	return filePath;
}

//gets path to a file in the bundle
+(NSString*)getBundlePath:(NSString *)fileName{
	NSString *defaultFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
	return defaultFilePath;
}

//does named file exist on writeable file system...
+(BOOL)doesLocalFileExist:(NSString *)fileName{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"doesLocalFileExist: %@", fileName]];
	BOOL success = FALSE;
	if(fileName != nil && [fileName length] > 1){
		NSFileManager *fileManager = [NSFileManager defaultManager];
		success = [fileManager fileExistsAtPath:[self getFilePath:fileName]];
		if(success){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"File does exist in cached directory: \"%@\"", fileName]];
			success = TRUE;
		}else{
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"File does not exist in cached directory: \"%@\"", fileName]];
			success = FALSE;
		}	
	}	
	return success;
}

//does named file exist in the applications bundle...
+(BOOL)doesFileExistInBundle:(NSString *)fileName{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"doesFileExistInBundle: %@", fileName]];
	BOOL success = FALSE;
	if(fileName != nil && [fileName length] > 1){
		NSFileManager *fileManager = [NSFileManager defaultManager];
		success = [fileManager fileExistsAtPath:[self getBundlePath:fileName]];
		if(success){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"File does exist in Xcode bundle: \"%@\"", fileName]];
			success = TRUE;
		}else{
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"File does not exist in Xcode bundle: \"%@\"", fileName]];
			success = FALSE;
		}
	}
	return success;
}

//deletes file
+(void)deleteFile:(NSString *)fileName{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"deleteFile: \"%@\"", fileName]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	if([fileManager fileExistsAtPath:[self getFilePath:fileName]]){
		if(![fileManager removeItemAtPath:[self getFilePath:fileName] error:&error]){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"deleteFile: Error deleting file: \"%@\", %@, %@", fileName, error, [error userInfo]]];
		}
	}
}

//deletes all local data
+(void)deleteAllLocalData{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"deleteAllLocalData%@", @""]];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *filesArray = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
	
    //get a reference to the appDelegate...
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];

    
    
     for (int i = 0; i < [filesArray count]; i++){
		NSString *fileName = [filesArray objectAtIndex:i];
		
        BOOL doDelete = true;
        
        //do NOT delete the applications cached configuration file...
        if([fileName isEqualToString:[appDelegate saveAsFileName]]){
            doDelete = false;
        }
         
        //some plugins use persisted files...do NOT delete these.
        BOOL persistedResult = [fileName hasPrefix:@"persist_"];
         if(persistedResult){
            doDelete = false;
        }
    
        //delete the file?         
        if(doDelete){
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"deleting: \"%@\"", fileName]];
            NSString *filePath = [documentsDirectory stringByAppendingString:@"/"];
            filePath = [filePath stringByAppendingString:fileName];
            [fileManager removeItemAtPath:filePath error:NULL];
        }else{
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"NOT deleting (persisted): \"%@\"", fileName]];
        }
        
				
	}//end for each file.
	
}



//deletes all data associated with a screen
+(void)deleteScreenData:(NSString *)theScreenId{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"deleteScreenData for screen with id: \"%@\"", theScreenId]];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *filesArray = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
	for (int i = 0; i < [filesArray count]; i++){
		NSString *fileName = [filesArray objectAtIndex:i];
		
		if([fileName rangeOfString:theScreenId options:NSCaseInsensitiveSearch].location != NSNotFound){
		
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"deleting: \"%@\"", fileName]];
			NSString *filePath = [documentsDirectory stringByAppendingString:@"/"];
			filePath = [filePath stringByAppendingString:fileName];
			[fileManager removeItemAtPath:filePath error:NULL];
		}
		
	}//end for each file.
	
}


//copies file in bundle to writeable location
+(BOOL)makeWritableFromBundle:(NSString *)fileName{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"makeWritableFromBundle: \"%@\"", fileName]];
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *defaultFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
	if(![fileManager copyItemAtPath:defaultFilePath toPath:[self getFilePath:fileName] error:&error]){
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"makeWritableFromBundle: Error copying file: \"%@\", %@, %@", fileName, error, [error userInfo]]];
		return FALSE;
	}else{
		return TRUE;
	}
}


//read text file from bundle with encoding
+(NSString *)readTextFileFromBundleWithEncoding:(NSString *)fileName encodingFlag:(int)encodingFlag{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"readTextFileFromBundleWithEncoding: \"%@\" encoding: %i", fileName, encodingFlag]];
	
	//If encodingFlag is -1 (the default), use NSUTF8StringEncoding
	if(encodingFlag == -1){
		encodingFlag = 4;
	}
		
	//if we cannot read the data using the NSUTF8StringEncoding encoding, try NSISOLatin1StringEncoding
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *bundleFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
	if([fileManager fileExistsAtPath:bundleFilePath]){
		NSData *bundleData = [fileManager contentsAtPath:bundleFilePath];
		NSString *dataString = [[NSString alloc] initWithData:bundleData encoding:encodingFlag];
		if(!dataString){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"readTextFileFromBundleWithEncoding ERROR using encoding NSUTF8StringEncoding, trying NSISOLatin1StringEncoding%@", @""]];
			dataString = [[NSString alloc] initWithData:bundleData encoding:5];
		}
		return dataString;
	}else{
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"readTextFileFromBundleWithEncoding ERROR. Could not read file in bundle: \"%@\"", fileName]];
		return @"";
	}
}

//read text file from cache with encoding
+(NSString *)readTextFileFromCacheWithEncoding:(NSString *)fileName encodingFlag:(int)encodingFlag{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"readTextFileFromCacheWithEncoding: \"%@\" encoding: %i", fileName, encodingFlag]];

	//If encodingFlag is -1 (the default), use NSUTF8StringEncoding
	if(encodingFlag == -1){
		encodingFlag = 4;
	}
	//if we cannot read the data using the NSUTF8StringEncoding encoding, try NSISOLatin1StringEncoding
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingString:@"/"];
	filePath = [filePath stringByAppendingString:fileName];	
	NSError *error;
	NSString *stringFromFileAtPath = [[NSString alloc] initWithContentsOfFile:filePath encoding:encodingFlag error:&error];
	if(!stringFromFileAtPath){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"readTextFileFromCacheWithEncoding ERROR using encoding NSUTF8StringEncoding, trying NSISOLatin1StringEncoding%@", @""]];
		stringFromFileAtPath = [[NSString alloc] initWithContentsOfFile:filePath encoding:5 error:&error];
	}
	return stringFromFileAtPath;
	
}


//saves TEXT file with encoding
+(BOOL)saveTextFileToCacheWithEncoding:(NSString *)stringData fileName:(NSString *)fileName encodingFlag:(int)encodingFlag{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"saveTextFileToCacheWithEncoding: \"%@\" encodingFlag: %i", fileName, encodingFlag]];
	
	//If encodingFlag is -1 (the default), use NSUTF8StringEncoding
	if(encodingFlag == -1){
		encodingFlag = 4;
	}
	
	//If fileName alraedy exists it will be overwritten	
	NSError *error;
	if(![stringData writeToFile:[self getFilePath:fileName] atomically:YES encoding:encodingFlag error:&error]){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"saveTextFileToCacheWithEncoding: ERROR saving string data to file: \"%@\" encodingFlag: %i error:%@", fileName, encodingFlag, [error localizedDescription]]];
		return FALSE;
	}else{
		return TRUE;
	}
	
	
}


//return string representation of local file storage size
+(NSString *)getHumanReadableLocalStorageSize{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"getHumanReadableLocalStorageSize%@", @""]];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	int tmpSize = [self getSizeOfFolder:documentsDirectory];
	return [self stringFromFileSize:tmpSize];
}

//return int representation of local file storage size
+(int)getLocalDataSizeInt{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"getLocalDataSizeInt%@", @""]];
	//NSLog(@"BT_fileManager: getLocalDataSizeInt);
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [self getSizeOfFolder:documentsDirectory];
}

//get count of how many files we are storing locally
+(int)countLocalFiles{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"countLocalFiles%@", @""]];
	int countOfFiles = 0;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *filesArray = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
	//NSLog(@"deleting %i files", filesArray.count);
	for (int i = 0; i < [filesArray count]; i++) {
		countOfFiles = (countOfFiles + 1);
	}//end for
	return countOfFiles;
}

//converts file size to human readable string
+(NSString *)stringFromFileSize:(int)theSize{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"stringFromFileSize: %i", theSize]];
	float floatSize = theSize;
	if (theSize < 1023)
		return([NSString stringWithFormat:@"%i bytes",theSize]);
	floatSize = floatSize / 1024;
	if (floatSize < 1023)
		return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
	floatSize = floatSize / 1024;
	if (floatSize < 1023)
		return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
	floatSize = floatSize / 1024;
	return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

//get size of one file
+(int)getSizeOfFile:(NSString *)path{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"sizeOfFile: %@", path]];
	NSDictionary *fattrib = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
	int fileSize = (int)[fattrib fileSize];
	return fileSize;
}

//get size of one directory
+(int)getSizeOfFolder:(NSString*)folderPath{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"getSizeOfFolder: %@", folderPath]];
	NSArray *contents;
	NSEnumerator *enumerator;
	NSString *path;
	contents = [[NSFileManager defaultManager] subpathsAtPath:folderPath];
	enumerator = [contents objectEnumerator];
	int fileSizeInt = 0;
	while ((path = [enumerator nextObject])) {
		NSDictionary *fattrib = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:path] error:NULL];
		fileSizeInt +=[fattrib fileSize];
	}
	return fileSizeInt;
}


//saves NSData to file system
+(BOOL)saveDataToFile:(NSData *)theData fileName:(NSString *)fileName{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"saveDataToFile: \"%@\"", fileName]];
	//NSLog(@"BT_fileManager: saveTextFile: %@", fileName);
	if([theData writeToFile:[self getFilePath:fileName] atomically:YES]){
		return TRUE;
	}else{
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"ERROR saving data to file: \"%@\"", fileName]];
		return FALSE;
	}
}

//returns an image from a file
+(UIImage *)getImageFromFile:(NSString *)fileName{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"getImageFromFile: \"%@\"", fileName]];
	UIImage *theImage = nil;
	if([self doesLocalFileExist:fileName]){
    	NSData *data = [[NSData alloc] initWithContentsOfFile:[self getFilePath:fileName]];
		theImage = [[UIImage alloc] initWithData:data];
	}
	return theImage;
}


//saves image to file
+(BOOL)saveImageToFile:(UIImage *)theImage fileName:(NSString *)fileName{
	
	//save locallly
	if([fileName rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound){
		NSData *imgData = UIImagePNGRepresentation(theImage);
		if(imgData){
			[imgData writeToFile:[self getFilePath:fileName] atomically: YES];
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"saveImageToFile: \"%@\"", fileName]];
		}else{
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"saveImageToFile: ERROR, could not save image to cache %@", fileName]];
		}
		return TRUE;
	}
	
	if([fileName rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound ||
	   [fileName rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound){
			NSData *imgData = UIImageJPEGRepresentation(theImage, 100);
			if(imgData){
				[imgData writeToFile:[self getFilePath:fileName] atomically: YES];
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"saveImageToFile: \"%@\"", fileName]];
			}else{
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"saveImageToFile: ERROR, could not save image to cache %@", fileName]];
			}
			return TRUE;
	}//not a .png
	
	//if failed?
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"saveImageToFile: ERROR saving: \"%@\"", fileName]];
	return FALSE;

}




@end







