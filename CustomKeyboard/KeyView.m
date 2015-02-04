//
//  LetterView.m
//  SoundBoard
//
//  Created by Gregory Klein on 1/21/15.
//  Copyright (c) 2015 Pure Virtual Studios, LLC. All rights reserved.
//

#import "KeyView.h"
#import "CALayer+DisableAnimations.h"

@interface KeyView ()
@property (nonatomic) KeyboardKeyLayer* keyLayer;
@property (nonatomic) CALayer* backgroundLayer;
@property (nonatomic, copy) dispatch_block_t actionBlock;
@end

@implementation KeyView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame])
   {
      [self setupBackgroundLayer];
   }
   return self;
}

- (instancetype)initWithText:(NSString*)text fontSize:(CGFloat)fontSize frame:(CGRect)frame
{
   if (self = [self initWithFrame:frame])
   {
      self.displayText = text;
      [self setupLetterLayerWithText:text fontSize:fontSize];
   }
   return self;
}

#pragma mark - Class Init
+ (instancetype)viewWithText:(NSString *)text fontSize:(CGFloat)fontSize frame:(CGRect)frame
{
   return [[[self class] alloc] initWithText:text fontSize:fontSize frame:frame];
}

#pragma mark - Setup
- (void)setupLetterLayerWithText:(NSString*)text fontSize:(CGFloat)fontSize
{
   self.keyLayer = [KeyboardKeyLayer layerWithText:text fontSize:fontSize];
   self.keyLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

   [self.layer addSublayer:self.keyLayer];
}

- (void)setupBackgroundLayer
{
   self.backgroundLayer = [CALayer layer];
   self.backgroundLayer.backgroundColor = [UIColor colorWithRed:31/255.f green:32/255.f blue:34/255.f alpha:1].CGColor;
   self.backgroundLayer.cornerRadius = 4.f;
   
   self.backgroundLayer.shadowOpacity = .25f;
   self.backgroundLayer.shadowRadius = 1.5f;
   self.backgroundLayer.shadowOffset = CGSizeMake(0, .5f);
   [self.backgroundLayer disableAnimations];
   
   [self.layer addSublayer:self.backgroundLayer];
}

#pragma mark - Public
- (void)updateFrame:(CGRect)frame
{
   self.frame = frame;
   self.backgroundLayer.frame = CGRectInset(self.bounds, 4, 8);
   self.keyLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)setActionBlock:(dispatch_block_t)block
{
   _actionBlock = block;
}

- (void)executeActionBlock
{
   if (self.actionBlock != nil)
   {
      self.actionBlock();
   }
}

- (void)giveFocus
{
   self.backgroundLayer.backgroundColor = [UIColor colorWithRed:31/255.f green:32/255.f blue:34/255.f alpha:1].CGColor;
}

- (void)removeFocus
{
   self.backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
}

@end
