//
//  BlueIntentYYText.h
//  BlueIntent
//
//  Created by fm on 2021/5/11.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@class YYTextLayout;
#import <Foundation/Foundation.h>

@interface BlueIntentYYText : NSObject

// 公开 YYTextDrawText 使外部调用， https://github.com/ibireme/YYText/blob/7bd2aa41414736f6451241725778509fe75860b5/YYText/Component/YYTextLayout.m#L2596
+ (void)YYTextDrawText:(CGContextRef)context
                layout:(nullable YYTextLayout *)layout
                 point:(CGPoint)point
                  size:(CGSize)size
                cancel:(nullable BOOL(^)())cancel;

@end
