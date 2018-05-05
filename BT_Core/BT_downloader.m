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


#import "BT_downloader.h"

@implementation BT_downloader
@synthesize delegate, urlString, saveAsFileName, saveAsFileType, expectedDownloadSize;
@synthesize receivedData, remoteConn, downloadTimer, downloadSeconds, timeoutSeconds;

-(id)init{
    self = [super init];
    if(self != nil) {
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"INIT%@", @""]];
		
		[self setDownloadSeconds:0];
		[self setTimeoutSeconds:30];
		[self setExpectedDownloadSize:0];
    }
    return self;
}

//sends message to delegate that download started..
-(void)downloadFileStarted:(NSString *)message{
	[self setDownloadSeconds:0];
    SEL selector = NSSelectorFromString(@"downloadFileStarted:");
    if([self.delegate respondsToSelector:selector]){
		[self.delegate downloadFileStarted:message];
	}
}
//sends message to delegate during the download..
-(void)downloadFileInProgress:(NSString *)message{
	[self setDownloadSeconds:0];
    SEL selector = NSSelectorFromString(@"downloadFileInProgress:");
	if([self.delegate respondsToSelector:selector]){
		[self.delegate downloadFileInProgress:message];
	}
}
//sends message to delegate that download completed..
-(void)downloadFileCompleted:(NSString *)message{
	[self setDownloadSeconds:0];
    SEL selector = NSSelectorFromString(@"downloadFileCompleted:");
	if([self.delegate respondsToSelector:selector]){
		[self.delegate downloadFileCompleted:message];
	}
	if(self.downloadTimer){
		[self.downloadTimer invalidate];
	}
}


//cancel download
-(void)cancelDownload{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"cancelDownload%@", @""]];
    
	[self setDownloadSeconds:0];
	if(self.remoteConn){
		[self.remoteConn cancel];
	}
	if(self.downloadTimer){
		[self.downloadTimer invalidate];
	}
    SEL selector = NSSelectorFromString(@"downloadCompleted:");
    if([self.delegate respondsToSelector:selector]){
		[self.delegate downloadFileCompleted:@"Download Cancelled"];
	}
    
}

//timer tracks how long it took
-(void)timerTick{
	self.downloadSeconds++;
	
	//if we've begun downloading... and it's taking too long, bail out...
	if(self.downloadSeconds > self.timeoutSeconds){
		if(self.downloadTimer){
			[self.downloadTimer invalidate];
		}
		[self.remoteConn cancel];
		[self setDownloadSeconds:0];
		[self downloadFileCompleted:@"ERROR-1968: Data download timed out"];
	}
}

//start parse at URL
-(void)downloadFile{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloadFile: %@", urlString]];
    
	//tell delegate download has started
	[self downloadFileStarted:@"starting download..."];
	
	//start timer to track how long this is taking
	if(self.downloadTimer){
		[self.downloadTimer invalidate];
	}
    
	self.downloadTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:NULL repeats:YES];
    
	//replace "feed://" with "http://" in urlString
	NSString *useURL = [urlString stringByReplacingOccurrencesOfString:@"feed://" withString:@"http://"];
    
	//clean-up URL, encode as UTF8
	NSURL *escapedURL = [NSURL URLWithString:useURL];
    
	//start request
	NSMutableURLRequest  *theRequest = [NSMutableURLRequest requestWithURL:escapedURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:25.0];
	[theRequest setHTTPMethod:@"GET"];
	self.remoteConn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:TRUE];
	if(self.remoteConn){
		receivedData = [[NSMutableData data] init];
	}else{
		[self downloadFileCompleted:@"ERROR-1968 - could not initialize connection."];
	}
	
}

