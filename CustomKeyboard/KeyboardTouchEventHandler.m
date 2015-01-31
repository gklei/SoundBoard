//
//  KeyboardTouchEventHandler.m
//  SoundBoard
//
//  Created by Klein, Greg on 1/26/15.
//  Copyright (c) 2015 Pure Virtual Studios, LLC. All rights reserved.
//

#import "KeyboardTouchEventHandler.h"
#import "KeyboardKeyFrameTextMap.h"
#import "KeyView.h"
#import "TextDocumentProxyManager.h"
#import "EnlargedKeyDrawingView.h"

@interface KeyboardTouchEventHandler ()

@property (nonatomic) EnlargedKeyDrawingView* view;
@property (nonatomic) KeyView* currentFocusedKeyView;
@property (nonatomic) KeyboardKeyFrameTextMap* keyFrameTextMap;
@property (nonatomic) UITouch* currentActiveTouch;

@end

@implementation KeyboardTouchEventHandler

#pragma mark - Init
- (instancetype)init
{
   if (self = [super init])
   {
      self.view = [EnlargedKeyDrawingView drawingViewWithFrame:self.view.bounds];
      self.view.multipleTouchEnabled = YES;
   }
   return self;
}

#pragma mark - Class Init
+ (instancetype)handler
{
   return [[[self class] alloc] init];
}

#pragma mark - Touch Events
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
   if (self.currentActiveTouch == nil)
   {
      [self handleTouch:touches.anyObject onTouchDown:YES];
   }
   else
   {
      [self handleTouch:self.currentActiveTouch onTouchDown:NO];
   }
   self.currentActiveTouch = touches.anyObject;
   KeyView* keyView = [self.keyFrameTextMap keyViewAtPoint:[self.currentActiveTouch locationInView:nil]];
   [self.view drawEnlargedKeyView:keyView withFrame:keyView.frame];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
   if (self.currentActiveTouch == touches.anyObject)
   {
      [self handleTouch:self.currentActiveTouch onTouchDown:NO];
      self.currentActiveTouch = nil;
   }
}

#pragma mark - Helper
- (void)handleTouch:(UITouch*)touch onTouchDown:(BOOL)touchDown
{
   if (touch != nil)
   {
      CGPoint touchLocation = [touch locationInView:nil];
      KeyView* targetKeyView = [self.keyFrameTextMap keyViewAtPoint:touchLocation];

      BOOL shouldTrigger = touchDown ? targetKeyView.shouldTriggerActionOnTouchDown : !targetKeyView.shouldTriggerActionOnTouchDown;
      if (targetKeyView != nil && shouldTrigger)
      {
         [targetKeyView executeActionBlock];
      }
   }
}

#pragma mark - Keyboard Map Updater Protocol
- (void)updateKeyboardKeyFrameTextMap:(KeyboardKeyFrameTextMap*)keyFrameTexMap
{
   self.keyFrameTextMap = keyFrameTexMap;
}

@end
