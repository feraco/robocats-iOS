//
//  DetailView.h
//  ARKit Example
//
//  Created by Carlos on 25/10/13.
//
//

#import <UIKit/UIKit.h>

@protocol ARDetailViewDelegate <NSObject>
@optional
-(void)didCloseARDetailView;
@end

@interface ARDetailView : UIView
@property (nonatomic, strong) IBOutlet UILabel *nameLbl;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, weak) id<ARDetailViewDelegate> delegate;
@end
