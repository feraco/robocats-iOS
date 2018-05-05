//
//  Scene.m
//  AugmentedReality
//
//  Created by Sergey Koval on 28/07/16.
//  Copyright © 2016 Sergey Koval. All rights reserved.
//

#import "Scene.h"

@implementation Scene

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        [self setupScene];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        [self setupScene];
    }
    return self;
}

-(void)awakeFromNib {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self setupScene];
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.alpha > 0 && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    return NO;
}

-(void)setupScene {
    SCNScene *scene = [SCNScene new];
    SCNNode *cameraNode = [SCNNode new];
    cameraNode.camera = [SCNCamera new];
    [scene.rootNode addChildNode:cameraNode];
    cameraNode.position = SCNVector3Make(0, 0, 15);
    
    SCNNode *lightNode = [SCNNode new];
    lightNode.light = [SCNLight new];
    lightNode.light.type = SCNLightTypeOmni;
    [scene.rootNode addChildNode:lightNode];
    lightNode.position = SCNVector3Make(0, 10, 10);
    
    SCNNode *ambientLightNode = [SCNNode new];
    ambientLightNode.light = [SCNLight new];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor lightGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];

    
    SCNNode *lighthouse = [SCNNode new];
    SCNScene *scene2 = [SCNScene sceneNamed:@"lighthouse.dae"];
    NSArray *nodeArray = scene2.rootNode.childNodes;
    
    for (SCNNode *node in nodeArray) {
        [lighthouse addChildNode:node];
    }
    
    [scene.rootNode addChildNode:lighthouse];
    lighthouse.position = SCNVector3Make(0, 3.5, 0);
    lighthouse.scale = SCNVector3Make(0.002, 0.002, 0.002);
    [lighthouse runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    
    self.scene = scene;
    self.backgroundColor = [UIColor clearColor];
    self.allowsCameraControl = YES;
    self.showsStatistics = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGesture];
}

-(void)handleTap:(UIGestureRecognizer*)gestureRecognize {
    SCNView *scnView = (SCNView*)self;
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    if (hitResults.count > 0) {
        SCNHitTestResult *result = hitResults.lastObject;
        SCNMaterial *material = result.node.geometry.firstMaterial;
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            material.emission.contents = [UIColor blackColor];
            [SCNTransaction commit];
        }];
        material.emission.contents = [UIColor yellowColor];
        [SCNTransaction commit];
    }
}

@end
