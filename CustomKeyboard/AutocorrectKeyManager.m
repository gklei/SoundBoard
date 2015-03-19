//
//  AutocorrectKeyManager.m
//  SoundBoard
//
//  Created by Gregory Klein on 3/14/15.
//  Copyright (c) 2015 Pure Virtual Studios, LLC. All rights reserved.
//

#import "AutocorrectKeyManager.h"
#import "AutocorrectKeyController.h"
#import "SpellCorrectorBridge.h"
#import "UITextChecker+Additions.h"
#import "NSString+Additions.h"
#import "SpellCorrectionResult.h"

static NSString* _properCasing(NSString* string, BOOL uppercase)
{
   NSString* retVal = string;
   if (uppercase)
   {
      retVal = string.titleCase;
   }
   return retVal;
}

static BOOL _containsLetters(NSString* string)
{
   BOOL containsLetters = NO;
   for (int i = 0; i < string.length; ++i)
   {
      unichar character = [string characterAtIndex:i];
      if ([[NSCharacterSet letterCharacterSet] characterIsMember:character])
      {
         containsLetters = YES;
         break;
      }
   }
   return containsLetters;
}

/*
 Strings that are valid for correcting are in the following format:
 
 letters-symbols  --  e.g. "abcdefg??"
 symbols-letters  --  e.g. "??abcdefg"
 
 invalid examples: ??abcdefg??, ??abc?d?efg??, abcd??efg
 */
static BOOL _isValidForCorrecting(NSString* string)
{
   BOOL isValid = YES;
   if (string.length > 0)
   {
      unichar firstCharacter = [string characterAtIndex:0];
      if ([[NSCharacterSet letterCharacterSet] characterIsMember:firstCharacter])
      {
         NSInteger firstNonLetterCharacterIndex = -1;
         NSInteger firstLetterCharacterIndexAfterNonLetterCharacter = -1;
         for (NSUInteger charIndex = 0; charIndex < string.length; ++charIndex)
         {
            unichar currentChar = [string characterAtIndex:charIndex];
            if (![[NSCharacterSet letterCharacterSet] characterIsMember:currentChar] && firstNonLetterCharacterIndex == -1)
            {
               firstNonLetterCharacterIndex = charIndex;
            }
            else if ([[NSCharacterSet letterCharacterSet] characterIsMember:currentChar] && firstNonLetterCharacterIndex > 0 && firstLetterCharacterIndexAfterNonLetterCharacter == -1)
            {
               firstLetterCharacterIndexAfterNonLetterCharacter = charIndex;
            }
         }
         if (firstNonLetterCharacterIndex != -1 && firstLetterCharacterIndexAfterNonLetterCharacter != -1)
         {
            isValid = NO;
         }
      }
      else
      {
         NSInteger firstLetterCharacterIndex = -1;
         NSInteger firstNonLetterCharacterIndexAfterLetterCharacter = -1;
         for (NSUInteger charIndex = 0; charIndex < string.length; ++charIndex)
         {
            unichar currentChar = [string characterAtIndex:charIndex];
            if ([[NSCharacterSet letterCharacterSet] characterIsMember:currentChar] && firstLetterCharacterIndex == -1)
            {
               firstLetterCharacterIndex = charIndex;
            }
            else if (![[NSCharacterSet letterCharacterSet] characterIsMember:currentChar] && firstLetterCharacterIndex > 0 && firstNonLetterCharacterIndexAfterLetterCharacter == -1)
            {
               firstNonLetterCharacterIndexAfterLetterCharacter = charIndex;
            }
         }
         if (firstLetterCharacterIndex != -1 && firstNonLetterCharacterIndexAfterLetterCharacter != -1)
         {
            isValid = NO;
         }
      }
   }
   return isValid && _containsLetters(string);
}

@interface AutocorrectKeyManager ()
@property (nonatomic) AutocorrectKeyController* primaryController;
@property (nonatomic) AutocorrectKeyController* secondaryController;
@property (nonatomic) AutocorrectKeyController* tertiaryController;
@property (nonatomic) UITextChecker* textChecker;
@property (nonatomic) BOOL primaryControllerCanTrigger;
@end

@implementation AutocorrectKeyManager

