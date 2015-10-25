#import "DGTController.h"
#import "Interfaces.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "DGTConcentricRingView.h"
#import "DGTFloatingTimeView.h"
#import "BEMAnalogClockView.h"
#import "UIAlertView+Blocks.h"
#import <EventKit/EventKit.h>
void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID,id arg,NSDictionary* vibratePattern);

#define kBlurViewTag 1347364

@implementation DGTController
+(instancetype)sharedInstance {
	// Setup instance for current class once
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	// Provide instance
	return sharedInstance;
}
+(UIWindow*)mainDeviceView {
	//return [(FBSceneManager*)[objc_getClass("FBSceneManager") sharedInstance] _rootWindowForDisplay:(FBDisplayManager*)[objc_getClass("FBDisplayManager") mainDisplay]];
	return [[UIApplication sharedApplication] keyWindow];
}
-(instancetype)init {
	if ((self = [super init])) {
		_longPressHasBeenInvoked = NO;

		_doubleTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_doubleTapRecognized:)];
		_doubleTapRec.numberOfTapsRequired = 2;
		_doubleTapRec.delegate = self;

		_endDot = [CAShapeLayer layer];
		_endDot.fillColor = [UIColor whiteColor].CGColor;
		_endDot.strokeColor = [UIColor whiteColor].CGColor;
		_endDot.opacity = 1.0;

		_lineLayer = [CAShapeLayer layer];
		_lineLayer.fillColor = nil;
		_lineLayer.opacity = 1.0;
		_lineLayer.strokeColor = [UIColor whiteColor].CGColor;
		_lineLayer.lineCap = kCALineCapButt;
		_lineLayer.lineWidth = 3.0;

		_floatingTimeView = [[DGTFloatingTimeView alloc] initWithDefaultSizeWithDirection:DGTFloatingTimeViewArrowDirectionRight];
	}
	return self;
}
-(void)setupRecognizers {
	NSLog(@"setupRecognizers");
	[[DGTController mainDeviceView] addGestureRecognizer:_doubleTapRec];

	//_UIViewControllerPreviewSourceViewRecord *record = (_UIViewControllerPreviewSourceViewRecord *)previewer;
	//UIPreviewInteractionController *interactionController = record.previewInteractionController;
	//[interactionController startInteractivePreviewAtPosition:sourceLocation inView:record.sourceView];
	NSLog(@"mainDeviceView: %@", [DGTController mainDeviceView]);
}
-(void)_keyWindowChanged {
	//remove gesture recognizers from previous key window, and this window (if it has the gesture rec, which shouldn't happen)
	[_previousKeyWindow removeGestureRecognizer:_doubleTapRec];
	[[DGTController mainDeviceView] removeGestureRecognizer:_doubleTapRec];

	//set this to be the next previous key window
	_previousKeyWindow = [DGTController mainDeviceView];

	//setup recognizers on this view
	[self setupRecognizers];
}
-(void)_doubleTapRecognized:(UITapGestureRecognizer*)rec {
	if (rec.state == UIGestureRecognizerStateEnded) {
		NSLog(@"Double tap recognized");
		__block UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longPressRecognized:)];
		longPressRecognizer.minimumPressDuration = 0.15;
		longPressRecognizer.delegate = self;
		[[DGTController mainDeviceView] addGestureRecognizer:longPressRecognizer];

		//after 0.51s, if the long press recognizer still hasn't been recognized, remove the long press recognizer from the view
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.51 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			if (!_longPressHasBeenInvoked) {
				NSLog(@"Long press not invoked, removing gesture");

				[[DGTController mainDeviceView] removeGestureRecognizer:longPressRecognizer];
			}
		});
	}
}	
-(void)selectionViewTouchBeganWithLocation:(CGPoint)locationInView {
	//don't remove long press rec
	_longPressHasBeenInvoked = YES;

	//if device is force touch enabled, actuate pop
	if ([[UIDevice currentDevice] respondsToSelector:@selector(_tapticEngine)]) {
		UITapticEngine *tapticEngine = [UIDevice currentDevice]._tapticEngine;
		if (tapticEngine) {
			[tapticEngine actuateFeedback:UITapticEngineFeedbackPop];
		}
		else {
			typedef void* (*vibratePointer)(SystemSoundID inSystemSoundID, id arg, NSDictionary *vibratePattern);
			//vibrate
			NSMutableArray* vPattern = [NSMutableArray array];
			[vPattern addObject:[NSNumber numberWithBool:YES]];
			[vPattern addObject:[NSNumber numberWithInt:100]];
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
		[vPattern addObject:[NSNumber numberWithInt:100]];
		NSDictionary *vDict = @{ @"VibePattern" : vPattern, @"Intensity" : @1 };

		vibratePointer vibrate;
		void *handle = dlopen(0, 9);
		*(void**)(&vibrate) = dlsym(handle,"AudioServicesPlaySystemSoundWithVibration");
		vibrate(kSystemSoundID_Vibrate, nil, vDict);
	}

	//_endDot.opacity = 0.0;
	//_lineLayer.opacity = 0.0;
	_endDot.path = nil;
	_endDot.path = [UIBezierPath bezierPathWithArcCenter:locationInView radius:10 startAngle:0 endAngle:(2*M_PI) clockwise:YES].CGPath;
	_lineLayer.path = nil;
	UIBezierPath* linePath = [UIBezierPath bezierPath];
	[linePath moveToPoint:locationInView];
	_lineLayer.path = linePath.CGPath;

	//remove any blur from last time if it was not removed for some reason
	/*
	for (UIView* view in [DGTController mainDeviceView].subviews) {
		if (view.tag == kBlurViewTag) {
			[view removeFromSuperview];
		}
	}
	*/

	//add blur view
	[_backdropView removeFromSuperview];
	_backdropView = [[_UIBackdropView alloc] initWithFrame:[DGTController mainDeviceView].frame autosizesToFitSuperview:NO settings:[_UIBackdropViewSettings settingsForStyle:2]];
	_backdropView.tag = kBlurViewTag;
	_backdropView.alpha = 0.0;

	//slightly darken blur view
	UIView* darkeningView = [[UIView alloc] initWithFrame:_backdropView.frame];
	darkeningView.backgroundColor = [UIColor blackColor];
	darkeningView.alpha = 0.2;
	[_backdropView addSubview:darkeningView];

	if (![[DGTController mainDeviceView].subviews containsObject:_backdropView]) {
		[[DGTController mainDeviceView] addSubview:_backdropView];
	}

	//add floating time view
	_floatingTimeView.tag = kBlurViewTag;
	if ([UIScreen mainScreen].bounds.size.width/2 > locationInView.x) {
		//right arrow
		[_floatingTimeView changeDirection:DGTFloatingTimeViewArrowDirectionLeft];
	}
	else {
		//left arrow
		[_floatingTimeView changeDirection:DGTFloatingTimeViewArrowDirectionRight];
	}
	_floatingTimeView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width/2 > locationInView.x ? 
								  locationInView.x + kFloatingTimeViewPadding : 
								  locationInView.x - kFloatingTimeViewPadding - _floatingTimeView.frame.size.width), locationInView.y - kFloatingTimeViewPadding/2, _floatingTimeView.frame.size.width, _floatingTimeView.frame.size.height);
	_floatingTimeView.alpha = 0.0;
	_floatingTimeView.clockView.seconds = 0;
	_floatingTimeView.clockView.minutes = 0;
	_floatingTimeView.clockView.hours = 0;
	[_floatingTimeView.clockView updateTimeAnimated:NO];
	[[DGTController mainDeviceView] addSubview:_floatingTimeView];

	//fade in blur view
	[UIView animateWithDuration:0.25 animations:^{
		_backdropView.alpha = 1.0;
		_floatingTimeView.alpha = 1.0;
	} completion:^(BOOL finished){
		//spring out concentric outline
		_ringView = [[DGTConcentricRingView alloc] initWithRadius:[DGTConcentricRingView defaultRadius]];
		_ringView.tag = kBlurViewTag;
		[[DGTController mainDeviceView] addSubview:_ringView];
		//place it on the user's finger
		_ringView.center = locationInView;
		[_ringView performPresentationAnimationWithCompletion:^{
			//add animations
			[_ringView addRotationAnimation];
			[_ringView addPulseAnimation];
		}];

		//set clock to current time
		[_floatingTimeView.clockView setClockToCurrentTimeAnimated:YES];
	}];
}
-(BOOL)selectionViewIsInvoked {
	return _longPressHasBeenInvoked;
}
-(void)selectionViewTouchMovedWithLocation:(CGPoint)locationInView {
	_endDot.path = nil;
	_endDot.path = [UIBezierPath bezierPathWithArcCenter:locationInView radius:10 startAngle:0 endAngle:(2*M_PI) clockwise:YES].CGPath;
	[[DGTController mainDeviceView].layer addSublayer:_endDot];

	_lineLayer.path = nil;
	UIBezierPath *linePath=[UIBezierPath bezierPath];
	[linePath moveToPoint:locationInView];
	[linePath addLineToPoint:_ringView.center];
	_lineLayer.path=linePath.CGPath;

	[[DGTController mainDeviceView].layer addSublayer:_lineLayer];

	//add floating time view
	if ([UIScreen mainScreen].bounds.size.width/2 > locationInView.x) {
		//right arrow
		[_floatingTimeView changeDirection:DGTFloatingTimeViewArrowDirectionLeft];
	}
	else {
		//left arrow
		[_floatingTimeView changeDirection:DGTFloatingTimeViewArrowDirectionRight];
	}
	_floatingTimeView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width/2 > locationInView.x ? 
										  locationInView.x + kFloatingTimeViewPadding : 
										  locationInView.x - kFloatingTimeViewPadding - _floatingTimeView.frame.size.width), locationInView.y - kFloatingTimeViewPadding/2, _floatingTimeView.frame.size.width, _floatingTimeView.frame.size.height);

	//find distance between origin and current point
	//yay math
	//d = sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
	CGFloat distance = sqrt( pow((locationInView.x - _ringView.center.x), 2) + pow((locationInView.y - _ringView.center.y), 2) );
	[_floatingTimeView movedToDistanceFromOrigin:distance];
}
-(void)selectionViewTouchEndedWithLocation:(CGPoint)locationInView withRecognizer:(UIGestureRecognizer*)rec {
	//reset for next use
	[[DGTController mainDeviceView] removeGestureRecognizer:rec];
	_longPressHasBeenInvoked = NO;

	//make sure timer stops
	[_ringView.pulseTimer invalidate];
	_ringView.pulseTimer = nil;

	if (CGRectContainsPoint(_ringView.frame, locationInView)) {
		//they didnt move their finger outside the ring, dismiss
		[self dismissOverlay];
	}
	else {
		//show menu for alarm/reminder/whathaveyou
		[self dismissOverlay];
		//find distance between origin and current point
		//yay math
		//d = sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
		CGFloat distance = sqrt( pow((locationInView.x - _ringView.center.x), 2) + pow((locationInView.y - _ringView.center.y), 2) );
		[self displayResultPanelWithDistanceFromOrigin:distance];
	}

	_endDot.path = nil;
	_lineLayer.path = nil;
	[_endDot removeFromSuperlayer];
	[_lineLayer removeFromSuperlayer];
}
-(void)_longPressRecognized:(UILongPressGestureRecognizer*)rec {
	CGPoint locationInView = [rec locationInView:rec.view];

	switch (rec.state) {
		case UIGestureRecognizerStateBegan: {
			NSLog(@"Long press recognized");
			[self selectionViewTouchBeganWithLocation:locationInView];
			break;
		}
		case UIGestureRecognizerStateChanged: {
			[self selectionViewTouchMovedWithLocation:locationInView];
			break;
		}
		case UIGestureRecognizerStateEnded: {
		default:
			[self selectionViewTouchEndedWithLocation:locationInView withRecognizer:rec];
			break;
		}
	}
}
static char associativeObjectsKey;
#define kMainAlertViewTag 2452425
#define kReminderNameAlertViewTag 537522
#define kEventNameAlertViewTag 5345786
-(void)displayResultPanelWithDistanceFromOrigin:(CGFloat)distance {
	NSLog(@"displayResultPanelWithDistanceFromOrigin: %f", distance);
	_distance = distance - [DGTConcentricRingView defaultRadius];
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Alarm", @"Reminder", @"Calendar Event", nil];
	alertView.tag = kMainAlertViewTag;
	[alertView show];
}
-(void)mainAlertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSInteger rawSeconds = _distance;
	//1px = 5minutes
	rawSeconds *= 60 * 5;
	//keep rough proportion to scren = 24 hours
	//rawSeconds /= 2.5;

	NSInteger seconds = rawSeconds % 60; 
	NSInteger minutes = (rawSeconds / 60) % 60; 
	NSInteger hours = floor(rawSeconds / 3600); 

	NSLog(@"Absolute time: %i:%i:%i", hours, minutes, seconds);

	NSTimeInterval interval = rawSeconds;
	NSDate* relativeDate = [NSDate dateWithTimeIntervalSinceNow:interval];
	//convert to the user's time zone
	//NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
	//relativeDate = [relativeDate dateByAddingTimeInterval:timeZoneSeconds];

	NSLog(@"Relative time: %@", relativeDate);

	if (buttonIndex == [alertView cancelButtonIndex]) {
		NSLog(@"Cancelled");
		return;
	} 

	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:relativeDate];
	if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Alarm"]) {
		[self createAlarmWithDateComponents:dateComponents];
	} 
	else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Reminder"]) {
		[self createReminderWithDateComponents:dateComponents];
	}
	else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Calendar Event"]) {
		[self createEventWithDateComponents:dateComponents];
	}
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == kMainAlertViewTag) {
		[self mainAlertView:alertView clickedButtonAtIndex:buttonIndex];
	}
	else if (alertView.tag == kReminderNameAlertViewTag) {
		[self _createReminderWithAlert:alertView name:[[alertView textFieldAtIndex:0] text]];
	}
	else if (alertView.tag == kEventNameAlertViewTag) {
		[self _createEventWithAlert:alertView name:[[alertView textFieldAtIndex:0] text]];
	}
}
- (void)didPresentAlertView:(UIAlertView *)alertView {
    UITextField *nameField = [alertView textFieldAtIndex:0];
    [nameField becomeFirstResponder];
}
-(void)_createReminderWithAlert:(UIAlertView*)alertView name:(NSString*)name {
	NSDateComponents* dateComponents = objc_getAssociatedObject(alertView, &associativeObjectsKey);
	EKEventStore* store = [[EKEventStore alloc] init];
	[store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
		if (granted) {
			EKReminder *reminder = [EKReminder reminderWithEventStore:store];
			[reminder setTitle:name];
			[reminder setCalendar:[store defaultCalendarForNewReminders]];
			reminder.dueDateComponents = dateComponents;
			[reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:[[NSCalendar currentCalendar] dateFromComponents:dateComponents]]];

			NSError *error = nil;
			BOOL success = [store saveReminder:reminder commit:YES error:&error];
			if (!success) {
				[[[UIAlertView alloc] initWithTitle:@"Could not create reminder" message:[NSString stringWithFormat:@"We could not create your reminder:\n%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
			}
		}
		else {
			[[[UIAlertView alloc] initWithTitle:@"Could not create reminder" message:@"Please allow Springboard access to Reminders in Settings." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
		}
	}];
}
-(void)_createEventWithAlert:(UIAlertView*)alertView name:(NSString*)name {
	NSDateComponents* dateComponents = objc_getAssociatedObject(alertView, &associativeObjectsKey);
	EKEventStore* store = [[EKEventStore alloc] init];
	[store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
		if (granted) {
			EKEvent *event = [EKEvent eventWithEventStore:store];
			[event setTitle:name];
			[event setCalendar:[store defaultCalendarForNewEvents]];
			NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
			event.startDate = date;
			event.endDate = date;
			[event addAlarm:[EKAlarm alarmWithAbsoluteDate:date]];

			NSError *error = nil;
			BOOL success = [store saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
			if (!success) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[[[UIAlertView alloc] initWithTitle:@"Could not create calendar event" message:[NSString stringWithFormat:@"We could not create your calendar event:\n%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
				});
			}
		}
		else {
			[[[UIAlertView alloc] initWithTitle:@"Could not create calendar event" message:@"Please allow Springboard access to Calendar in Settings." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
		}
	}];
}
-(void)createAlarmWithDateComponents:(NSDateComponents*)dateComponents {
	Alarm* alarm = [[objc_getClass("Alarm") alloc] initWithDefaultValues];
	alarm.title = @"Alarm";
	alarm.hour = dateComponents.hour;
	alarm.minute = dateComponents.minute;
	[[objc_getClass("AlarmManager") sharedManager] loadAlarms];
	[[objc_getClass("AlarmManager") sharedManager] addAlarm:alarm active:YES];
}
-(void)createReminderWithDateComponents:(NSDateComponents*)dateComponents {
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Enter a name for this reminder" message:nil delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
	alertView.tag = kReminderNameAlertViewTag;
	objc_setAssociatedObject(alertView, &associativeObjectsKey, dateComponents, OBJC_ASSOCIATION_RETAIN);
	[alertView addTextFieldWithValue:@""label:@"Reminder Name"]; 
	// Customise name field 
	UITextField* name = [alertView textFieldAtIndex:0]; 
	name.autocorrectionType = UITextAutocorrectionTypeYes;
	name.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	name.enablesReturnKeyAutomatically = YES;
	name.clearButtonMode = UITextFieldViewModeWhileEditing; 
	name.keyboardType = UIKeyboardTypeAlphabet; 
	name.keyboardAppearance = UIKeyboardAppearanceAlert; 
	[alertView show];
}
-(void)createEventWithDateComponents:(NSDateComponents*)dateComponents {
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Enter a name for this calendar event" message:nil delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
	alertView.tag = kEventNameAlertViewTag;
	objc_setAssociatedObject(alertView, &associativeObjectsKey, dateComponents, OBJC_ASSOCIATION_RETAIN);
	[alertView addTextFieldWithValue:@""label:@"EventName"]; 

	// Customise name field 
	UITextField* name = [alertView textFieldAtIndex:0]; 
	name.autocorrectionType = UITextAutocorrectionTypeYes;
	name.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	name.enablesReturnKeyAutomatically = YES;
	name.clearButtonMode = UITextFieldViewModeWhileEditing; 
	name.keyboardType = UIKeyboardTypeAlphabet; 
	name.keyboardAppearance = UIKeyboardAppearanceAlert; 
	[alertView show];
}
-(void)dismissOverlay {
	//fade out blur view
	[UIView animateWithDuration:0.25 animations:^{
		for (UIView* view in [DGTController mainDeviceView].subviews) {
			if (view.tag == kBlurViewTag) {
				view.alpha = 0.0;
			}
		}
		_lineLayer.opacity = 0.0;
		_endDot.opacity = 0.0;
	} completion:^(BOOL finished){
		//remove blur view from main device view
		//_UIBackdropView does funky stuff if we don't wait a bit after the animation to remove it
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			for (UIView* view in [DGTController mainDeviceView].subviews) {
				if (view.tag == kBlurViewTag) {
					[view removeFromSuperview];
				}
			}
			[_lineLayer removeFromSuperlayer];
			//reset for next use
			_endDot.path = nil;
			_endDot.opacity = 1.0;
			_lineLayer.path = nil;
			_lineLayer.opacity = 1.0;
		});
	}];
}
@end
