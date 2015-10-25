//
//  UIAlertView+Blocks.h
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

#import <UIKit/UIKit.h>

typedef void (^DGTUIAlertViewBlock) (UIAlertView * __nonnull alertView);
typedef void (^DGTUIAlertViewCompletionBlock) (UIAlertView * __nonnull alertView, NSInteger buttonIndex);

@interface UIAlertView (DGTBlocks)

+ (nonnull instancetype)dgt_showWithTitle:(nullable NSString *)title
                              message:(nullable NSString *)message
                                style:(UIAlertViewStyle)style
                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                    otherButtonTitles:(nullable NSArray *)otherButtonTitles
                             tapBlock:(nullable DGTUIAlertViewCompletionBlock)tapBlock;

+ (nonnull instancetype)dgt_showWithTitle:(nullable NSString *)title
                              message:(nullable NSString *)message
                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                    otherButtonTitles:(nullable NSArray *)otherButtonTitles
                             tapBlock:(nullable DGTUIAlertViewCompletionBlock)tapBlock;

@property (copy, nonatomic, nullable) DGTUIAlertViewCompletionBlock dgt_tapBlock;
@property (copy, nonatomic, nullable) DGTUIAlertViewCompletionBlock dgt_willDismissBlock;
@property (copy, nonatomic, nullable) DGTUIAlertViewCompletionBlock dgt_didDismissBlock;

@property (copy, nonatomic, nullable) DGTUIAlertViewBlock dgt_willPresentBlock;
@property (copy, nonatomic, nullable) DGTUIAlertViewBlock dgt_didPresentBlock;
@property (copy, nonatomic, nullable) DGTUIAlertViewBlock dgt_cancelBlock;

@property (copy, nonatomic, nullable) BOOL(^dgt_shouldEnableFirstOtherButtonBlock)(UIAlertView * __nonnull alertView);

@end
