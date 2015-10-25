#define kTweakName @"Tether"
#ifdef DEBUG
    #define NSLog(FORMAT, ...) NSLog(@"[%@: %s - %i] %@", kTweakName, __FILE__, __LINE__, [NSString stringWithFormat:FORMAT, ##__VA_ARGS__])
#else
    #define NSLog(FORMAT, ...) do {} while(0)
#endif

#include <dlfcn.h>

@interface _UIBackdropViewSettings : NSObject
+(id)settingsForStyle:(NSInteger)style graphicsQuality:(NSInteger)quality;
+(id)settingsForStyle:(NSInteger)style;
@end
@interface _UIBackdropView : UIView
-(id)initWithFrame:(CGRect)frame autosizesToFitSuperview:(BOOL)autoresizes settings:(_UIBackdropViewSettings*)settings;
@end
@interface FBDisplayManager : NSObject
+(id)mainDisplay;
@end
@interface FBSceneManager : NSObject
+(id)sharedInstance;
-(UIView*)_rootWindowForDisplay:(FBDisplayManager*)display;
@end
@interface UIPreviewForceInteractionProgress : NSObject
- (void)endInteraction:(BOOL)arg1;
@end
@interface UIPreviewInteractionController : NSObject
@property (nonatomic, readonly) UIPreviewForceInteractionProgress *interactionProgressForPresentation;
- (BOOL)startInteractivePreviewAtPosition:(CGPoint)point inView:(UIView *)view;
- (void)cancelInteractivePreview;
- (void)commitInteractivePreview;
@end
@interface _UIViewControllerPreviewSourceViewRecord : NSObject <UIViewControllerPreviewing>
@property (nonatomic, readonly) UIPreviewInteractionController *previewInteractionController;
@end
@interface SBIconViewMap : NSObject
-(id)mappedIconViewForIcon:(id)icon;
@end
@interface UITouch (Private)
@property (nonatomic, readonly) float _pressure;
@end
@interface SBHomeScreenWindow : UIWindow
- (id)_initWithScreen:(id)arg1 layoutStrategy:(id)arg2 debugName:(id)arg3 rootViewController:(id)arg4 scene:(id)arg5;
@end
@interface SBIconScrollView : UIScrollView
@end
static int const UITapticEngineFeedbackPeek = 1001;
static int const UITapticEngineFeedbackPop = 1002;
@interface UITapticEngine : NSObject
- (void)actuateFeedback:(int)arg1;
- (void)endUsingFeedback:(int)arg1;
- (void)prepareUsingFeedback:(int)arg1;
@end
@interface UIDevice (Private)
-(UITapticEngine*)_tapticEngine;
@end
@interface UIAlertView (Private)
-(id)addTextFieldWithValue:(id)value label:(id)label;
@end
@interface Alarm : NSObject
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, retain) NSString* title;
-(id)initWithDefaultValues;
@end
@interface AlarmManager : NSObject
+(id)sharedManager;
-(void)loadAlarms;
-(void)addAlarm:(Alarm*)alarm active:(BOOL)active;
@end
#import <AudioToolbox/AudioToolbox.h>
void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID,id arg,NSDictionary* vibratePattern);
