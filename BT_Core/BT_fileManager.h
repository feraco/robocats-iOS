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



@interface BT_fileManager : NSObject {
	
}

+(NSString*)getFilePath:(NSString *)fileName;
+(NSString*)getBundlePath:(NSString *)fileName;
+(BOOL)doesLocalFileExist:(NSString *)fileName;
+(BOOL)doesFileExistInBundle:(NSString *)fileName;
+(BOOL)saveDataToFile:(NSData *)theData fileName:(NSString *)fileName;
+(BOOL)saveImageToFile:(UIImage *)theImage fileName:(NSString *)fileName;
+(void)deleteFile:(NSString *)fileName;
+(void)deleteAllLocalData;
+(void)deleteScreenData:(NSString *)theScreenId;
+(BOOL)makeWritableFromBundle:(NSString *)fileName;

+(BOOL)saveTextFileToCacheWithEncoding:(NSString *)stringData fileName:(NSString *)fileName encodingFlag:(int)encodingFlag;
+(NSString *)readTextFileFromCacheWithEncoding:(NSString *)fileName encodingFlag:(int)encodingFlag;
+(NSString *)readTextFileFromBundleWithEncoding:(NSString *)fileName encodingFlag:(int)encodingFlag;


+(NSString *)getHumanReadableLocalStorageSize;
+(int)getLocalDataSizeInt;
+(int)countLocalFiles;
+(NSString *)stringFromFileSize:(int)theSize;
+(int)getSizeOfFile:(NSString *)path;
+(int)getSizeOfFolder:(NSString*)folderPath;
+(UIImage *)getImageFromFile:(NSString *)fileName;


@end
