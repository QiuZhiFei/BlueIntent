//
//  BlueIntentYYText.m
//  BlueIntent
//
//  Created by fm on 2021/5/11.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@import YYText;
#import "BlueIntentYYText.h"

@implementation BlueIntentYYText

+ (void)YYTextDrawText:(CGContextRef)context
                layout:(nullable YYTextLayout *)layout
                 point:(CGPoint)point
                  size:(CGSize)size
                cancel:(nullable BOOL(^)())cancel
{
  if (layout == nil) {
    return;
  }
  
  CGContextSaveGState(context); {
    
    CGContextTranslateCTM(context, point.x, point.y);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, -1);
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    
    NSArray *lines = layout.lines;
    for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
      YYTextLine *line = lines[l];
      if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
      NSArray *lineRunRanges = line.verticalRotateRange;
      CGFloat posX = line.position.x + verticalOffset;
      CGFloat posY = size.height - line.position.y;
      CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
      for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextSetTextPosition(context, posX, posY);
        [self YYTextDrawRun:context line:line run:run size:size isVertical:isVertical runRanges:lineRunRanges[r] verticalOffset:verticalOffset];
      }
      if (cancel && cancel()) break;
    }
    
    // Use this to draw frame for test/debug.
    // CGContextTranslateCTM(context, verticalOffset, size.height);
    // CTFrameDraw(layout.frame, context);
    
  } CGContextRestoreGState(context);
}

