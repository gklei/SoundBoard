//
//  NextKeyboardController.m
//  SoundBoard
//
//  Created by Klein, Greg on 1/23/15.
//  Copyright (c) 2015 Pure Virtual Studios, LLC. All rights reserved.
//

#import "NextKeyboardKeyController.h"
#import "LetterView.h"

@interface NextKeyboardKeyController ()
@property (nonatomic) LetterView* nextKeyboardKeyView;
@end

@implementation NextKeyboardKeyController

#pragma mark - Setup
- (void)setupLetterViews
{
   self.nextKeyboardKeyView = [LetterView viewWithLetter:@"next" fontSize:14.f frame:CGRectZero];
   self.letterViewArray = @[self.nextKeyboardKeyView];
   [self.view addSubview:self.nextKeyboardKeyView];
}

@end