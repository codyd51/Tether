#import <objc/runtime.h>
#import "DGTController.h"
#import "Interfaces.h"

static void loadPreferences() {
    CFPreferencesAppSynchronize(CFSTR("com.phillipt.dragthingy"));

    //enabled = [(id)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.phillipt.dragthingy")) boolValue];
}
/*
%hook SBIconController
- (void)_handleShortcutMenuPeek:(id)arg1 {
    %log;
    %orig;
}
%end
*/
%hook SBHomeScreenWindow
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGFloat pressure = MSHookIvar<CGFloat>(touch, "_previousPressure");

    CGPoint convertedPoint = [self convertPoint:[touch locationInView:self] toView:((SBIconController*)[%c(SBIconController) sharedInstance]).contentView];

    if ([[DGTController sharedInstance] selectionViewIsInvoked]) {
        [[DGTController sharedInstance] selectionViewTouchMovedWithLocation:convertedPoint];
        return;
    }

    //TODO adjust to user's 3DTouch setting
    if (pressure > 300) {
        NSLog(@"user force touched with pressure: %f", pressure);
        
        [[DGTController sharedInstance] selectionViewTouchBeganWithLocation:convertedPoint];
        return;
    }
    %orig;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[DGTController sharedInstance] selectionViewIsInvoked]) {
        UITouch* touch = [touches anyObject];
        CGPoint convertedPoint = [self convertPoint:[touch locationInView:self] toView:((SBIconController*)[%c(SBIconController) sharedInstance]).contentView];
        [[DGTController sharedInstance] selectionViewTouchEndedWithLocation:convertedPoint withRecognizer:nil];
    }
}
/*
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[DGTController sharedInstance] selectionViewIsInvoked]) {
        UITouch* touch = [touches anyObject];
        [[DGTController sharedInstance] selectionViewTouchEndedWithLocation:[touch locationInView:self] withRecognizer:nil];
    }
}
*/
%end
%hook SBIconScrollView
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGFloat pressure = MSHookIvar<CGFloat>(touch, "_previousPressure");

    CGPoint convertedPoint = [self convertPoint:[touch locationInView:self] toView:((SBIconController*)[%c(SBIconController) sharedInstance]).contentView];

    if ([[DGTController sharedInstance] selectionViewIsInvoked]) {
        [[DGTController sharedInstance] selectionViewTouchMovedWithLocation:convertedPoint];

        //steal touch from scroll view
        self.panGestureRecognizer.enabled = NO;
        self.panGestureRecognizer.enabled = YES;

        //steal touch from spotlight pan gesture recognizer
        //find spotlight pan gesture recognizer
        for (UIGestureRecognizer* rec in self.gestureRecognizers) {
            NSArray* targets = MSHookIvar<NSArray*>(rec, "_targets");
            if (targets.count > 0) {
                id target = MSHookIvar<id>(targets[0], "_target");
                if ([target isKindOfClass:%c(SBSearchScrollView)]) {
                    ((UIScrollView*)target).panGestureRecognizer.enabled = NO;
                    ((UIScrollView*)target).panGestureRecognizer.enabled = YES;
                }
            }
        }
        return;
    }

    //TODO adjust to user's 3DTouch setting
    if (pressure > 500) {
        NSLog(@"user force touched with pressure: %f", pressure);
        [[DGTController sharedInstance] selectionViewTouchBeganWithLocation:convertedPoint];
        return;
    }
    %orig;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[DGTController sharedInstance] selectionViewIsInvoked]) {
        UITouch* touch = [touches anyObject];
        CGPoint convertedPoint = [self convertPoint:[touch locationInView:self] toView:((SBIconController*)[%c(SBIconController) sharedInstance]).contentView];
        [[DGTController sharedInstance] selectionViewTouchEndedWithLocation:convertedPoint withRecognizer:nil];
    }
}
/*
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[DGTController sharedInstance] selectionViewIsInvoked]) {
        UITouch* touch = [touches anyObject];
        [[DGTController sharedInstance] selectionViewTouchEndedWithLocation:[touch locationInView:self] withRecognizer:nil];
    }
}
*/
%end

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                (CFNotificationCallback)loadPreferences,
                                CFSTR("com.phillipt.dragthingy/prefsChanged"),
                                NULL,
                                CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPreferences();

    //[[NSNotificationCenter defaultCenter] addObserver:[DGTController sharedInstance] selector:@selector(_keyWindowChanged) name:UIWindowDidBecomeKeyNotification object:nil];
}