#pragma mark - Init
- (instancetype)init
{
   if (self = [super init])
   {
      // this will do nothing if someone else already called this method, we're calling it
      // here just in case the text file used for spell correction hasn't been loaded yet
      [SpellCorrectorBridge loadForSpellCorrection];
      self.textChecker = [UITextChecker new];
   }
   return self;
}

#pragma mark - Public Class Methods
+ (instancetype)sharedManager
{
   static AutocorrectKeyManager* manager = nil;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      manager = [AutocorrectKeyManager new];
   });
   return manager;
}

#pragma mark - Private
- (void)updateControllersWithRealWord:(NSString*)text
{
   NSString* word = text;
   NSArray* guesses = [self.textChecker guessesForWord:_properCasing(word, text.isUppercase)];

   if (guesses.count > 0)
   {
      // punctuation hopefully
      NSString* secondaryWord = guesses[0];
      BOOL shouldUseGuess = NO;
      for (int charIndex = 0; charIndex < secondaryWord.length; ++charIndex)
      {
         if ([secondaryWord characterAtIndex:charIndex] == '\'')
         {
            shouldUseGuess = YES;
            break;
         }
      }

      if (shouldUseGuess == NO && ![text isEqualToString:word])
      {
         secondaryWord = text.quotedString;
      }
      [self.secondaryController updateText:secondaryWord];

      NSString* tertiaryWord = guesses.count > 1 ? guesses[1] : @"";
      [self.tertiaryController updateText:_properCasing(tertiaryWord, text.isUppercase)];
   }

   [self.primaryController updateText:word.quotedString];
   self.primaryControllerCanTrigger = YES;
}

- (void)updateControllersWithMisspelledWord:(NSString*)text corrections:(NSArray*)corrections
{
   [self.secondaryController updateText:text.quotedString];

   SpellCorrectionResult* firstResult = corrections[0];
   NSString* word = firstResult.word;

   [self.primaryController updateText:_properCasing(word, text.isUppercase)];
   self.primaryControllerCanTrigger = YES;

   if (corrections.count > 1)
   {
      for (int correctionIndex = 1; correctionIndex < corrections.count; ++correctionIndex)
      {
         SpellCorrectionResult* result = corrections[correctionIndex];
         NSString* resultWord = result.word;
         if (![resultWord isEqualToString:word])
         {
            [self.tertiaryController updateText:_properCasing(resultWord, text.isUppercase)];
            break;
         }
      }
   }
}

- (void)updateControllersWithInvalidWord:(NSString*)word
{
   [self.primaryController updateText:word.quotedString];
   [self.secondaryController updateText:@""];
   [self.tertiaryController updateText:@""];
}

#pragma mark - Public
- (void)setAutocorrectKeyController:(AutocorrectKeyController *)controller withPriority:(AutocorrectKeyControllerPriority)priority
{
   AutocorrectKeyManager* manager = [[self class] sharedManager];
   switch (priority)
   {
      case AutocorrectControllerPrimary:
         manager.primaryController = controller;
         break;

      case AutocorrectControllerSecondary:
         manager.secondaryController = controller;
         break;

      case AutocorrectControllerTertiary:
         manager.tertiaryController = controller;
         break;

      default:
         break;
   }
}

- (void)updateControllersWithTextInput:(NSString*)text
{
   self.primaryControllerCanTrigger = NO;
   if (text)
   {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

         if (_isValidForCorrecting(text))
         {
            NSArray* corrections = [SpellCorrectorBridge correctionsForText:text];
            if (corrections.count == 0)
            {
               [self updateControllersWithRealWord:text];
            }
            else
            {
               [self updateControllersWithMisspelledWord:text corrections:corrections];
            }
         }
         else
         {
            [self updateControllersWithInvalidWord:text];
         }
      });
   }
   else
   {
      [self resetControllers];
   }
}

- (void)resetControllers
{
   self.primaryControllerCanTrigger = NO;
   [self.primaryController updateText:@""];
   [self.secondaryController updateText:@""];
   [self.tertiaryController updateText:@""];
}

- (BOOL)triggerPrimaryKeyIfPossible
{
   BOOL triggered = NO;
   if (self.primaryControllerCanTrigger)
   {
      [self.primaryController trigger];
      triggered = YES;
   }
   return triggered;
}

@end