//post vars to URL
-(void)postToURL:(NSString *)postVars{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloadFile: %@", urlString]];
    
	//tell delegate download has started
	[self downloadFileStarted:@"starting download..."];
	
	//start timer to track how long this is taking
	if(self.downloadTimer){
		[self.downloadTimer invalidate];
	}
	self.downloadTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:NULL repeats:YES];
    
	//replace "feed://" with "http://" in urlString
	NSString *useURL = [urlString stringByReplacingOccurrencesOfString:@"feed://" withString:@"http://"];
    
	//clean-up URL, encode as UTF8
	NSURL *escapedURL = [NSURL URLWithString:[useURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
	//start request
	NSMutableURLRequest  *theRequest = [NSMutableURLRequest requestWithURL:escapedURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:25.0];
    
	//clean-up URL, encode as UTF8
	NSData *postData = [postVars dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];

	//start request
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[theRequest setHTTPBody:postData];
	if((self.remoteConn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self])){
		receivedData = [[NSMutableData data] init];
	}else{
		[self downloadFileCompleted:@"ERROR-1968 Could not create HTTP Post?"];
	}
    
}

//receive response
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	[receivedData setLength:0];
	
	//save the size of the download
	[self setExpectedDownloadSize:(int)[response expectedContentLength]];
    
    SEL selector = NSSelectorFromString(@"statusCode");
	if([response respondsToSelector:selector]){
		int statusCode = (int)[((NSHTTPURLResponse *)response) statusCode];
		if (statusCode >= 400){
			[remoteConn cancel];  // error stop connecting; no more delegate messages
			[self downloadFileCompleted:@"ERROR-1968: URL returned 400 - location not available"];
		}
	}
	
}

//receive data
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if(data != nil){
		[receivedData appendData:data];
		
		//if we are still getting data... keep the downloadSeconds at zero so it does not timeout.
		[self setDownloadSeconds:0];
		
		//send percentage downloaded to delegate. Only do this if we know
		//how much is downloaded and how much to expect...
		float theVal = 0;
		if([self expectedDownloadSize] > 0 && [receivedData length] > 0){
			theVal = ([receivedData length] * 100) / [self expectedDownloadSize];
            NSString *formatted = [NSString stringWithFormat:@"%g%%", theVal];
		    [self.delegate downloadFileInProgress:formatted];
		}
		
	}
}

//connection failure
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self downloadFileCompleted:[NSString stringWithFormat:@"ERROR-1968: Code: %i Description: %@", (int)[error code], [error localizedDescription]]];
}

