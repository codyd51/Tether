@interface DGTConcentricRingView : UIView {
	CGFloat _radius;
	UIColor* _color;
}
@property (nonatomic, retain) NSTimer* pulseTimer;
+(CGFloat)defaultRadius;
-(instancetype)initWithLineParts:(NSInteger)lineParts;
-(instancetype)initWithRadius:(CGFloat)radius;
-(instancetype)initWithRadius:(CGFloat)radius withLineParts:(NSInteger)lineParts;
-(instancetype)initWithRadius:(CGFloat)radius withLineParts:(NSInteger)lineParts withColor:(UIColor*)color NS_DESIGNATED_INITIALIZER;
-(void)performPresentationAnimationWithCompletion:(void(^)(void))completion;
-(void)addPulseAnimation;
-(void)addRotationAnimation;
@end
