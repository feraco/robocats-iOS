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

#import "BT_user.h"


@implementation BT_user
@synthesize userId, userType, userDisplayName, userEmail, userLogInId, userLogInPassword, userIsLoggedIn, userImage;
@synthesize userAllowLocation;
 

-(id)init{
    if((self = [super init])){
		[BT_debugger showIt:self message:[NSString stringWithFormat:@"INIT"]];

		//init to empty vars, or previously saved values...
		[self setUserId:[BT_strings getPrefString:@"userId"]];
		[self setUserType:[BT_strings getPrefString:@"userType"]];
		[self setUserDisplayName:[BT_strings getPrefString:@"userDisplayName"]];
		[self setUserEmail:[BT_strings getPrefString:@"userEmail"]];
		[self setUserLogInId:[BT_strings getPrefString:@"userLogInId"]];
		[self setUserLogInPassword:[BT_strings getPrefString:@"userLogInPassword"]];
		[self setUserIsLoggedIn:[BT_strings getPrefString:@"userIsLoggedIn"]];
		[self setUserAllowLocation:[BT_strings getPrefString:@"userAllowLocation"]];
		[self setUserImage:nil];
		
		//if we have a guid and an email address in prefs, we are logged in
		if([[BT_strings getPrefString:@"userId"] length] > 0){
			[self setUserIsLoggedIn:@"1"];
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"User is logged in with id: \"%@\"", [BT_strings getPrefString:@"userId"]]];
		}else{
			[self setUserIsLoggedIn:@"0"];
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"User is not logged in"]];
        }
		
        //if the user prevented location services from a settings plugin...
        if([[self userAllowLocation] length] < 2) {
            [self setUserAllowLocation:@"allow"];
        }else{
            [self setUserAllowLocation:@"deny"];
        }

		
	}
	return self;
}




@end





