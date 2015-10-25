#import "BEMAnalogClockView.h"

typedef NS_ENUM(NSInteger, DGTFloatingTimeViewArrowDirection) {
	DGTFloatingTimeViewArrowDirectionRight = 0,
	DGTFloatingTimeViewArrowDirectionLeft
};

@interface DGTFloatingTimeView : UIView <BEMAnalogClockDelegate> {
	DGTFloatingTimeViewArrowDirection _currentDirection;
	UILabel* _accurateTimeLabel;
	UILabel* _relativeTimeLabel;
	UIView* _boxView;
}
@property (nonatomic, retain) BEMAnalogClockView* clockView;
+(CGFloat)defaultWidth;
-(id)initWithDefaultSizeWithDirection:(DGTFloatingTimeViewArrowDirection)direction;
-(id)initWithWidth:(CGFloat)width withDirection:(DGTFloatingTimeViewArrowDirection)direction NS_DESIGNATED_INITIALIZER;
-(void)changeDirection:(DGTFloatingTimeViewArrowDirection)direction;
-(void)movedToDistanceFromOrigin:(CGFloat)distance;
@end