//
//  UIAlertView+Blocks.m
//  UIAlertViewBlocks
//
//  Created by Ryan Maxwell on 29/08/13.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Ryan Maxwell
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "UIAlertView+Blocks.h"

#import <objc/runtime.h>

static const void *UIAlertViewOriginalDelegateKey                   = &UIAlertViewOriginalDelegateKey;

static const void *UIAlertViewTapBlockKey                           = &UIAlertViewTapBlockKey;
static const void *UIAlertViewWillPresentBlockKey                   = &UIAlertViewWillPresentBlockKey;
static const void *UIAlertViewDidPresentBlockKey                    = &UIAlertViewDidPresentBlockKey;
static const void *UIAlertViewWillDismissBlockKey                   = &UIAlertViewWillDismissBlockKey;
static const void *UIAlertViewDidDismissBlockKey                    = &UIAlertViewDidDismissBlockKey;
static const void *UIAlertViewCancelBlockKey                        = &UIAlertViewCancelBlockKey;
static const void *UIAlertViewShouldEnableFirstOtherButtonBlockKey  = &UIAlertViewShouldEnableFirstOtherButtonBlockKey;

@implementation UIAlertView (DGTBlocks)

+ (instancetype)dgt_showWithTitle:(NSString *)title
                      message:(NSString *)message
                        style:(UIAlertViewStyle)style
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
                     tapBlock:(DGTUIAlertViewCompletionBlock)dgt_tapBlock {
    
    NSString *firstObject = otherButtonTitles.count ? otherButtonTitles[0] : nil;
    
    UIAlertView *alertView = [[self alloc] initWithTitle:title
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:cancelButtonTitle
                                       otherButtonTitles:firstObject, nil];
    
    alertView.alertViewStyle = style;
    
    if (otherButtonTitles.count > 1) {
        for (NSString *buttonTitle in [otherButtonTitles subarrayWithRange:NSMakeRange(1, otherButtonTitles.count - 1)]) {
            [alertView addButtonWithTitle:buttonTitle];
        }
    }
    
    if (dgt_tapBlock) {
        alertView.dgt_tapBlock = dgt_tapBlock;
    }
    
    [alertView show];
    
#if !__has_feature(objc_arc)
    return [alertView autorelease];
#else
    return alertView;
#endif
}


+ (instancetype)dgt_showWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
                     tapBlock:(DGTUIAlertViewCompletionBlock)dgt_tapBlock {
    
    return [self dgt_showWithTitle:title
                       message:message
                         style:UIAlertViewStyleDefault
             cancelButtonTitle:cancelButtonTitle
             otherButtonTitles:otherButtonTitles
                      tapBlock:dgt_tapBlock];
}

#pragma mark -

- (void)_dgt_checkAlertViewDelegate {
    if (self.delegate != (id<UIAlertViewDelegate>)self) {
        objc_setAssociatedObject(self, UIAlertViewOriginalDelegateKey, self.delegate, OBJC_ASSOCIATION_ASSIGN);
        self.delegate = (id<UIAlertViewDelegate>)self;
    }
}

- (DGTUIAlertViewCompletionBlock)dgt_tapBlock {
    return objc_getAssociatedObject(self, UIAlertViewTapBlockKey);
}

- (void)setDgt_tapBlock:(DGTUIAlertViewCompletionBlock)dgt_tapBlock {
    [self _dgt_checkAlertViewDelegate];
    objc_setAssociatedObject(self, UIAlertViewTapBlockKey, dgt_tapBlock, OBJC_ASSOCIATION_COPY);
}

- (DGTUIAlertViewCompletionBlock)dgt_willDismissBlock {
    return objc_getAssociatedObject(self, UIAlertViewWillDismissBlockKey);
}

- (void)setDgt_willDismissBlock:(DGTUIAlertViewCompletionBlock)willDismissBlock {
    [self _dgt_checkAlertViewDelegate];
    objc_setAssociatedObject(self, UIAlertViewWillDismissBlockKey, willDismissBlock, OBJC_ASSOCIATION_COPY);
}

- (DGTUIAlertViewCompletionBlock)dgt_didDismissBlock {
    return objc_getAssociatedObject(self, UIAlertViewDidDismissBlockKey);
}

