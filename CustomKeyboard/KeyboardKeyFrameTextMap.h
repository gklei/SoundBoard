//
//  KeyboardKeyFrameTextMap.h
//  SoundBoard
//
//  Created by Klein, Greg on 1/26/15.
//  Copyright (c) 2015 Pure Virtual Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@class KeyView;
@class KeyViewCollection;

@interface KeyboardKeyFrameTextMap : NSObject

+ (instancetype)map;

- (void)reset;

- (void)addFrame:(CGRect)frame forKeyView:(KeyView*)keyView;
- (void)addFramesForKeyViewCollection:(KeyViewCollection*)collection;

- (void)enumerateFramesUsingBlock:(void (^)(CGRect targetFrame, NSString* text, BOOL *stop))block;

@property (nonatomic) UIView* keyboardView;

@end