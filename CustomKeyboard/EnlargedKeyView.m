//
//  EnlargedKeyView.m
//  SoundBoard
//
//  Created by Gregory Klein on 2/2/15.
//  Copyright (c) 2015 Pure Virtual Studios, LLC. All rights reserved.
//

#import "EnlargedKeyView.h"
#import "KeyboardKeyLayer.h"
#import "CALayer+DisableAnimations.h"
#import "KeyView.h"

@interface EnlargedKeyView ()
@property (nonatomic) CAShapeLayer* enlargedKeyViewLayer;
@property (nonatomic) CALayer* shadowContainerLayer;
@property (nonatomic) KeyboardKeyLayer* letterLayer;
@end

@implementation EnlargedKeyView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame text:(NSString*)text
{
   if (self = [super initWithFrame:frame])
   {
      [self setupEnlargedKeyViewLayer];
      [self setupShadowLayer];

      [self.layer addSublayer:self.shadowContainerLayer];
      [self.shadowContainerLayer addSublayer:self.enlargedKeyViewLayer];

      self.letterLayer = [KeyboardKeyLayer layerWithText:text fontSize:24.f];
      [self.layer addSublayer:self.letterLayer];
   }
   return self;
}

#pragma mark - Class Init
+ (instancetype)viewWithKeyView:(KeyView *)keyView
{
   EnlargedKeyView* view = [[[self class] alloc] initWithFrame:keyView.bounds text:keyView.displayText];

   return view;
}

#pragma mark - Setup
- (void)setupEnlargedKeyViewLayer
{
   self.enlargedKeyViewLayer = [CAShapeLayer layer];

   self.enlargedKeyViewLayer.lineWidth = 2.f;
   self.enlargedKeyViewLayer.fillColor = [UIColor colorWithWhite:.2 alpha:.96].CGColor;
   self.enlargedKeyViewLayer.strokeColor = [UIColor whiteColor].CGColor;

   self.enlargedKeyViewLayer.shadowOpacity = .1f;
   self.enlargedKeyViewLayer.shadowRadius = 1.5f;
   self.enlargedKeyViewLayer.shadowOffset = CGSizeMake(0, .5f);

   [self.enlargedKeyViewLayer disableAnimations];
}

- (void)setupShadowLayer
{
   self.shadowContainerLayer = [CALayer layer];
   self.shadowContainerLayer.shadowOpacity = .25f;
   self.shadowContainerLayer.shadowRadius = 1.5f;
   self.shadowContainerLayer.shadowOffset = CGSizeMake(0, .5f);
}

#pragma mark - Update
- (void)updateEnlargedKeyPathWithFrame:(CGRect)frame
{
   CGPathRef keyPath = [self pathForKeyType:self.keyType frame:frame];
   self.enlargedKeyViewLayer.path = keyPath;
   CGPathRelease(keyPath);
}

#pragma mark - Public
- (void)updateFrame:(CGRect)frame
{
   self.frame = frame;
   [self updateEnlargedKeyPathWithFrame:CGRectInset(self.bounds, 4, 8)];

   CGRect letterLayerFrame = self.bounds;
   letterLayerFrame.origin.y -= 38;
   letterLayerFrame.origin.x += [self letterLayerXPositionOffsetForKeyType:self.keyType];
   self.letterLayer.frame = letterLayerFrame;
}

#pragma mark - Helper
- (CGPathRef)pathForKeyType:(EnlargedKeyType)keyType frame:(CGRect)frame
{
   CGPathRef keyPath = NULL;
   switch (keyType)
   {
      case EnlargedKeyTypeDefault:
         keyPath = [self defaultEnlargedKeyPathWithFrame:frame];
         break;
         
      case EnlargedKeyTypeLeft:
         keyPath = [self leftEnlargedKeyPathWithFrame:frame];
         break;
         
      case EnlargedKeyTypeRight:
         keyPath = [self rightEnlargedKeyPathWithFrame:frame];
         break;
         
      default:
         break;
   }
   return keyPath;
}

- (CGFloat)letterLayerXPositionOffsetForKeyType:(EnlargedKeyType)type
{
   CGFloat offset = 0;
   switch (type)
   {
      case EnlargedKeyTypeDefault:
         break;
         
      case EnlargedKeyTypeLeft:
         offset += 6.f;
         break;
         
      case EnlargedKeyTypeRight:
         offset -= 6.f;
         break;
         
      default:
         break;
   }
   return offset;
}

- (CGPathRef)defaultEnlargedKeyPathWithFrame:(CGRect)frame
{
   CGFloat minX = CGRectGetMinX(frame);
   CGFloat minY = CGRectGetMinY(frame);
   CGFloat maxX = CGRectGetMaxX(frame);
   CGFloat maxY = CGRectGetMaxY(frame);
   
   CGMutablePathRef keyPath = CGPathCreateMutable();
   
   CGPathMoveToPoint(keyPath, nil, minX, minY - 4);
   CGPathAddLineToPoint(keyPath, nil, minX - 12, minY - 14);
   CGPathAddLineToPoint(keyPath, nil, minX - 12, minY - 52);
   CGPathAddLineToPoint(keyPath, nil, maxX + 12, minY - 52);
   CGPathAddLineToPoint(keyPath, nil, maxX + 12, minY - 14);
   CGPathAddLineToPoint(keyPath, nil, maxX, minY - 4);
   CGPathAddLineToPoint(keyPath, nil, maxX, maxY);
   CGPathAddLineToPoint(keyPath, nil, minX, maxY);
   CGPathCloseSubpath(keyPath);
   
   return keyPath;
}

- (CGPathRef)leftEnlargedKeyPathWithFrame:(CGRect)frame
{
   CGFloat minX = CGRectGetMinX(frame);
   CGFloat minY = CGRectGetMinY(frame);
   CGFloat maxX = CGRectGetMaxX(frame);
   CGFloat maxY = CGRectGetMaxY(frame);
   
   CGMutablePathRef keyPath = CGPathCreateMutable();
   CGPathMoveToPoint(keyPath, nil, minX, minY - 52);
   CGPathAddLineToPoint(keyPath, nil, maxX + 12, minY - 52);
   CGPathAddLineToPoint(keyPath, nil, maxX + 12, minY - 14);
   CGPathAddLineToPoint(keyPath, nil, maxX, minY - 4);
   CGPathAddLineToPoint(keyPath, nil, maxX, maxY);
   CGPathAddLineToPoint(keyPath, nil, minX, maxY);
   CGPathCloseSubpath(keyPath);
   
   return keyPath;
}

- (CGPathRef)rightEnlargedKeyPathWithFrame:(CGRect)frame
{
   CGFloat minX = CGRectGetMinX(frame);
   CGFloat minY = CGRectGetMinY(frame);
   CGFloat maxX = CGRectGetMaxX(frame);
   CGFloat maxY = CGRectGetMaxY(frame);
   
   CGMutablePathRef keyPath = CGPathCreateMutable();
   
   CGPathMoveToPoint(keyPath, nil, minX, minY - 4);
   CGPathAddLineToPoint(keyPath, nil, minX - 12, minY - 14);
   CGPathAddLineToPoint(keyPath, nil, minX - 12, minY - 52);
   CGPathAddLineToPoint(keyPath, nil, maxX, minY - 52);
   CGPathAddLineToPoint(keyPath, nil, maxX, maxY);
   CGPathAddLineToPoint(keyPath, nil, minX, maxY);
   CGPathCloseSubpath(keyPath);
   
   return keyPath;
}

@end
