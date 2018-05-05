//
//  ViewController.h
//  AugmentedReality
//
//  Created by Sergey Koval on 19/07/16.
//  Copyright © 2016 Sergey Koval. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARKit.h"
#import "ARDetailView.h"
#import "BT_viewController.h"

@interface FF_gpsar : BT_viewController <ARViewDelegate, ARDetailViewDelegate> {
    NSMutableArray *points;
    ARKitEngine *engine;
    
    NSInteger selectedIndex;
    ARDetailView *currentDetailView;
}

@end

