//
//  NAD_iapItem.m
//  nrcgfes
//
//  Created by Nicholas DInnocenzo on 8/16/14.
//  Copyright (c) 2014 Buzztouch. All rights reserved.
//

#import "NAD_iapItem.h"








@implementation NAD_iapItem

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.productID = [aDecoder decodeObjectForKey:@"pID"];
    self.purchased = [aDecoder decodeBoolForKey:@"purchased"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.productID forKey:@"pID"];
    [aCoder encodeBool:self.purchased forKey:@"purchased"];

}


@end
