//
//  BaseRenderer.h
//  WordArtProject
//  父级渲染层
//  Created by richsjeson on 2017/10/27.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKit.h>
#define glError() { \
GLenum err = glGetError(); \
if (err != GL_NO_ERROR) { \
printf("glError: %04x caught at %s:%u\n", err, __FILE__, __LINE__); \
} \
}
@interface BaseRenderer : NSObject
-(void) prepareToDraw;
-(BOOL) compileShader:(GLuint *) shader type:(GLenum) type file:(NSString *)file;
-(BOOL) linkProgram:(GLuint) program;
@property(nonatomic,assign) GLKMatrix4 renderProjectionMatrix;
@property(nonatomic,assign) GLKMatrix4 renderModelViewMatrix;
//屏幕比例
@property(nonatomic,assign) NSInteger scale;
@end
