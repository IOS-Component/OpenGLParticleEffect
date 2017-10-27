//
//  BrushRenderer.h
//  WordArtProject
//
//  Created by richsjeson on 2017/10/27.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseRenderer.h"
@interface BrushRenderer : BaseRenderer
-(void) prepareToDraw;
//绘制缓冲区
-(void) drawLine:(CGPoint) start endPoint:(CGPoint) end;
- (void)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
@property(nonatomic,readwrite)   GLfloat   pointSize;
@end
