//
//  DetailView.m
//  ARKit Example
//
//  Created by Carlos on 25/10/13.
//
//

#import "ARDetailView.h"

@implementation ARDetailView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            CGSize s = [UIScreen mainScreen].bounds.size;
            self.frame = CGRectMake(0, 0, s.height, s.width);
        } else {
            self.frame = [UIScreen mainScreen].bounds;
        }
    }
    return self;
}

- (IBAction)close {
    [self removeFromSuperview];
}

- (IBAction)closeAndGoToLocations {
    [self.delegate didCloseARDetailView];
    [self removeFromSuperview];
}

@end
