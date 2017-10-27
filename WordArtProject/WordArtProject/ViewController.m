//
//  ViewController.m
//  WordArtProject
//
//  Created by richsjeson on 2017/10/27.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import "ViewController.h"
#import "GLKitView.h"
#import "GLKitHelper.h"
#import "BrushRenderer.h"
#define kBrightness             1.0
#define kSaturation             0.45

#define kPaletteHeight            30
#define kPaletteSize            5
#define kMinEraseInterval        0.5

// Padding for margins
#define kLeftMargin                10.0
#define kTopMargin                10.0
#define kRightMargin            10.0

#define  WIDTH  [[UIScreen mainScreen] bounds].size.width
#define  HEIGHT [[UIScreen mainScreen] bounds].size.height
#define  SCALE  [UIScreen mainScreen].scale



@interface ViewController ()<GLKitViewDelegate,GLKHelperDelegate>
@property(nonatomic,strong) GLKitView * glkView;
@property(nonatomic,strong) GLKitHelper *glkHelper;
@property(nonatomic,strong) BrushRenderer * brushRenderer;
@property(nonatomic,strong) EAGLContext * mContext;
@end


@implementation ViewController
@synthesize glkView;
@synthesize glkHelper;
@synthesize brushRenderer;
@synthesize mContext;
- (void)viewDidLoad {
    [super viewDidLoad];
    mContext=[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    CGColorRef color = [UIColor colorWithHue:(CGFloat)2.0 / (CGFloat)kPaletteSize
                                  saturation:kSaturation
                                  brightness:kBrightness
                                       alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    if(!glkView){
        glkView=[[GLKitView alloc] initWithFrame:self.view.bounds context:mContext];
        glkView.backingWidth=WIDTH*SCALE;
        glkView.backingHeight=HEIGHT*SCALE;
        glkView.delegate=self;
        [self.view addSubview:glkView];
    }
    if(!glkHelper){
        glkHelper=[[GLKitHelper alloc] init];
        glkHelper.delegate=self;
    }
    
    if(!brushRenderer){
        brushRenderer=[[BrushRenderer alloc] init];
        brushRenderer.renderProjectionMatrix=GLKMatrix4MakeOrtho(0,WIDTH*SCALE,0, HEIGHT*SCALE, -1, 1);
        brushRenderer.renderModelViewMatrix=GLKMatrix4Identity;
        brushRenderer.scale=SCALE;
        [brushRenderer colorWithRed:components[0] green:components[1] blue:components[2]];
    }
    glClearColor(0.1, 0.2, 0.3, 1);
    [EAGLContext setCurrentContext:mContext];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) renderGL{
    
    
    if(brushRenderer && glkHelper){
        textureInfo_t texure=[glkHelper createTexture:@"Particle"];
        brushRenderer.pointSize=texure.width/2;
        [brushRenderer prepareToDraw];
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    }
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(glkHelper){
        [glkHelper touchesBegan:touches withEvent:event view:glkView];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(glkHelper){
        [glkHelper touchesEnded:touches withEvent:event view:glkView];
    }
    
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(glkHelper){
        [glkHelper touchesMoved:touches withEvent:event view:glkView];
    }
}

-(void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
//    if(glkHelper){
//        [glkHelper touchesCancelled:touches withEvent:event view:glkView];
//    }
}

- (void)glTouchesBegan:(CGPoint) start  end:(CGPoint)end{

    
}
- (void)glTouchesMoved:(CGPoint) start  end:(CGPoint)end{
    [self glTouchesEnded:start end:end];
}
- (void)glTouchesEnded:(CGPoint) start  end:(CGPoint)end{
    if(glkView && brushRenderer){
        [glkView beginRender];
        [brushRenderer drawLine:start endPoint:end];
        [glkView renderFrame];
    }
}
@end