- (void)setDgt_cidDismissBlock:(DGTUIAlertViewCompletionBlock)didDismissBlock {
    [self _dgt_checkAlertViewDelegate];
    objc_setAssociatedObject(self, UIAlertViewDidDismissBlockKey, didDismissBlock, OBJC_ASSOCIATION_COPY);
}

- (DGTUIAlertViewBlock)dgt_willPresentBlock {
    return objc_getAssociatedObject(self, UIAlertViewWillPresentBlockKey);
}

- (void)setDgt_willPresentBlock:(DGTUIAlertViewBlock)willPresentBlock {
    [self _dgt_checkAlertViewDelegate];
    objc_setAssociatedObject(self, UIAlertViewWillPresentBlockKey, willPresentBlock, OBJC_ASSOCIATION_COPY);
}

- (DGTUIAlertViewBlock)dgt_didPresentBlock {
    return objc_getAssociatedObject(self, UIAlertViewDidPresentBlockKey);
}

- (void)setDgt_cidPresentBlock:(DGTUIAlertViewBlock)didPresentBlock {
    [self _dgt_checkAlertViewDelegate];
    objc_setAssociatedObject(self, UIAlertViewDidPresentBlockKey, didPresentBlock, OBJC_ASSOCIATION_COPY);
}

- (DGTUIAlertViewBlock)dgt_cancelBlock {
    return objc_getAssociatedObject(self, UIAlertViewCancelBlockKey);
}

- (void)setDgt_cancelBlock:(DGTUIAlertViewBlock)cancelBlock {
    [self _dgt_checkAlertViewDelegate];
    objc_setAssociatedObject(self, UIAlertViewCancelBlockKey, cancelBlock, OBJC_ASSOCIATION_COPY);
}

- (void)setDgt_shouldEnableFirstOtherButtonBlock:(BOOL(^)(UIAlertView *alertView))shouldEnableFirstOtherButtonBlock {
    [self _dgt_checkAlertViewDelegate];
    objc_setAssociatedObject(self, UIAlertViewShouldEnableFirstOtherButtonBlockKey, shouldEnableFirstOtherButtonBlock, OBJC_ASSOCIATION_COPY);
}

- (BOOL(^)(UIAlertView *alertView))dgt_shouldEnableFirstOtherButtonBlock {
    return objc_getAssociatedObject(self, UIAlertViewShouldEnableFirstOtherButtonBlockKey);
}

#pragma mark - UIAlertViewDelegate

- (void)willPresentAlertView:(UIAlertView *)alertView {
    DGTUIAlertViewBlock block = alertView.dgt_willPresentBlock;
    
    if (block) {
        block(alertView);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [originalDelegate willPresentAlertView:alertView];
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    DGTUIAlertViewBlock block = alertView.dgt_didPresentBlock;
    
    if (block) {
        block(alertView);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [originalDelegate didPresentAlertView:alertView];
    }
}


- (void)alertViewCancel:(UIAlertView *)alertView {
    DGTUIAlertViewBlock block = alertView.dgt_cancelBlock;
    
    if (block) {
        block(alertView);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(alertViewCancel:)]) {
        [originalDelegate alertViewCancel:alertView];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DGTUIAlertViewCompletionBlock completion = alertView.dgt_tapBlock;
    
    if (completion) {
        completion(alertView, buttonIndex);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [originalDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    DGTUIAlertViewCompletionBlock completion = alertView.dgt_willDismissBlock;
    
    if (completion) {
        completion(alertView, buttonIndex);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
        [originalDelegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    DGTUIAlertViewCompletionBlock completion = alertView.dgt_didDismissBlock;
    
    if (completion) {
        completion(alertView, buttonIndex);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
        [originalDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    BOOL(^shouldEnableFirstOtherButtonBlock)(UIAlertView *alertView) = alertView.dgt_shouldEnableFirstOtherButtonBlock;
    
    if (shouldEnableFirstOtherButtonBlock) {
        return shouldEnableFirstOtherButtonBlock(alertView);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)]) {
        return [originalDelegate alertViewShouldEnableFirstOtherButton:alertView];
    }
    
    return YES;
}

@end
