//
//  GLKitView.m
//  WordArtProject
//  OpenGL渲染层
//  Created by richsjeson on 2017/10/27.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import "GLKitView.h"
#define kBrushOpacity        (1.0 / 3.0)
#define kBrushPixelStep        3
#define kBrushScale            2
#define WIDTH  [[UIScreen mainScreen]bounds].size.width
#define HEIGHT [[UIScreen mainScreen]bounds].size.height

#define kBrightness             1.0
#define kSaturation             0.45

#define kPaletteHeight            30
#define kPaletteSize            5
#define kMinEraseInterval        0.5
typedef struct {
    GLuint id;
    GLsizei width, height;
} textureInfo_t;
@interface GLKitView(){
    // OpenGL names for the renderbuffer and framebuffers used to render to this view
    GLuint viewRenderbuffer, viewFramebuffer;
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    GLuint depthRenderbuffer;
    textureInfo_t brushTexture;     // brush texture
    GLfloat brushColor[4];          // brush color
    
    Boolean    firstTouch;
    
    BOOL initialized;
}
@end
@implementation GLKitView

-(instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *) context{
    if ((self = [super initWithFrame:frame])) {
        self.mContext=context;
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        if (!context || ![EAGLContext setCurrentContext:context]) {
            return nil;
        }
    }
    return self;
}
-(void)layoutSubviews
{
    [EAGLContext setCurrentContext:self.mContext];
    
    if (!initialized) {
        initialized = [self initOpenGL];
    }
}
-(BOOL) initOpenGL{
    // Generate IDs for a framebuffer object and a color renderbuffer
    glGenFramebuffers(1, &viewFramebuffer);
    glGenRenderbuffers(1, &viewRenderbuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    // This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
    // allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
    [self.mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    glViewport(0, 0, _backingWidth, _backingHeight);
//    brushTexture = [self textureFromName:@"Particle.png"];
    if(self.delegate && [self.delegate respondsToSelector:@selector(renderGL)]){
        [self.delegate renderGL];
    }
    return YES;
}
//开始渲染
-(void) beginRender{
    [EAGLContext setCurrentContext:self.mContext];
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
}
//执行渲染
-(void) renderFrame{
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
@end