+ (void)YYTextDrawRun:(CGContextRef)context
                 line:(YYTextLine *)line
                  run:(CTRunRef)run
                 size:(CGSize)size
           isVertical:(BOOL)isVertical
            runRanges:(NSArray *)runRanges
       verticalOffset:(CGFloat)verticalOffset
{
  CGAffineTransform runTextMatrix = CTRunGetTextMatrix(run);
  BOOL runTextMatrixIsID = CGAffineTransformIsIdentity(runTextMatrix);
  
  CFDictionaryRef runAttrs = CTRunGetAttributes(run);
  NSValue *glyphTransformValue = CFDictionaryGetValue(runAttrs, (__bridge const void *)(YYTextGlyphTransformAttributeName));
  if (!isVertical && !glyphTransformValue) { // draw run
    if (!runTextMatrixIsID) {
      CGContextSaveGState(context);
      CGAffineTransform trans = CGContextGetTextMatrix(context);
      CGContextSetTextMatrix(context, CGAffineTransformConcat(trans, runTextMatrix));
    }
    CTRunDraw(run, context, CFRangeMake(0, 0));
    if (!runTextMatrixIsID) {
      CGContextRestoreGState(context);
    }
  } else { // draw glyph
    CTFontRef runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
    if (!runFont) return;
    NSUInteger glyphCount = CTRunGetGlyphCount(run);
    if (glyphCount <= 0) return;
    
    CGGlyph glyphs[glyphCount];
    CGPoint glyphPositions[glyphCount];
    CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
    CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
    
    CGColorRef fillColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTForegroundColorAttributeName);
    fillColor = [self YYTextGetCGColor:fillColor];
    NSNumber *strokeWidth = CFDictionaryGetValue(runAttrs, kCTStrokeWidthAttributeName);
    
    CGContextSaveGState(context); {
      CGContextSetFillColorWithColor(context, fillColor);
      if (!strokeWidth || strokeWidth.floatValue == 0) {
        CGContextSetTextDrawingMode(context, kCGTextFill);
      } else {
        CGColorRef strokeColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTStrokeColorAttributeName);
        if (!strokeColor) strokeColor = fillColor;
        CGContextSetStrokeColorWithColor(context, strokeColor);
        CGContextSetLineWidth(context, CTFontGetSize(runFont) * fabs(strokeWidth.floatValue * 0.01));
        if (strokeWidth.floatValue > 0) {
          CGContextSetTextDrawingMode(context, kCGTextStroke);
        } else {
          CGContextSetTextDrawingMode(context, kCGTextFillStroke);
        }
      }
      
      if (isVertical) {
        CFIndex runStrIdx[glyphCount + 1];
        CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
        CFRange runStrRange = CTRunGetStringRange(run);
        runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
        CGSize glyphAdvances[glyphCount];
        CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
        CGFloat ascent = CTFontGetAscent(runFont);
        CGFloat descent = CTFontGetDescent(runFont);
        CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
        CGPoint zeroPoint = CGPointZero;
        
        for (YYTextRunGlyphRange *oneRange in runRanges) {
          NSRange range = oneRange.glyphRangeInRun;
          NSUInteger rangeMax = range.location + range.length;
          YYTextRunGlyphDrawMode mode = oneRange.drawMode;
          
          for (NSUInteger g = range.location; g < rangeMax; g++) {
            CGContextSaveGState(context); {
              CGContextSetTextMatrix(context, CGAffineTransformIdentity);
              if (glyphTransformValue) {
                CGContextSetTextMatrix(context, glyphTransform);
              }
              if (mode) { // CJK glyph, need rotated
                CGFloat ofs = (ascent - descent) * 0.5;
                CGFloat w = glyphAdvances[g].width * 0.5;
                CGFloat x = x = line.position.x + verticalOffset + glyphPositions[g].y + (ofs - w);
                CGFloat y = -line.position.y + size.height - glyphPositions[g].x - (ofs + w);
                if (mode == YYTextRunGlyphDrawModeVerticalRotateMove) {
                  x += w;
                  y += w;
                }
                CGContextSetTextPosition(context, x, y);
              } else {
                CGContextRotateCTM(context, YYTextDegreesToRadians(-90));
                CGContextSetTextPosition(context,
                                         line.position.y - size.height + glyphPositions[g].x,
                                         line.position.x + verticalOffset + glyphPositions[g].y);
              }
              
              if (YYTextCTFontContainsColorBitmapGlyphs(runFont)) {
                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
              } else {
                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                CGContextSetFont(context, cgFont);
                CGContextSetFontSize(context, CTFontGetSize(runFont));
                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
                CGFontRelease(cgFont);
              }
            } CGContextRestoreGState(context);
          }
        }
      } else { // not vertical
        if (glyphTransformValue) {
          CFIndex runStrIdx[glyphCount + 1];
          CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
          CFRange runStrRange = CTRunGetStringRange(run);
          runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
          CGSize glyphAdvances[glyphCount];
          CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
          CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
          CGPoint zeroPoint = CGPointZero;
          
          for (NSUInteger g = 0; g < glyphCount; g++) {
            CGContextSaveGState(context); {
              CGContextSetTextMatrix(context, CGAffineTransformIdentity);
              CGContextSetTextMatrix(context, glyphTransform);
              CGContextSetTextPosition(context,
                                       line.position.x + glyphPositions[g].x,
                                       size.height - (line.position.y + glyphPositions[g].y));
              
              if (YYTextCTFontContainsColorBitmapGlyphs(runFont)) {
                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
              } else {
                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                CGContextSetFont(context, cgFont);
                CGContextSetFontSize(context, CTFontGetSize(runFont));
                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
                CGFontRelease(cgFont);
              }
            } CGContextRestoreGState(context);
          }
        } else {
          if (YYTextCTFontContainsColorBitmapGlyphs(runFont)) {
            CTFontDrawGlyphs(runFont, glyphs, glyphPositions, glyphCount, context);
          } else {
            CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
            CGContextSetFont(context, cgFont);
            CGContextSetFontSize(context, CTFontGetSize(runFont));
            CGContextShowGlyphsAtPositions(context, glyphs, glyphPositions, glyphCount);
            CGFontRelease(cgFont);
          }
        }
      }
      
    } CGContextRestoreGState(context);
  }
}

+ (UIEdgeInsets)UIEdgeInsetRotateVertical:(UIEdgeInsets)insets
{
  UIEdgeInsets one;
  one.top = insets.left;
  one.left = insets.bottom;
  one.bottom = insets.right;
  one.right = insets.top;
  return one;
}

+ (CGColorRef)YYTextGetCGColor:(CGColorRef)color
{
  static UIColor *defaultColor;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    defaultColor = [UIColor blackColor];
  });
  if (!color) return defaultColor.CGColor;
  if ([((__bridge NSObject *)color) respondsToSelector:@selector(CGColor)]) {
    return ((__bridge UIColor *)color).CGColor;
  }
  return color;
}

@end
