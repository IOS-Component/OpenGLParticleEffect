//
//  Particle.h
//  WordArtProject
//
//  Created by richsjeson on 2017/10/27.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseRenderer.h"
#define kBrushOpacity        (1.0 / 3.0)
#define kBrushPixelStep        3
#define kBrushScale            2
@interface ParticleRenderer : BaseRenderer
-(void) prepareToDraw;
//-(void) drawLine:(CGPoint) start endPoint:(CGPoint) end;
@end