//done dowloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
	//if we are saving the file after it's downloaded?
	if([self.saveAsFileName length] > 3){
        
		//ignore this if we have "return" as the saveAsFileType
		if(![saveAsFileType isEqualToString:@"return"]){
            
			//if saving text files (JSON, XML, HTML, etc)
			if([saveAsFileType isEqualToString:@"text"] ||
               [saveAsFileName rangeOfString:@".txt" options:NSCaseInsensitiveSearch].location != NSNotFound ||
               [saveAsFileName rangeOfString:@".html" options:NSCaseInsensitiveSearch].location != NSNotFound ||
               [saveAsFileName rangeOfString:@".xml" options:NSCaseInsensitiveSearch].location != NSNotFound){
                
				//try saving with UTF-8 Encoding. Try NSISOLatin1StringEncoding if that fails
				NSString *theEncodedString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
				if(theEncodedString){
					
					//if we successfully loaded the NSUTF8StringEncoding string
					if(![BT_fileManager saveTextFileToCacheWithEncoding:theEncodedString fileName:saveAsFileName encodingFlag:-1]){
						[BT_debugger showIt:self message:[NSString stringWithFormat:@"Error saving file (tried UTF-8 Encoding): %@", saveAsFileName]];
					}
					
				}else{
					
					//if an error occrred trying to load the NSUTF8StringEncoding string, try NSISOLatin1StringEncoding
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"Error saving file (tried UTF-8 Encoding): %@", saveAsFileName]];
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"Trying different character set (NSISOLatin1StringEncoding): %@", saveAsFileName]];
					
					//try re-loading as NSISOLatin1StringEncoding
					theEncodedString = [[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding];
					if(![BT_fileManager saveTextFileToCacheWithEncoding:theEncodedString fileName:saveAsFileName encodingFlag:5]){
						[BT_debugger showIt:self message:[NSString stringWithFormat:@"Error saving file (tried NSISOLatin1StringEncoding): %@", saveAsFileName]];
					}
                    
				}
			}
            
			//save PDF (NSData, not a string)
			if([saveAsFileName rangeOfString:@".pdf" options:NSCaseInsensitiveSearch].location != NSNotFound){
				BOOL saved = [BT_fileManager saveDataToFile:receivedData fileName:saveAsFileName];
				if(!saved){
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"Error saving file: %@", saveAsFileName]];
				}
			}
            
			//save XLS (NSData, not a string)
			if([saveAsFileName rangeOfString:@".xls" options:NSCaseInsensitiveSearch].location != NSNotFound){
				BOOL saved = [BT_fileManager saveDataToFile:receivedData fileName:saveAsFileName];
				if(!saved){
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"Error saving file: %@", saveAsFileName]];
				}
			}
            
			//save PPT (NSData, not a string)
			if([saveAsFileName rangeOfString:@".ppt" options:NSCaseInsensitiveSearch].location != NSNotFound){
				BOOL saved = [BT_fileManager saveDataToFile:receivedData fileName:saveAsFileName];
				if(!saved){
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"Error saving file: %@", saveAsFileName]];
				}
			}
            
			//save Word Docs (NSData, not a string)
			if([saveAsFileName rangeOfString:@".doc" options:NSCaseInsensitiveSearch].location != NSNotFound){
				BOOL saved = [BT_fileManager saveDataToFile:receivedData fileName:saveAsFileName];
				if(!saved){
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"Error saving file: %@", saveAsFileName]];
				}
			}
            
            //save Word Docs (.docx) (NSData, not a string)
			if([saveAsFileName rangeOfString:@".docx" options:NSCaseInsensitiveSearch].location != NSNotFound){
				BOOL saved = [BT_fileManager saveDataToFile:receivedData fileName:saveAsFileName];
				if(!saved){
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"Error saving file: %@", saveAsFileName]];
				}
			}
            
			
			//save Image (.PNG or .JPG)
			if([saveAsFileType rangeOfString:@"image" options:NSCaseInsensitiveSearch].location != NSNotFound){
				UIImage *tmpImage = [[UIImage alloc] initWithData:receivedData];
				BOOL saved = [BT_fileManager saveImageToFile:tmpImage fileName:saveAsFileName];
				if(!saved){
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"Error saving file: %@", saveAsFileName]];
				}
			}
            
		}//saveAsFileType != return
		
	}//saveAsFileName == nil
	
	//tell the delgate the download is done OR return the results if "return" was passed as saveAsFileType
	if([[self saveAsFileType ] isEqualToString:@"return"]){
        
		//try saving with UTF-8 Encoding. Try NSISOLatin1StringEncoding if that fails
		NSString *theEncodedString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		
        //don't save if we don't have a file name...
        if([saveAsFileName length] > 3){
            if(theEncodedString){
                if(![BT_fileManager saveTextFileToCacheWithEncoding:theEncodedString fileName:saveAsFileName encodingFlag:-1]){
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Error returning string (tried UTF-8 Encoding)%@", @""]];
                }
            }else{
                theEncodedString = [[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding];
                if(![BT_fileManager saveTextFileToCacheWithEncoding:theEncodedString fileName:saveAsFileName encodingFlag:-1]){
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Error returning string (tried UTF-8 Encoding)%@", @""]];
                }
            }
        }
        
        //send the encoding string to the download completed method...
		[self downloadFileCompleted:theEncodedString];
        
        
	}else{
        
		if([[self saveAsFileType ] isEqualToString:@"ignore"]){
			//do nothing
		}else{
			[self downloadFileCompleted:@"Success"];
		}
	}
	
}



@end


