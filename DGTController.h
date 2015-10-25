@class _UIBackdropView, DGTConcentricRingView, DGTFloatingTimeView;

#define kFloatingTimeViewPadding 60

@interface DGTController : NSObject <UIGestureRecognizerDelegate, UIAlertViewDelegate> {
	BOOL _longPressHasBeenInvoked;
	_UIBackdropView* _backdropView;
	UIWindow* _previousKeyWindow;
	UITapGestureRecognizer* _doubleTapRec;
	DGTConcentricRingView* _ringView;
	CAShapeLayer* _lineLayer;
	CAShapeLayer* _endDot;
	DGTFloatingTimeView* _floatingTimeView;
	CGFloat _distance;
}
+(instancetype)sharedInstance;
+(UIWindow*)mainDeviceView;
-(void)setupRecognizers;
-(BOOL)selectionViewIsInvoked;
-(void)selectionViewTouchBeganWithLocation:(CGPoint)locationInView;
-(void)selectionViewTouchMovedWithLocation:(CGPoint)locationInView;
-(void)selectionViewTouchEndedWithLocation:(CGPoint)locationInView withRecognizer:(UIGestureRecognizer*)rec;
@end
