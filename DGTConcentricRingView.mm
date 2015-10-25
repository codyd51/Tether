#import "DGTConcentricRingView.h"
#import "Interfaces.h"

@implementation DGTConcentricRingView
+(CGFloat)defaultRadius {
	//if the phone is landscape, -width and -height will be switched
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	CGFloat width = fmin(screenSize.width, screenSize.height);
	return width/9;
}
+ (Class)layerClass {
    return [CAShapeLayer class];
}
-(instancetype)initWithLineParts:(NSInteger)lineParts {
	return [self initWithRadius:[DGTConcentricRingView defaultRadius] withLineParts:lineParts withColor:[UIColor whiteColor]];
}
-(instancetype)initWithRadius:(CGFloat)radius {
	return [self initWithRadius:radius withLineParts:1 withColor:[UIColor whiteColor]];
}
-(instancetype)initWithRadius:(CGFloat)radius withLineParts:(NSInteger)lineParts {
	return [self initWithRadius:radius withLineParts:1 withColor:[UIColor whiteColor]];
}
-(instancetype)initWithRadius:(CGFloat)radius withLineParts:(NSInteger)lineParts withColor:(UIColor*)color {
	if ((self = [super initWithFrame:CGRectMake(0, 0, radius*2, radius*2)])) {
		//if they pass less than 1 line part, throw up and die
		if (lineParts < 1) {
			[NSException raise:@"Invalid number of line parts" format:@"A DGTConcentricRingView must be made up of at least one line (passed %i)", (int)lineParts];
		}

		_radius = radius;
		_color = color;

		CAShapeLayer *layer = (id)self.layer;
	    layer.lineWidth = 1.5;

	    UIBezierPath* path = [UIBezierPath bezierPath];
	    [path addArcWithCenter:self.center radius:_radius startAngle:0 endAngle:(2 * M_PI) clockwise:YES];
/*
	    //add squiggles
	    //random # of squiggles
	    NSInteger lowerBound = 2;
		NSInteger upperBound = 20;
		//random value between these two
		//dividing these by 2 then multiplying by 2 ensures evenness
		NSInteger randomSquigglesAmount = (arc4random_uniform(upperBound/2) + lowerBound/2) * 2;
		CGFloat outValue = 10.0;
		for (int i = 0; i <= randomSquigglesAmount; i++) {
			CGPoint left = CGPointMake(self.center.x + _radius * cos((2*M_PI * (i == 0 ? randomSquigglesAmount : i-1)/randomSquigglesAmount) - M_PI_2), self.center.y + _radius * sin((2*M_PI * (i == 0 ? randomSquigglesAmount : i-1)/randomSquigglesAmount) - M_PI_2));
			CGPoint outPoint = CGPointMake(self.center.x + _radius + outValue * cos((2*M_PI * i/randomSquigglesAmount) - M_PI_2), self.center.y + _radius + outValue * sin((2*M_PI * i/randomSquigglesAmount) - M_PI_2));
			CGPoint right = CGPointMake(self.center.x + _radius * cos((2*M_PI * (i == randomSquigglesAmount ? 0 : i+1)/randomSquigglesAmount) - M_PI_2), self.center.y + _radius * sin((2*M_PI * (i == randomSquigglesAmount ? 0 : i+1)/randomSquigglesAmount) - M_PI_2));
			[path moveToPoint:left];

			[path addQuadCurveToPoint:outPoint controlPoint:right];
		}
*/
	    layer.path = path.CGPath;
	    layer.strokeColor = _color.CGColor;
	    layer.fillColor = NULL;
	    //layer.contentsScale = [UIScreen mainScreen].scale;
	    layer.shouldRasterize = NO;

	    //add small circle from which tracking line expands
		CAShapeLayer *originDot = [CAShapeLayer layer];
		[originDot setPath:[[UIBezierPath bezierPathWithArcCenter:self.center radius:2.5 startAngle:0 endAngle:(2*M_PI) clockwise:YES] CGPath]];
		originDot.fillColor = [UIColor whiteColor].CGColor;
		originDot.strokeColor = [UIColor whiteColor].CGColor;
		[self.layer addSublayer:originDot];

	    self.userInteractionEnabled = NO;
	}
	return self;
}
/*
- (void)drawRect:(CGRect)rect {
	NSLog(@"rect: %@", NSStringFromCGRect(rect));
	NSLog(@"self: %@", self);
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	[bezierPath addArcWithCenter:self.center radius:_radius startAngle:0 endAngle:(2 * M_PI) clockwise:YES];
	[_color setStroke];
	[bezierPath stroke];
	[super drawRect:rect];

    [[UIColor redColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);

    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), NULL);
    [_color setStroke];
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1);
    [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 4, 4)] stroke];
}
*/
-(void)addRotationAnimation {
	NSLog(@"self: %@", self);
	[self _doRotateAnimation];
}
-(void)_doRotateAnimation {
	//NSLog(@"self: %@", self);
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setTransform:CGAffineTransformRotate(self.transform, M_PI_2)];
    }completion:^(BOOL finished){
        if (finished) {
            [self _doRotateAnimation];
        }
    }];
}
-(void)addPulseAnimation {
	NSLog(@"self: %@", self);
	CGFloat animationDuration = 0.1875;
	self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:animationDuration target:self selector:@selector(pulseTimerFired) userInfo:nil repeats:YES];
	//[pulseTimer fire];

	CABasicAnimation* pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	pulseAnimation.duration = 0.75;
	pulseAnimation.repeatCount = HUGE_VALF;
	pulseAnimation.autoreverses = YES;
	pulseAnimation.fromValue=[NSNumber numberWithFloat:1.15];
	pulseAnimation.toValue=[NSNumber numberWithFloat:1.0];
	pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

	[CATransaction setCompletionBlock:^{
		[self.pulseTimer invalidate];
		self.pulseTimer = nil;
	}];
	[self.layer addAnimation:pulseAnimation forKey:@"scale"];
}
-(void)pulseTimerFired {
	NSLog(@"pulseTimerFired");
	if (!self.pulseTimer || ![self.pulseTimer isValid]) return;
	//if device is force touch enabled, actuate peek
	if ([[UIDevice currentDevice] respondsToSelector:@selector(_tapticEngine)]) {
		UITapticEngine *tapticEngine = [UIDevice currentDevice]._tapticEngine;
		if (tapticEngine) {
			[tapticEngine actuateFeedback:UITapticEngineFeedbackPeek];
		}
		else {
			//vibrate
			//function no longer available as of iOS9, have to look it up at runtime
			typedef void* (*vibratePointer)(SystemSoundID inSystemSoundID, id arg, NSDictionary *vibratePattern);
			NSMutableArray* vPattern = [NSMutableArray array];
			[vPattern addObject:[NSNumber numberWithBool:YES]];
			[vPattern addObject:[NSNumber numberWithInt:25]];
			NSDictionary *vDict = @{ @"VibePattern" : vPattern, @"Intensity" : @1 };

			vibratePointer vibrate;
			void *handle = dlopen(0, 9);
			*(void**)(&vibrate) = dlsym(handle,"AudioServicesPlaySystemSoundWithVibration");
			vibrate(kSystemSoundID_Vibrate, nil, vDict);
		}
	}
	else {
		typedef void* (*vibratePointer)(SystemSoundID inSystemSoundID, id arg, NSDictionary *vibratePattern);
		//vibrate
		NSMutableArray* vPattern = [NSMutableArray array];
		[vPattern addObject:[NSNumber numberWithBool:YES]];
		[vPattern addObject:[NSNumber numberWithInt:25]];
		NSDictionary *vDict = @{ @"VibePattern" : vPattern, @"Intensity" : @1 };

		vibratePointer vibrate;
		void *handle = dlopen(0, 9);
		*(void**)(&vibrate) = dlsym(handle,"AudioServicesPlaySystemSoundWithVibration");
		vibrate(kSystemSoundID_Vibrate, nil, vDict);
	}

}
-(void)performPresentationAnimationWithCompletion:(void(^)(void))completion {
	NSLog(@"self: %@", self);

	self.transform = CGAffineTransformMakeScale(0.01, 0.01);
	//[UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:nil animations:^{
	[UIView animateWithDuration:0.5 animations:^{
		self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.15, 1.15);
	} completion:^(BOOL finished){
		//if (finished) {
			completion();
		//}
	}];
}
@end
