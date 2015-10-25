#import "DGTFloatingTimeView.h"
#import "BEMAnalogClockView.h"
#import "DGTConcentricRingView.h"
#import "Interfaces.h"

#define kArrowHeight 20

@implementation DGTFloatingTimeView : UIView
+ (Class)layerClass {
    return [CAShapeLayer class];
}
+(CGFloat)defaultWidth {
	return ([[UIScreen mainScreen] bounds].size.width/2)*0.9;
}
-(id)initWithDefaultSizeWithDirection:(DGTFloatingTimeViewArrowDirection)direction {
	return [self initWithWidth:[DGTFloatingTimeView defaultWidth] withDirection:direction];
}
-(id)initWithWidth:(CGFloat)width withDirection:(DGTFloatingTimeViewArrowDirection)direction {
	if ((self = [super initWithFrame:CGRectMake(0, 0, width, width/3)])) {

		_boxView = [[UIView alloc] initWithFrame:[self boxFrameWithDirection:direction]];
		[self addSubview:_boxView];

		_clockView = [[BEMAnalogClockView alloc] initWithFrame:CGRectMake(0, 0, _boxView.frame.size.height*0.75, _boxView.frame.size.height*0.75)];
		_clockView.center = CGPointMake(_clockView.center.x + kArrowHeight/4, _boxView.center.y);
		_clockView.delegate = self;
		_clockView.faceBackgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
		_clockView.borderAlpha = 0.0;
		_clockView.enableShadows = YES;

		_clockView.enableHub = YES;
		_clockView.hubRadius = 2.0;

		_clockView.hourHandWidth = 2.0;
		_clockView.hourHandLength = _clockView.frame.size.height*0.3;
		_clockView.hourHandOffsideLength = 0;

		_clockView.minuteHandWidth = 2.0;
		_clockView.minuteHandLength = _clockView.frame.size.height*0.4;
		_clockView.minuteHandOffsideLength = 0;

		_clockView.secondHandAlpha = 0.0;
		//_clockView.enableGraduations = YES;
		//_clockView.secondHandAlpha = 0.0;
		[_boxView addSubview:_clockView];

		NSLog(@"_clockView.frame: %@", NSStringFromCGRect(_clockView.frame));

		//CGFloat clockOffset = _boxView.frame.origin.x + _clockView.frame.size.width + (_clockView.frame.origin.x - _boxView.frame.origin.x)*2/* + (_currentDirection == DGTFloatingTimeViewArrowDirectionRight ? (self.frame.size.width/2)/2 - kArrowHeight : (self.frame.size.width/2)/2 + kArrowHeight*2)*/;
		CGFloat clockOffset = _clockView.center.x * 2;

		_accurateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(clockOffset, _boxView.frame.origin.y, _boxView.frame.size.width - clockOffset - kArrowHeight/4, _clockView.frame.size.height/2)];
		_accurateTimeLabel.center = CGPointMake(_accurateTimeLabel.center.x, _boxView.center.y*0.75);
		_accurateTimeLabel.adjustsFontSizeToFitWidth = YES;
		_accurateTimeLabel.text = @"0 hours 0 minutes";
		_accurateTimeLabel.font = [UIFont systemFontOfSize:10];
		_accurateTimeLabel.numberOfLines = 1;
		_accurateTimeLabel.minimumScaleFactor = 0.01;
		_accurateTimeLabel.textColor = [UIColor whiteColor];
		_accurateTimeLabel.textAlignment = NSTextAlignmentLeft;
		[_boxView addSubview:_accurateTimeLabel];

		_relativeTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(clockOffset, _boxView.frame.origin.y, _boxView.frame.size.width - clockOffset - kArrowHeight/4, _clockView.frame.size.height/2)];
		_relativeTimeLabel.center = CGPointMake(_relativeTimeLabel.center.x, _boxView.center.y*1.25);
		_relativeTimeLabel.adjustsFontSizeToFitWidth = YES;
		_relativeTimeLabel.text = @"at 0:00 AM";
		_relativeTimeLabel.font = [UIFont systemFontOfSize:10];
		_relativeTimeLabel.numberOfLines = 1;
		_relativeTimeLabel.minimumScaleFactor = 0.01;
		_relativeTimeLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
		_relativeTimeLabel.textAlignment = NSTextAlignmentLeft;
		[_boxView addSubview:_relativeTimeLabel];

		self.clipsToBounds = YES;

		[self makeLayerWithDirection:direction];
	}
	return self;
}
-(CGRect)boxFrameWithDirection:(DGTFloatingTimeViewArrowDirection)direction {
	if (direction == DGTFloatingTimeViewArrowDirectionRight) {
		return CGRectMake(0, 0, self.frame.size.width - kArrowHeight, self.frame.size.height);
	}
	return CGRectMake(kArrowHeight, 0, self.frame.size.width - kArrowHeight, self.frame.size.height);
}
-(void)movedToDistanceFromOrigin:(CGFloat)distance {
	[self layoutSubviews];
	NSInteger rawSeconds = distance - [DGTConcentricRingView defaultRadius];
	if (rawSeconds < 0) {
		[self movedToDistanceFromOrigin:[DGTConcentricRingView defaultRadius]];
		return;
	}
	//1px = 5minutes
	rawSeconds *= 60 * 5;
	//keep rough proportion to scren = 24 hours
	//rawSeconds /= 2.5;

	NSInteger seconds = rawSeconds % 60; 
  	NSInteger minutes = (rawSeconds / 60) % 60; 
  	NSInteger hours = floor(rawSeconds / 3600); 

  	NSDate* eventDate = [[NSDate date] dateByAddingTimeInterval:rawSeconds];
  	NSDateComponents* eventDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:eventDate];

  	NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
  	if (eventDateComponents.hour - 12 < 10) [timeFormat setDateFormat:@"'at' h:mm a"];
  	else [timeFormat setDateFormat:@"'at' hh:mm a"];

  	_accurateTimeLabel.text = [NSString stringWithFormat:@"%i hour%@ %i minute%@", (int)hours, (hours == 1) ? @"" : @"s", (int)minutes, (minutes == 1) ? @"" : @"s"];
  	_relativeTimeLabel.text = [timeFormat stringFromDate:eventDate];

	self.clockView.hours = eventDateComponents.hour;
	self.clockView.minutes = eventDateComponents.minute;
	self.clockView.seconds = eventDateComponents.second;
	[self.clockView updateTimeAnimated:YES];
}
-(void)changeDirection:(DGTFloatingTimeViewArrowDirection)direction {
	[self makeLayerWithDirection:direction];
}
-(void)makeLayerWithDirection:(DGTFloatingTimeViewArrowDirection)direction {
	_currentDirection = direction;

	_boxView.frame = [self boxFrameWithDirection:direction];

	CAShapeLayer* arrowShapeLayer = (id)self.layer;
	arrowShapeLayer.fillColor = [UIColor colorWithWhite:0.0 alpha:0.6].CGColor;

	arrowShapeLayer.path = (direction == DGTFloatingTimeViewArrowDirectionRight ? [self rightArrowShapePath] : [self leftArrowShapePath]).CGPath;
/*
	_clockView.center = CGPointMake((_currentDirection == DGTFloatingTimeViewArrowDirectionRight ? 
								   ((self.frame.size.width/2)/2 - kArrowHeight/2) :
								   ((self.frame.size.width/2)/2 + kArrowHeight/2)),
									 self.frame.size.height/2);
*/
	//CGFloat clockOffset = _boxView.frame.origin.x + _clockView.frame.size.width + (_clockView.frame.origin.x - _boxView.frame.origin.x)*2/* + (_currentDirection == DGTFloatingTimeViewArrowDirectionRight ? (self.frame.size.width/2)/2 - kArrowHeight : (self.frame.size.width/2)/2 + kArrowHeight*2)*/;
	//_accurateTimeLabel.frame = CGRectMake(clockOffset, _accurateTimeLabel.frame.origin.y, _boxView.frame.size.width - clockOffset, _accurateTimeLabel.frame.size.height);
	//_relativeTimeLabel.frame = CGRectMake(clockOffset, _relativeTimeLabel.frame.origin.y, _boxView.frame.size.width - clockOffset, _relativeTimeLabel.frame.size.height);

	//CGSize accurateTimeLabelSize = [_accurateTimeLabel.text sizeWithFont:_accurateTimeLabel.font constrainedToSize:_accurateTimeLabel.frame.size lineBreakMode:_accurateTimeLabel.lineBreakMode];  
	//CGPoint accurateTimeLabelOrigin = CGPointMake(_boxFrame.origin.x + _clockView.frame.size.width + (_clockView.frame.origin.x - _boxFrame.origin.x)*2, 0);
	//_accurateTimeLabel.frame = CGRectMake(accurateTimeLabelOrigin.x, accurateTimeLabelOrigin.y, _accurateTimeLabel.frame.size.width, _accurateTimeLabel.frame.size.height);
	//_accurateTimeLabel.center = CGPointMake(_accurateTimeLabel.center.x, CGRectGetMidY(_boxFrame)*0.25);

	//CGSize relativeTimeLabelSize = [_relativeTimeLabel.text sizeWithFont:_relativeTimeLabel.font constrainedToSize:_relativeTimeLabel.frame.size lineBreakMode:_relativeTimeLabel.lineBreakMode];  
	//CGPoint relativeTimeLabelOrigin = CGPointMake(_boxFrame.origin.x + _clockView.frame.size.width + (_clockView.frame.origin.x - _boxFrame.origin.x)*2, 0);
	//_relativeTimeLabel.frame = CGRectMake(relativeTimeLabelOrigin.x, relativeTimeLabelOrigin.y, _relativeTimeLabel.frame.size.width, _relativeTimeLabel.frame.size.height);
	//_relativeTimeLabel.center = CGPointMake(_relativeTimeLabel.center.x, CGRectGetMidY(_boxFrame)*1.25);
/*
	NSLog(@"self.frame: %@", NSStringFromCGRect(self.frame));
	NSLog(@"_boxFrame: %@", NSStringFromCGRect(_boxFrame));
	//NSLog(@"accurateTimeLabelSize: %@", NSStringFromCGSize(accurateTimeLabelSize));
	//NSLog(@"relativeTimeLabelSize: %@", NSStringFromCGSize(relativeTimeLabelSize));
	NSLog(@"accurateTimeLabelOrigin: %@", NSStringFromCGPoint(accurateTimeLabelOrigin));
	NSLog(@"relativeTimeLabelOrigin: %@", NSStringFromCGPoint(relativeTimeLabelOrigin));
	NSLog(@"_accurateTimeLabel.frame: %@", NSStringFromCGRect(_accurateTimeLabel.frame));
	NSLog(@"_relativeTimeLabel.frame: %@", NSStringFromCGRect(_relativeTimeLabel.frame));
*/
}
-(UIBezierPath*)rightArrowShapePath {
    UIBezierPath* fillPath = [UIBezierPath bezierPath];
    CGFloat radius = 5.0;
    [fillPath moveToPoint:CGPointMake(self.frame.size.width - kArrowHeight - radius, 0)];
    [fillPath addArcWithCenter:CGPointMake(self.frame.size.width - kArrowHeight - radius, radius) radius:radius startAngle:-(M_PI/2) endAngle:(0) clockwise:YES];
    [fillPath addLineToPoint:CGPointMake(self.frame.size.width - kArrowHeight, self.frame.size.height/2 - (kArrowHeight/1.5))];
    [fillPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height/2)];
    [fillPath addLineToPoint:CGPointMake(self.frame.size.width - kArrowHeight, self.frame.size.height/2 + (kArrowHeight/1.5))];
    [fillPath addLineToPoint:CGPointMake(self.frame.size.width - kArrowHeight, self.frame.size.height - radius)];
    [fillPath addArcWithCenter:CGPointMake(self.frame.size.width - kArrowHeight - radius, self.frame.size.height - radius) radius:radius startAngle:(0) endAngle:(M_PI/2) clockwise:YES];
    [fillPath addLineToPoint:CGPointMake(radius, self.frame.size.height)];
    [fillPath addArcWithCenter:CGPointMake(radius, self.frame.size.height - radius) radius:radius startAngle:- ((M_PI * 3) / 2) endAngle:- M_PI clockwise:YES];
    [fillPath addLineToPoint:CGPointMake(0, radius)];
    [fillPath addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:- M_PI endAngle:- (M_PI / 2) clockwise:YES];
    [fillPath closePath];

    return fillPath;
}
-(UIBezierPath*)leftArrowShapePath {
	UIBezierPath *fillPath = [UIBezierPath bezierPath];
	CGFloat radius = 5.0;
    [fillPath moveToPoint:CGPointMake(self.frame.size.width - radius, 0)];
    [fillPath addArcWithCenter:CGPointMake(self.frame.size.width - radius, radius) radius:radius startAngle:-(M_PI/2) endAngle:(0) clockwise:YES];
    [fillPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height - radius)];
    [fillPath addArcWithCenter:CGPointMake(self.frame.size.width - radius, self.frame.size.height - radius) radius:radius startAngle:(0) endAngle:(M_PI/2) clockwise:YES];
    [fillPath addLineToPoint:CGPointMake(0 + kArrowHeight + radius, self.frame.size.height)];
    [fillPath addArcWithCenter:CGPointMake(0 + kArrowHeight + radius, self.frame.size.height - radius) radius:radius startAngle:- ((M_PI * 3) / 2) endAngle:- M_PI clockwise:YES];
    [fillPath addLineToPoint:CGPointMake(0 + kArrowHeight, self.frame.size.height/2 + (kArrowHeight/1.5))];
    [fillPath addLineToPoint:CGPointMake(0, self.frame.size.height/2)];
    [fillPath addLineToPoint:CGPointMake(0 + kArrowHeight, self.frame.size.height/2 - (kArrowHeight/1.5))];
    [fillPath addLineToPoint:CGPointMake(0 + kArrowHeight, radius)];
    [fillPath addArcWithCenter:CGPointMake(0 + kArrowHeight + radius, radius) radius:radius startAngle:- M_PI endAngle:- (M_PI / 2) clockwise:YES];
    [fillPath closePath];
    return fillPath;
}
#pragma mark - BEMAnalogClockDelegate
- (CGFloat)analogClock:(BEMAnalogClockView *)clock graduationLengthForIndex:(NSInteger)index {
	//if (index % 10 == 0) return 5;
	/*else*/ //if (index % 5 == 0) return 2.5;
	return 0;
}
- (CGFloat)analogClock:(BEMAnalogClockView *)clock graduationAlphaForIndex:(NSInteger)index {
	//if (index % 5 == 0) return 1;
	return 0;
}
- (CGFloat)analogClock:(BEMAnalogClockView *)clock graduationOffsetForIndex:(NSInteger)index {
	return 0;
}
@end