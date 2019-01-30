#import <UIKit/UIKit.h>

@interface ScannerOverlay : UIView
  @property(nonatomic) CGRect scanLineRect;
  @property(nonatomic, retain) UIColor *cornerColor;
  -(id)initWithFrameAndTheme:(CGRect)frame theme:(UIColor *)cornerColor;
@end
